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
  # @param [String] str La chaine de caractère à traiter
  # @param [Hash]   context   Le contexte (et notamment le paragraph, les styles, etc.)
  # 
  # @return [String] la chaine de caractère corrigée
  # 
  def __parse(str, context)

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
    context[:font_size] ||= context[:size] || (context[:pdf] && context[:pdf].current_options && context[:pdf].current_options[:font_size]) || context[:paragraph].font_size

    #
    # Est-ce un texte avec un class-tags ?
    # (cf. l'explication au-dessus de la méthode, ci-dessous)
    #   
    str = __get_class_tags_in(str, context)

    #
    # Si une méthode de "pré-parsing" existe, on l'appelle. Elle
    # peut être définie pour chaque livre/collection
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
    # spy "str après format markdown inline : #{text.inspect}".orange

    #
    # Traitement des mots indexés
    # 
    str = __traite_mots_indexed_in(str, context)

    #
    # Traitement des références externes
    # 
    str = __traite_cross_references_in(str, context)

    #
    # Traitement des références internes
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
    # Traitement des class-tags
    # 
    str = __traite_class_tags_in(str, context)

    #
    # Si une méthode de parsing propre existe, on l'appelle
    # (@note : je ne sais plus à quoi elle correspond)
    # 
    str = parse(str, context) if respond_to?(:parse)


    return str
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
  def self.pdfbook; PdfBook.current end

  def formate_per_nature(pdf)
    return unless paragraph?
    pa = self
    pdf.update do 
      if pa.list_item?
        move_cursor_to_next_reference_line
        float { text '– ' }
      end
    end
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
    str.gsub(REG_CODE_RUBY) do
      code = $1.freeze
      if context[:paragraph]
        context[:paragraph].instance_eval(code)
      else
        eval(code)
      end
    end
  end
  REG_CODE_RUBY = /#\{(.+?)\}/.freeze


  def self.__traite_markdown_inline_in(str, context)
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
      dmot = {mot: $1.freeze, page: first_page, paragraph:numero_par}
      pdfbook.page_index.add(dmot)
      dmot[:mot] + $2
    end
    str = str.gsub(/index\((.+?)\)/) do
      mot, canon = $1.freeze.split('|')
      dmot = {mot: mot, canon: canon, page: first_page, paragraph: numero_par}
      pdfbook.page_index.add(dmot)
      dmot[:mot]
    end
    return str
  end

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
      pdfbook.table_references.add_and_get_cross_reference(book_id, cible)
    end

    return str    
  end
  REG_APPEL_CROSS_REFERENCE = /\(\( \->\((.+?):(.+?)\) +\)\)/.freeze

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
    if str.match?('\( <\-'.freeze)
      str = str.gsub(REG_CIBLE_REFERENCE) do
        cible = $1.freeze
        spy "[REFERENCES] Consignation de la référence #{cible.inspect} ({page:#{first_page}, paragraph:#{numero_par}})".bleu
        pdfbook.table_references.add(cible, {page:first_page, paragraph:numero_par})
        ''
      end
      # 
      # On corrige les éventuels retours chariot intempestifs
      # 
      str = str.gsub(/  +/, ' ')
    end
    #
    # - Traitement des APPELS -
    # 
    if str.match?('\( \->'.freeze)
      str = str.gsub(REG_APPEL_REFERENCE) do
        appel = $1.freeze
        spy "[REFERENCES] Consignation de l'appel à la référence #{appel.inspect}".bleu
        pdfbook.table_references.get(appel, self)
      end
    end

    return str
  end
  REG_CIBLE_REFERENCE       = /\(\( <\-\((.+?)\) \)\)/.freeze
  REG_APPEL_REFERENCE       = /\(\( \->\((.+?)\) +\)\)/.freeze

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

      biblio = Prawn4book::Bibliography.get(bib_tag) || raise("Impossible de trouver la bibliographie de tag #{bib_tag.inspect}")
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
        bibitem.add_occurrence({page: first_page, paragraph: parag_num})
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
        str = self.send(method_name, str, context)
      else
        raise (ERRORS[:parsing][:class_tag_formate_method_required] % method_name)
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
  REG_ITALIC    = /\*(.+?)\*/.freeze
  SPAN_ITALIC   = '<em>\1</em>'.freeze
  REG_START     = /mmSTARmm/.freeze

  def self.__traite_underline(str)
    return str unless str.match?('_')
    str .gsub(REG_TIRET_PLAT, 'mmTIRETmmPLATmm'.freeze)
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


end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
