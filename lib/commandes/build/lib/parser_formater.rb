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
  def __parse(str, context)

    context[:paragraph] || begin
      raise ERRORS[:parsing][:paragraph_required]
    end

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
    # Si une méthode de parsing propre existe, on l'appelle
    # 
    if respond_to?(:parse)
      str = parse(str, context)
    end

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
    # @note
    #   C'est dans cette méthode, aussi, qu'on définit les paramètres
    #   spéciaux de formatage (par exemple la marge pour les listes
    #   ou les citations)
    # 
    detecte_et_traite_nature_paragraphe(pdf)
    
    # 
    # Formatage général
    # 
    @text = self.class.__parse(text, {pdf: pdf, paragraph: self})

  end

  #
  # @produit @final_text (le texte final à afficher)
  # 
  def final_formatage(pdf)
    spy "-> final_formatage de #{text.inspect}".jaune
    @text = formate_text(pdf, text)

    @final_text = self.class.formatage_final(text, pdf)

    spy "Fin #final_formatage de #{text.inspect}"
  end

  # (ne pas mettre en cache : les tests foirent, sinon)
  def self.pdfbook; PdfBook.current end

  # = main =
  #

  ##
  # On doit détecter la nature de certains paragraphes avant le
  # formatage pour éviter certains problèmes. Typiquement, si un
  # paragraphe est un item de liste et qu'il contient un texte en 
  # italique, il peut ressembler à :
  #   * un item de *liste* avec italique
  # Mais s'il est formaté tel quel, alors la portion "* un item de *"
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
      final_specs.merge!({size: font_size(pdf) + 1, mg_left: 1.cm, mg_right: 1.cm, mg_top: 0.5.cm, mg_bot: 0.5.cm, no_num:true})
    end
    # 
    # Est-ce un item de liste ?
    # 
    @is_list_item = paragraph? && text.match?(REG_LIST_ITEM)
    if list_item?
      @text = text[1..-1].strip
      final_specs.merge!({mg_left:3.mm, no_num: true, cursor_positionned: true})
    end
    #
    # Est-ce une ligne de table ?
    # 
    @is_table_line = paragraph? && text.match?(REG_TABLE_LINE)
  end
  REG_LIST_ITEM   = /^\* .+$/.freeze
  REG_CITATION    = /^> .+$/.freeze
  REG_TABLE_LINE  = /^\|/.freeze 



  def formate_text(pdf, str)
    spy "[formate_text] str initial : #{str.inspect}".orange

    if list_item?
      str = formate_as_list_item(pdf, str)
    elsif citation?
      str = formate_as_citation(pdf, str)
    end

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

#
# TOUTES LES MÉTHODES DE TRAITEMENT
# 
# @note
#   On essaie de les mettre dans l'ordre où elles surviennent
# 
# 

private

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

      unless canon.nil?
        # 
        # Si le canon est défini (ie si le mot a été reconnu dans la bibliographie)
        # alors on enregistre une occurrence pour lui.
        # 

        # 
        # Ajout de cette occurrence
        # 
        bibitem.add_occurrence({page: first_page, paragraph: parag_num})

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
