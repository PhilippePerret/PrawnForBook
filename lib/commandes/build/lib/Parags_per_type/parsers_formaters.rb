=begin

Module rassemblant toutes les méthodes qui permettent de formater
les textes (sauf, bien entendu, le formateurs définis pour le livre
ou la collection dans helpers.rb et formaters.rb)

Pourquoi "bien entendu" ci-dessus ????
Ça serait pourtant ici que ça serait le mieux.

=end
module Prawn4book
class PdfBook
class AnyParagraph


  # La méthode générale pour formater le texte +str+
  # Note : on pourrait aussi prendre self.text, mais ça permettra
  # d'envoyer un texte déjà travaillé
  # + ça permet d'envoyer n'importe quel texte, comme celui provenant
  #   d'un code à évaluer ou d'un tableau (pour le moment, il semble
  #   que les tables ne passent pas par là, peut-être parce qu'elles
  #   sont transformées en lignes et écrites séparément)
  def formated_text(pdf, str = nil)
    # 
    # Soit on utilise le texte +str+ transmis, soit on prend le
    # text du paragraphe.
    # 
    str ||= text

    # spy "str initial : #{str.inspect}".orange

    # 
    # Traitement des marques de formatage spéciales
    # (par exemple 'perso(Selma)' dans la collection narration)
    # TODO C'est traité quelque part, mais il faut tout rassembler
    # ici

    # 
    # Traitement des codes ruby 
    # 
    str = __traite_codes_ruby_in(str)
    # spy "str après code ruby : #{str.inspect}".orange

    # 
    # Traitement des mots indexé
    #
    if str.match?('index:') || str.match?('index\(')
      str = __traite_mots_indexed_in(str)
      # spy "str après recherche index : #{str.inspect}".orange
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
    # Traitement du pseudo-format markdown
    # 
    # ATTENTION : cet traitement peut retourner deux éléments
    # 
    str = __traite_pseudo_markdown_format(str, pdf)

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
  end #/formated_text

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

  REG_BOLD      = /\*\*(.+?)\*\*/
  SPAN_BOLD     = "<b>%s<b>".freeze
  REG_ITALIC    = /\*(.+?)\*/
  SPAN_ITALIC   = '<em>%s</em>'.freeze
  REG_UNDERLINE = /__(.+?)__/
  SPAN_UNDERLINE  = '<u>%s</u>'.freeze

  REG_LIST_ITEM = /^\* (.*)$/
  
  # @return [String] Le texte traité 
  # 
  # Ça s'appelle "pseudo-markdown" car on utilise les mêmes marques
  # pour les mêmes choses, mais c'est traité en interne, de façon
  # tout à fait particulière.
  # 
  def __traite_pseudo_markdown_format(str, pdf)
    # 
    # Les citations
    # 
    is_exergue_citation = str.start_with?('> ')

    str = "<em>#{str[2..-1]}</em>" if is_exergue_citation

    # 
    # Les listes (repérées par des lignes qui commencent par '* ')
    # 
    # @note
    #   Incompatible avec une citation exergue
    is_item_of_liste = not(is_exergue_citation) && str.match?(REG_LIST_ITEM)

    if is_exergue_citation && is_item_of_liste
      raise "Un paragraphe ne peut pas être en même temps une citation en exergue et un item de liste. Faire un style propre, au besoin."
      is_exergue_citation = false
    end

    if is_item_of_liste
      str = str.gsub(REG_LIST_ITEM) do
        txt = $1.freeze
        txt
      end
    end

    # 
    # Les gras ('**')
    # 
    str = str.gsub(REG_BOLD) do
      txt = $1.freeze
      SPAN_BOLD % txt 
    end

    # 
    # Les italiques
    # 
    str = str.gsub(REG_ITALIC) do
      txt = $1.freeze
      SPAN_ITALIC % txt
    end

    # 
    # Les soulignés
    # 
    str = str.gsub(REG_UNDERLINE) do
      txt = $1.freeze
      SPAN_UNDERLINE % txt
    end

    if is_item_of_liste
      pdf.update do 
        move_cursor_to_next_reference_line
        float do
          text '– '
        end
      end
      return [str, {mg_left:0.3.cm, no_num: true, cursor_positionned: true}]
    elsif is_exergue_citation
      return [str, {size: font_size(pdf) + 2, mg_left: 1.cm, mg_right: 1.cm, mg_top: 0.5.cm, mg_bot: 0.5.cm, no_num:true}]
    else
      return str
    end
  end

  # @return [String] Le texte formaté
  def __traite_references_in(str)    
    if str.match?('\( <\-')
      str = str.gsub(REG_CIBLE_REFERENCE) do
        cible = $1.freeze
        spy "[REFERENCES] Consignation de la référence #{cible.inspect}".bleu
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
  def __traite_termes_bibliographiques_in(str)
    str.gsub(Bibliography::REG_OCCURRENCES) do
      bib_tag = $1.freeze
      item_id, item_titre = $2.freeze.split('|')
      spy "Biblio pour : #{item_titre.inspect}".rouge if item_titre
      # item_id = item_id.to_sym
      bibitem = Bibliography.add_occurrence_to(bib_tag, item_id, {page: first_page, paragraph: numero})
      if bibitem
        item_titre || bibitem.formated_for_text
      else
        building_error(ERRORS[:biblio][:bib_item_unknown] % [item_id.inspect, bib_tag.inspect])
        item_id
      end
    end
  end

  # @return [String] Le texte formaté
  def __traite_codes_ruby_in(str)
    str.gsub(/#\{(.+?)\}/) do
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

  # @return [String] Le texte formaté
  def __traite_mots_indexed_in(str)
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

end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
