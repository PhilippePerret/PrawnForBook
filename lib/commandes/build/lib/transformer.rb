#
# Module User qui pourra contenir la définition des helpers
# 
module PrawnHelpersMethods
end
=begin

Module rassemblant toutes les méthodes qui permettent de parser et
de formater tous les types de paragraphe, à commencer par les textes
et les paragraphes.

=end
module ParserFormaterClass
  #
  # Ce module contient les MÉTHODES DE CLASSE qui vont être ajoutées
  # à Prawn4book::PdfBook::AnyParagraph
  # 
  
  ##
  # = main =
  # 
  # Méthode principale qui parse la chaine +str+ dans le context
  # +context+ et la renvoie corrigée
  # 
  # [001]
  #   Par défaut, l’index est construit à partir des codes "index(mot)"
  #   ou "index:mot" qui sont trouvés. Mais depuis la version 2.1,
  #   n’importe quel identifiant peut devenir un identifiant d’index.
  #   On peut avoir par exemple "Je connais bien people(John Doe)" qui
  #   utilise ’people’ comme id d’index.
  #   C’est la méthode #__traite_other_mots_indexed_in ci-dessous qui
  #   traite ce cas d’index
  # 
  # @param [String] str La chaine de caractère à traiter, qui peut
  #     être aussi bien un texte complet (une description de 
  #     bibliographie) qu'un simple paragraphe en passant par le
  #     contenu d'une cellule de table.
  # 
  # @param [Hash]   context   Le contexte (et notamment le paragraph, les styles, etc.)
  # 
  # @return [String|Nil] la chaine de caractère corrigée ou nil si le texte a été traité avant.
  # 
  # 
  # TODO : changer le nom de cette méthode parce qu'elle fait plus de
  # formatage que de parsing…
  # 
  def __parse(str, context)

    pdf = context[:pdf]

    # spy "ParserFormaterClass#__parse avec le texte : #{str.inspect}".orange
    # spy "Prawn4book::PdfBook::AnyParagraph.has_custom_paragraph_parser? = #{Prawn4book::PdfBook::AnyParagraph.has_custom_paragraph_parser?.inspect}".orange

    str.is_a?(String) || begin
      raise(Prawn4book::ERRORS[:parsing][:parse_required_string] % [str.inspect, str.class.name])
    end

    context[:paragraph] || begin
      raise Prawn4book::ERRORS[:parsing][:paragraph_required]
    end

    #
    # La taille actuelle de la fonte
    # 
    context[:font_size] ||= Prawn4book::Fonte.current.size

    #
    # Est-ce un texte avec un class-tags ?
    # (cf. l'explication au-dessus de la méthode, plus bas)
    #   
    str = __get_class_tags_in(str, context)

    #
    # Si une méthode de "pré-parsing" existe, on l'appelle. Elle
    # peut être définie pour chaque livre/collection dans :
    # Prawn4book::PdfBook::AnyParagraph#pre_parse
    # 
    # Définie pour AnyParagraph, elle est utilisable par tous les
    # types de paragraphe (titre, table, pfbcode, etc.). Sinon, on
    # peut l'implémenter pour une classe particulière.
    #
    if respond_to?(:pre_parse)
      str = pre_parse(str, context)
    end 

    # 
    # Traitement des codes ruby 
    # 
    str = __traite_codes_ruby_in(str, context)

    #
    # Ajout (optionnel) de la position du cursor (en début de texte)
    # (pour débuggage et mise en place du texte, avec l'option 
    #  -cursor)
    # 
    str = __maybe_add_cursor_position(str, context)

    #
    # Traitement du code in-line pseudo-markdown
    # 
    str = __traite_markdown_inline_in(str, context)

    #
    # Traitement des mots indexés (index:mot)
    # 
    str = __traite_mots_indexed_in(str, context)

    #
    # Traitement des autres mots indexés [001]
    # 
    str = __traite_other_mots_indexed_in(str, context)

    #
    # Traitement des références croisées externes
    # 
    str = __traite_cross_references_in(str, context)

    #
    # Traitement des références croisées internes
    # 
    str = __traite_references_in(str, context)

    #
    # Traitement des marques bibliograghiques
    # 
    str = __traite_termes_bibliographiques_in(str, context) if Prawn4book::Bibliography.any?

    #
    # Si des formatages propres existent 
    # 
    if Prawn4book::PdfBook::AnyParagraph.has_custom_paragraph_parser?
      str = ParserParagraphModule.paragraph_parser(str, context[:pdf])
    end

    #
    # Si une méthode de parsing propre existe, on l'appelle
    # (@note : je ne sais plus à quoi elle correspond)
    # 
    if respond_to?(:parse)
      str = parse(str, context)
    end

    #
    # Mini-traitements finaux, par exemple les apostrophes et les
    # guillemets, les espaces insécables avant les ponctuations 
    # doubles, etc.
    # 
    str = __corrections_typographiques(str, context)

    #
    # Traitement des autres signes
    # (méthode inaugurée pour traiter les tirets conditionnels)
    # 
    str = __traite_other_signs(str, context)

    #
    # Traitement des class-tags
    # 
    str = __traite_class_tags_in(str, context) || return # quand nil

    #
    # Traitement des notes
    # 
    str = __traite_notes_in(str, context) || return # quand nil

    return str
  end

  def recipe
    @recipe ||= Prawn4book::PdfBook.ensure_current.recipe
  end

end


module ParserFormater
  #
  # Module destiné à contenir les méthodes d'instance pour les
  # parseurs/formateurs
  # 

end

module Prawn4book
class PdfBook
class AnyParagraph

  extend ParserFormaterClass
  include ParserFormater

  # (ne pas mettre en cache : les tests foirent, sinon)
  def self.book; @@_book ||= PdfBook.current end
  def self.book=(value) # pour les tests
    @@_book = value 
  end

  ##
  # Pour le debuggage on peut vouloir ajouter la valeur du curseur
  # en début de texte du paragraphe. Pour ce faire, on ajouter
  # l'option '--cursor' à la ligne de commande
  # @rappel
  #   Le "curseur", c'est la hauteur vertical du prochain texte
  #   écrit avec 'pdf.text'
  # 
  # @return [Boolean] true s'il faut ajouter la valeur du curseur
  def self.add_cursor_position?
    :TRUE == @@addcurspos ||= true_or_false(CLI.option(:cursor))
  end
  def add_cursor_position?
    self.class.add_cursor_position?
  end

#
# TOUTES LES MÉTHODES DE TRAITEMENT
# 
# @note
#   On essaie de les mettre dans l'ordre où elles surviennent
# 
# 

private

  #
  # Traitement des class-tags
  # 
  # @rappel
  #   Une "class-tag" est une marque, au début du texte, suivi
  #   de "::" qui permet d'application une "classe" au paragraphe
  #   par exemple "monformat::Ce texte sera mis au style monformat."
  # 
  # @note
  #   Il peut y avoir autant de class_tags qu'on veut
  # 
  # @note
  #   Cette méthode est utilisée aussi bien pour des textes isolés,
  #   comme les textes d'une table, que pour la préparation des 
  #   paragraphes de texte.
  # 
  def self.__get_class_tags_in(str, context)
    return str unless str.match?(REG_LEADING_TAG)
    class_tags = str.split('::')
    str = class_tags.pop
    context.merge!(class_tags: class_tags)
    return str
  end
  REG_LEADING_TAG   = /^[a-z_0-9]+::/.freeze
  REG_LEADING_TAGS  = /^((?:(?:[a-z_0-9]+)::){1,6})(.+)$/.freeze

  # 
  # Traitement des codes ruby, qui se présentent dans le texte par
  # « #{...} »
  # 
  # @return [String] Le texte évalué (dans l'instance paragraphe
  # si elle est fournie)
  # 
  def self.__traite_codes_ruby_in(str, context)
    str = __traite_ruby_in_with_reg(str, context, REG_CODE_RUBY_PROTECTED)
    str = __traite_ruby_in_with_reg(str, context, REG_CODE_RUBY)
    return str
  end
  def self.__traite_ruby_in_with_reg(str, context, regexp)
    str.gsub(regexp) do
      mat = Regexp.last_match
      begin
        code = mat[:code].freeze
        no_return = mat[:tiret] == '-'

        result = 
          if context[:paragraph]
            context[:paragraph].instance_eval(code)
          else
            eval(code)
          end

        if no_return
          ""
        else
          result
        end
      rescue Exception => e
        raise PFBFatalError.new(101,{
          code: code,
          err: e.message,
          trace: e.backtrace[0..3].join("\n  ")
        })
      end
    end
  end
  REG_CODE_RUBY_PROTECTED = /#\{\{\{(?<tiret>\-)?(?<code>.+)\}\}\}/.freeze
  REG_CODE_RUBY = /#{EXCHAR}#\{(?<tiret>\-)?(?<code>.+?)\}/.freeze


  def self.__traite_markdown_inline_in(str, context)

    str = str.gsub('\<', '&lt;'.freeze)

    # 
    # Les gras ('**')
    # 
    str = __traite_bold(str)
    # 
    # Les italiques
    # 
    str = __traite_italic(str)
    # 
    # Les soulignés
    # 
    str = __traite_underline(str)
    #
    # Les exposants
    # 
    str = __traite_superscript(str)
    #
    # Les codes en backsticks
    # 
    str = __traite_backsticks(str)
    #
    # Les hyper-liens 
    # 
    str = __traite_hyperlinks(str)

    return str
  end

  ##
  # Traite les mots indexés (par 'index:mot' ou 'index(mot[|canon])' )
  # 
  # @return [String] Le texte sans les marques d'index
  # 
  def self.__traite_mots_indexed_in(str, context)
    numero_par = context[:paragraph].numero
    first_page = context[:paragraph].first_page
    str = str.gsub(/index:(.+?)(\b)/) do
      dmot = {
        mot:  $1.freeze, 
        page: first_page, 
        paragraph:numero_par,
        hybrid: "#{first_page}-#{numero_par}"
      }
      book.page_index.add(dmot)
      dmot[:mot] + $2
    end
    str = str.gsub(/index\((.+?)\)/) do
      mot, canon = $1.freeze.split('|')
      dmot = {
        mot:        mot, 
        canon:      canon, 
        page:       first_page, 
        paragraph:  numero_par,
        hybrid:     "#{first_page}-#{numero_par}"
      }
      book.page_index.add(dmot)
      dmot[:mot]
    end

    return str
  end

  # Traitement des index personnalisés
  # cf. [001]
  # 
  def self.__traite_other_mots_indexed_in(str, context)
    return str unless str.match?('\(')
    str = str.gsub(REG_INDEX) do
      indexId = $~[:index_id].to_sym.freeze
      output  = $~[:mot].freeze
      motId   = ($~[:id_mot] || output).freeze
      book.index(indexId).add(motId, output, **context)
    end

    return str    
  end

  REG_INDEX = /(?<=(^| ))(?<index_id>[a-z]+?)#{EXCHAR}\((?<mot>.+?)(?:\|(?<id_mot>.+?))?\)/.freeze

  ##
  # Traitement des références croisées
  # 
  # @note
  #   Seulement les références croisées. Pour les références
  #   internes, voir la méthode suivante
  # 
  def self.__traite_cross_references_in(str, context)
    #
    # Note : ici, contrairement aux références internes, on a 
    # que des appels.
    # 
    str = str.gsub(REG_APPEL_CROSS_REFERENCE) do
      book_id = $1.freeze
      cible   = $2.freeze
      book.table_references.add_and_get_cross_reference(book_id, cible)
    end

    return str    
  end
  REG_APPEL_CROSS_REFERENCE = /#{EXCHAR}\->\((.+?):(.+?)\)/.freeze

  ##
  # Traitement des références interne (seulement interne)
  # 
  # @note
  #   Voir la méthode précédente pour les références externes
  # 
  # @return [String] Le texte formaté
  # 
  def self.__traite_references_in(str, context)
    first_page = context[:paragraph].first_page
    numero_par = context[:paragraph].numero

    # 
    # - Traitement des CIBLES -
    # 
    if str.match?(REG_AMORCE_CIBLE)
      # puts "Une cible trouvée dans #{str.inspect}"
      # sleep 0.5
      str = str.gsub(REG_CIBLE_REFERENCE) do
        cible = $1.freeze
        spy "[REFERENCES] Consignation de la référence #{cible.inspect} ({page:#{first_page}, paragraph:#{numero_par}})".bleu
        book.table_references.add(cible, **{
          page:       first_page, 
          paragraph:  numero_par,
        })
        ''
      end
      # 
      # On corrige les éventuels espaces intempestifs
      # 
      str = str.gsub(/  +/, ' ')
    end
    #
    # - Traitement des APPELS -
    # 
    if str.match?(REG_AMORCE_APPEL)
      str = str.gsub(REG_APPEL_REFERENCE) do
        appel = $1.freeze
        spy "[REFERENCES] Consignation de l'appel à la référence #{appel.inspect}".bleu
        book.table_references.get(appel, context)
      end
    end

    return str
  end

  REG_AMORCE_CIBLE    = /#{EXCHAR}\<\-\(/.freeze
  REG_AMORCE_APPEL    = /#{EXCHAR}\-\>\(/.freeze
  REG_CIBLE_REFERENCE = / ?\<\-\((.+?)\)/.freeze
  REG_APPEL_REFERENCE = /\-\>\((.+?)\)/.freeze

  ##
  # Traitement des termes propres aux bibliographies
  # 
  # @return [String] Le texte formaté
  def self.__traite_termes_bibliographiques_in(str, context)
    parag_num   = context[:paragraph].numero.freeze
    first_page  = context[:paragraph].first_page.freeze

    str.gsub(Prawn4book::Bibliography::REG_OCCURRENCES) do

      bib_tag = $1.freeze
      item_av, item_ap = $2.freeze.split('|')

      biblio = Prawn4book::Bibliography.get(bib_tag) || raise(PFBFatalError.new(700, {bib: bib_tag.inspect}))
      canon, actual = 
        if (bibitem = biblio.exist?(item_av))
          [item_av, item_ap]
        elsif item_ap && (bibitem = biblio.exist?(item_ap))
          [item_ap, item_av]
        else
          # 
          # Item de bibliographie inconnu
          # 
          unfound = [item_av,item_ap].compact.join("/")
          building_error(ERRORS[:biblio][:bib_item_unknown] % ["#{unfound}".inspect, bib_tag])
          [nil, item_av]
        end
      #
      # Pour la clarté sémantique
      # 
      bibitem_has_been_found = not(canon.nil?)

      if bibitem_has_been_found
        # 
        # Ajout de cette occurrence
        # 
        bibitem.add_occurrence({
          page:       first_page, 
          paragraph:  parag_num,
        })
        #
        # Formatage de l'élément bibliographique
        # (propre ou simplement le :title)
        # 
        bibitem.formated(context, actual)
      end
    end
  end

  ##
  # @private
  # 
  # Traitement des notes
  # 
  def self.__traite_notes_in(str, context)

    return str unless str.match?('\^')

    # puts "str: #{str.inspect}"
    #
    # Traitement de la DÉFINITION DE LA NOTE
    #
    # - Note numérotée -
    str = str.gsub(REG_NOTE_DEF) {
      book.notes_manager.treate($1.to_i.freeze, $2.freeze, context)
    }
    # - Note auto-incrémentée -
    str = str.gsub(REG_NOTE_AUTO_DEF) {
      book.notes_manager.treate(nil, $1.freeze, context)
    }
    
    #
    # Traitement d'une MARQUE DE NOTE (appel)
    #
    # - Note numérotée - 
    str = str.gsub(REG_NOTE_MARK) {
      " <sup>#{book.notes_manager.add($1.freeze)}</sup>"
    }
    # - Note auto-incrémentée -
    str = str.gsub(REG_NOTE_AUTO) {
      " <sup>#{book.notes_manager.add(:auto)}</sup>" 
    }

    return str

  end
  REG_NOTE_AUTO     = /(?<!\\)\^\^/.freeze
  REG_NOTE_AUTO_DEF = /^#{EXCHAR}\^\^ (.+?)$/.freeze
  
  REG_NOTE_MARK = /#{EXCHAR}\^([0-9]+)/.freeze
  REG_NOTE_DEF  = /^#{EXCHAR}\^([0-9]+) (.+?)$/.freeze


  def self.__corrections_typographiques(str, context)
    str = __traite_apos_and_guils(str, context)
    str = __traite_ponctuations_doubles(str, context)
    str = __traite_points_suspensions(str, context)
    str = __traite_tirets_exergue(str,context)
    str = str.gsub(REG_ANTESLASHED,'\1')
    return str
  end


  def self.__traite_other_signs(str, context)
    
    # # - Trait d’union conditionnel -
    str = str.gsub('{-}'.freeze, Prawn::Text::SHY)

    return str
  end

  ##
  # @private
  # 
  # Traitement des class-tags
  # 
  # @note
  #   Elles peuvent être définies dans context[:class_tags] (pour les
  #   textes isolés comme les textes de cellule de table) ou dans
  #   context[:paragraph].class_tags pour les paragraphes
  # 
  def self.__traite_class_tags_in(str, context)
    class_tags = context[:class_tags] || context[:paragraph].class_tags
    #
    # Rien à faire si aucune classe n'est définie
    # 
    return str if class_tags.nil? || class_tags.empty?
    #
    # Sinon, on applique tous les styles
    # 
    class_tags.each do |class_tag|
      method_name = "formate_#{class_tag}".to_sym
      if self.respond_to?(method_name)
        # C'est une méthode utilisateur, on la protège
        begin
          str = self.send(method_name, str, context)
        rescue Exception => e
          raise PFBFatalError.new(5000, **{
            meth: method_name, err: e.message, context: "Classe tag “#{class_tag}”",
            trace: PFBFatalError.backtracize(e),
            module: PFBFatalError.get_last_script(e)
          })
        end
      else
        raise PFBFatalError.new(1000, **{meth: method_name})
      end
    end

    return str
  end


  def self.__maybe_add_cursor_position(str,context)
    # S'il le faut (options), ajouter la position du curseur en
    # début de paragraphe.
    if context[:paragraph].paragraph? && add_cursor_position?
      if str.is_a?(Array)
        str[0] = pdf.add_cursor_position(str[0])
      else
        str = pdf.add_cursor_position(str) 
      end
    end

    return str    
  end


  #
  # === SOUS-SOUS MÉTHODES ===
  # 
  
  #
  # Les items de liste
  # (attention ! cette méthode ne doit être appelée qu'extérieurement
  #  au traitement __parse normal)
  # 
  def self.__traite_liste_item(str, item_format = '<li>%s</li>'.freeze)
    str = str.gsub(REG_LIST_ITEM) {
      item_format % $1.strip
    }
  end
  REG_LIST_ITEM = /^\* (.+?)$/.freeze

  def self.__traite_bold(str)
    str = str.gsub(REG_BOLD) do
      txt = $1.freeze
      SPAN_BOLD % txt 
    end
  end
  REG_BOLD      = /\*\*(.+?)\*\*/.freeze
  SPAN_BOLD     = "<b>%s</b>".freeze

  def self.__traite_italic(str)
    return str unless str.match?('\*')
    str .gsub(REG_ETOILE, 'mmSTARmm'.freeze)
        .gsub(REG_ITALIC, SPAN_ITALIC)
        .gsub(REG_START,  '*'.freeze)
  end
  REG_ETOILE    = /\\\*/.freeze
  REG_ITALIC    = /\*([^ ].+?)\*/.freeze
  SPAN_ITALIC   = '<em>\1</em>'.freeze
  REG_START     = /mmSTARmm/.freeze

  def self.__traite_underline(str)
    return str unless str.match?('_')
    str .gsub(REG_TIRET_PLAT, 'mmTIRETmmPLATmm'.freeze) # pour que "\__gras__" ne soit pas transformé
        .gsub(REG_UNDERLINE, SPAN_UNDERLINE)
        .gsub(REG_PLAT_TIRET, '_'.freeze)
  end
  REG_TIRET_PLAT = /\\_/.freeze 
  REG_UNDERLINE = /__(.+?)__/.freeze
  SPAN_UNDERLINE = '<u>\1</u>'.freeze
  REG_PLAT_TIRET = /mmTIRETmmPLATmm/.freeze

  def self.__traite_superscript(str)
    str = str.gsub(REG_EXPOSANT) do
      lettre = $1.freeze
      expo   = $2.freeze
      SPAN_EXPOSANT % [lettre, expo]
    end
  end
  REG_EXPOSANT = /([0-9XVIC])\^(er|re|e)/.freeze
  SPAN_EXPOSANT = '%s<sup>%s</sup>'.freeze

  def self.__traite_backsticks(str)
    return str unless str.match?('`')
    str = str.gsub(REG_BACKSTICKS) do
      SPAN_BACKSTICKS % [$1.freeze]
    end  
  end
  REG_BACKSTICKS  = /#{EXCHAR}`(.+?)#{EXCHAR}`/.freeze
  SPAN_BACKSTICKS = '<font name="Courier">%s</font>'.freeze

  def self.__traite_hyperlinks(str)
    str = str.gsub(REG_HYPERLINKS, remplacement_hyperlink)
    return str
  end

  def self.remplacement_hyperlink
    @remplacement_hyperlink ||= begin
      if recipe.output_format == :pdf
        REMP_HYPERLINKS_IN_PDF
      else
        REMP_HYPERLINKS_IN_BOOK
      end
    end
  end
  REG_HYPERLINKS = /#{EXCHAR}\[(.+?)\]\((.+?)\)/.freeze
  REMP_HYPERLINKS_IN_PDF = '<a href="\2">\1</a>'.freeze
  REMP_HYPERLINKS_IN_BOOK = '\1 (\2)'.freeze
  # REG_HYPERLINKS = /(.)\[(.+?)\]\((.+?)\)/.freeze
  # REMP_HYPERLINKS_IN_PDF = '%{pref}<a href="%{href}">%{titre}</a>'.freeze
  # REMP_HYPERLINKS_IN_BOOK = '%{pref}%%{titre} (%{href})'.freeze

  ##
  # @private
  # 
  # Traitement des ponctuations doubles
  # 
  # 
  def self.__traite_ponctuations_doubles(str, context)
    str = str.gsub(REG_DLBPONCT) {
      befo = $1.freeze
      ponc = $2.freeze
      befo = '' if befo == ' '
      "#{befo} #{ponc}"
    }
    return str
  end
  REG_DLBPONCT = /([^ \\])([\!\?])/.freeze

  REG_ANTESLASHED = /\\(.)/.freeze

  ##
  # @private
  # 
  # Traitement des apostrophes et des guillemets
  # 
  # @note
  #   Normalement, tous les guillemets droits qui viennent de code ou
  #   de définitions ont été traités avant, on devrait donc pouvoir 
  #   traiter tous ceux qui restent sans souci.
  # 
  #   Les apostrophes (') sont automatiquement remplacés par de vrais
  #   apostrophes (’).
  #   Les guillemets sont remplacés par la valeur par défaut ou le
  #   choix de l'utilisateur. Sont recherchés aussi bien les " que 
  #   les “ ou les chevrons «
  #  
  def self.__traite_apos_and_guils(str, context)
    str = str.gsub(REG_APO, '\1’')
    # 
    # @note
    #   [1] Au moment où les guillemets sont remplacés, tous les codes
    #       ont été évalués, il n'y a donc plus rien à craindre. On 
    #       laisse simplement tranquille les guillemets précédés par
    #       un échappement.
    #       FAUX : il reste les guillemets qu'on trouve dans le code
    #       html, par exemple les <color rbg="CCFFJJ">...</color>
    #       Donc, au final, un guillemet droit n'est remplacé que
    #       si on trouve une espace avant ou une parenthèse, et
    #       une espace après le deuxième ou un point ou un point
    #       de suspension ou une parenthèse.
    #   [2] Il faut aussi uniformiser les guillemets, c'est-à-dire
    #       que des bons guillemets peuvent avoir été mis dans le 
    #       texte, par exemple des courbes, mais qu'au final on 
    #       veuille utiliser les chevrons, ils seront remplacés. On
    #       par alors de "contre-guillemets"
    str = str.gsub(REG_GUILS_DROITS) {
      found = Regexp.last_match
      data = {
        before: found[:before], 
        content:found[:content].strip,
        after: found[:after]
      }
      remp_guillemets % data
    }

    str = str.gsub(reg_guillemets) {
      found = Regexp.last_match
      data = {      
        before: "",
        after:  "",
        content: found[:content]
      }
      remp_guillemets % data
    }

    # Cf. [2]
    str = str.gsub(reg_contre_guillemets) {
      found = Regexp.last_match
      remp_contre_guillemets % {content: found[:content].strip}
    }

    return str
  end

  def self.reg_guillemets
    recipe.reg_guillemets
  end
  def self.remp_guillemets
    recipe.remp_guillemets
  end

  def self.reg_contre_guillemets
    recipe.reg_contre_guillemets
  end
  def self.remp_contre_guillemets
    recipe.remp_contre_guillemets
  end

  # Cf. la @note [1] ci-dessus
  REG_GUILS_DROITS = /(?<before>[\( ])" ?(?<content>.*?) ?"(?<after>[\),; .…])/.freeze

  REG_APO = /(qu|d|j|l|n|m|s|t)'/.freeze

  def self.__traite_points_suspensions(str, context)
    str = str.gsub('...', '…')
    return str
  end

  def self.__traite_tirets_exergue(str, context)
    str = str.gsub(REG_TIRET_EXERGUE) {
      signe   = $1.freeze
      content = $2.strip.freeze
      "#{signe} #{content} #{signe}"
    }
    return str
  end
  REG_TIRET_EXERGUE = /#{EXCHAR}([—–])[ ]?(.+?) ?\2/.freeze

end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
