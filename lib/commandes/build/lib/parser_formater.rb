=begin

Module rassemblant toutes les méthodes qui permettent de formater
les textes (sauf, bien entendu, le formateurs définis pour le livre
ou la collection dans helpers.rb et formaters.rb)

Pourquoi "bien entendu" ci-dessus ????
Ça serait pourtant ici que ça serait le mieux.

=end
module Prawn4book
class PdfBook
  # Méthode qui doit être surclassée par les modules propres
  def parser_formater(str,pdf); str end

class AnyParagraph

  ##
  # Préformatage d'un string quelconque, dissocié de tout élément.
  # Ça peut être tout aussi bien le @text d'un paragraphe que le
  # contenu d'une cellule de table.
  # 
  # Ce préformatage n'a pas besoin de connaitre le pdf-viewer
  # courant.
  # 
  def self.preformatage(str)
    # 
    # Traitement des codes ruby 
    # 
    # (ce sont tous les codes qui sont mis dans #{...})
    # 
    str = __traite_codes_ruby_in(str)
    # spy "str après code ruby : #{text.inspect}".orange

    # 
    # Traitement des formats inline markdown 
    # (les étoiles, tirets plats, etc.)
    # 
    # Ne sont pas traités ici les listes (qui demande un traitement
    # au moment de l'impression) ou les blocs de notes
    # 
    str = __traite_format_markdown_inline(str)
    # spy "str après format markdown inline : #{text.inspect}".orange

    return str    
  end

  # [String] Le texte final, tel qu'il est vraiment écrit par 
  # pdf.
  attr_reader :final_text
  
  # [Hash] Table des spécifications finales pour l'impression du
  # paragraphe (quel qu'il soit)
  attr_accessor :final_specs


  def preformate(pdf)
    spy "#preformate de #{text.inspect}"
    self.final_specs = {}
    if pfbcode && pfbcode.parag_style
      final_specs.merge!(pfbcode.parag_style)
    end
    # 
    # Détection de la nature du texte
    # 
    detecte_et_traite_nature_paragraphe(pdf)
    # 
    # Préformatage général
    # 
    @text = self.class.preformatage(text)

  end

  #
  # @produit @final_text (le texte final à afficher)
  # 
  def final_formatage(pdf)
    spy "-> final_formatage de #{text.inspect}".jaune
    @text = formate_text(pdf, text)

    @final_text = self.class.formatage_final(text, pdf)

    #
    # Maintenant qu'on a tous les éléments (options), on peut
    # parser et formater le paragraphe.
    # 
    if pdfbook.module_parser? # && parag.some_text?
      # pdfbook.__paragraph_parser(self, pdf)
    end

    spy "Fin #final_formatage de #{text.inspect}"
  end

  #
  # @class
  # 
  # Méthode qui passe par toutes les méthodes de formatage, personna-
  # lisées comme communes.
  # 
  def self.formatage_final(str, pdf)
    str = pdfbook.parser_formater(str, pdf)
    return str
  end

  def self.pdfbook; @pdfbook ||= PdfBook.current end

  # = main =
  #

  ##
  # On doit détecter la nature de certains paragraphes avant le
  # formatage pour éviter certains problème. Typiquement, si un
  # paragraphe est un item de liste et qu'il contient un texte en 
  # italique, il peut ressembler à :
  #   * un item de *liste* avec italique
  # Mais s'il est formaté tel quel, alors la portion "* un item de "
  # va être considérée comme en italique.
  # Il faut donc :
  #   - détecter qu'il s'agit un item de liste (self.list_item?)
  #   - retirer la marque de début dans @text
  # On peut ensuite le formater comme convenu
  def detecte_et_traite_nature_paragraphe(pdf)
    # 
    # Est-ce une citation ?
    # 
    @is_citation = paragraph? && text.match?(REG_CITATION)
    if citation?
      @text = text[1..-1].strip
      final_specs.merge!({size: font_size(pdf) + 2, mg_left: 1.cm, mg_right: 1.cm, mg_top: 0.5.cm, mg_bot: 0.5.cm, no_num:true})
    end
    # 
    # Est-ce un item de liste
    # 
    @is_list_item = paragraph? && text.match?(REG_LIST_ITEM)
    if list_item?
      @text = text[1..-1].strip
      final_specs.merge!({mg_left:3.mm, no_num: true, cursor_positionned: true})
    end
  end
  REG_LIST_ITEM = /^\* .+$/.freeze
  REG_CITATION  = /^> .+$/.freeze



  def formate_text(pdf, str)
    spy "[formate_text] str initial : #{str.inspect}".orange

    if list_item?
      str = formate_as_list_item(pdf, str)
    elsif citation?
      str = formate_as_citation(pdf, str)
    end

    #
    # Traitement des marques bibliograghiques
    # 
    if Bibliography.any?
      str = __traite_termes_bibliographiques_in(str)
      # spy "str après recherche biblio : #{str.inspect}".orange
    end

    #
    # Traitement des références (appels et cibles)
    # 
    str = __traite_references_in(str)

    #
    # Traitement des mots indexés
    # 
    str = __traite_mot_indexed(str)

    #
    # Ajout (optionnel) de la position du cursor
    # (débuggage et mise en place du texte)
    # 
    str = __maybe_add_cursor_position(str)

    spy "[formate_text] str final : #{str.inspect}".orange
    
    return str
  end


  def __traite_mot_indexed(str)
    if str.match?('index:') || str.match?('index\(')
      str = __traite_mots_indexed_in(str)
      # spy "str après recherche index : #{str.inspect}".orange
    end
    
    return str
  end

  def formate_as_list_item(pdf, str)
    str = text
    pdf.update do 
      move_cursor_to_next_reference_line
      float { text '– ' }
    end
    return str
  end

  def formate_as_citation(pdf, str)
    str = "<em>#{str.strip}</em>"
    return str
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


private

  # @return [String] Le texte formaté
  def __traite_references_in(str)    
    if str.match?('\( <\-')
      str = str.gsub(REG_CIBLE_REFERENCE) do
        cible = $1.freeze
        spy "[REFERENCES] Consignation de la référence #{cible.inspect} ({page:#{first_page}, paragraph:#{numero}})".bleu
        pdfbook.table_references.add(cible, {page:first_page, paragraph:numero})
        ''
      end
      # 
      # On corrige les éventuels retours chariot intempestifs
      # 
      str = str.gsub(/  +/, ' ')
    end
    # Appels de référence
    if str.match?('\( \->')
      str = str.gsub(REG_APPEL_REFERENCE) do
        appel = $1.freeze
        spy "[REFERENCES] Consignation de l'appel à la référence #{appel.inspect}".bleu
        pdfbook.table_references.get(appel, self)
      end
    end
    return str
  end

  # @return [String] Le texte formaté
  def __traite_mots_indexed_in(str)
    # spy "Traitement de #{str.inspect} pour l'index"
    str = str.gsub(/index:(.+?)(\b)/) do
      dmot = {mot: $1.freeze, page: first_page, paragraph:numero}
      pdfbook.page_index.add(dmot)
      dmot[:mot] + $2
    end
    str = str.gsub(/index\((.+?)\)/) do
      mot, canon = $1.freeze.split('|')
      dmot = {mot: mot, canon: canon, page: first_page, paragraph: numero}
      pdfbook.page_index.add(dmot)
      dmot[:mot]
    end
    return str
  end

  def __maybe_add_cursor_position(str)
    # S'il le faut (options), ajouter la position du curseur en
    # début de paragraphe.
    if paragraph? && add_cursor_position?
      if str.is_a?(Array)
        str[0] = pdf.add_cursor_position(str[0])
      else
        str = pdf.add_cursor_position(str) 
      end
    end

    return str    
  end

  ##
  # Traitement des termes propres aux bibliographies
  # 
  # @return [String] Le texte formaté
  def __traite_termes_bibliographiques_in(str)
    str.gsub(Bibliography::REG_OCCURRENCES) do
      
      bib_tag = $1.freeze
      item_av, item_ap = $2.freeze.split('|')

      biblio = Bibliography.get(bib_tag) || raise("Impossible de trouver la bibliographie de tag #{bib_tag.inspect}")
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

      unless canon.nil?
        # 
        # Si le canon est défini (ie si le mot a été reconnu dans la bibliographie)
        # alors on enregistre une occurrence pour lui.
        # 

        # 
        # Ajout de cette occurrence
        # 
        bibitem.add_occurrence({page: first_page, paragraph: numero})

        if actual
          bibitem.formate_for_text(actual, self)
        elsif bibitem.respond_to?(:formated_for_text)
          bibitem.formated_for_text(self)
        else
          bibitem.title
        end
      end
    end
  end

  # 
  # Traitement des codes ruby, qui se présentent dans le texte par
  # « #{...} »
  # Le code à l'intérieur des accolades peut être du code à interpréter
  # tel quel (un opération par exemple, ou une date) ou alors une
  # méthode personnalisée définie dans les helpers.
  # 
  # @return [String] Le texte formaté
  # 
  REG_CODE_RUBY = /#\{(.+?)\}/.freeze
  def self.__traite_codes_ruby_in(str)
    str.gsub(REG_CODE_RUBY) do
      code = $1.freeze
      methode = nil
      if code.match?(REG_HELPER_METHOD)
        # C'est peut-être une méthode d'helpers qui est appelée
        methode = code.match(REG_HELPER_METHOD)[1].to_sym
      end
      if methode && pdfbook.pdfhelpers && pdfbook.pdfhelpers.respond_to?(methode)
        # 
        # Une méthode helper propre au livre ou à la collection
        # 
        pdfbook.pdfhelpers.instance_eval(code)
      else
        #
        # Un code général
        # 
        eval(code)
      end
    end
  end
  REG_HELPER_METHOD = /^([a-zA-Z0-9_]+)(\(.+?\))?$/


  def self.__traite_format_markdown_inline(str)
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
