=begin

Module rassemblant toutes les méthodes qui permettent de formater
les textes (sauf, bien entendu, le formateurs définis pour le livre
ou la collection dans helpers.rb/formaters.rb)

=end
module Prawn4book
class PdfBook
class AnyParagraph


  # La méthode générale pour formater le texte +str+
  # Note : on pourrait aussi prendre self.text, mais ça permettra
  # d'envoyer un texte déjà travaillé
  def formated_text(pdf, str = nil)
    # 
    # Soit on utilise le texte +str+ transmis, soit on prend le
    # text du paragraphe.
    # 
    str ||= text
    # 
    # Traitement des codes ruby 
    # 
    str = __traite_codes_ruby_in(str)

    # 
    # Traitement des mots indexé
    #
    if str.match?('index:') || str.match?('index\(')
      str = __traite_mots_indexed_in(str)
    end

    #
    # Traitement des marques bibliograghiques
    # 
    if Bibliography.any?
      str = __traite_termes_bibliographiques_in(str)
    end

    #
    # Traitement des références (appels et cibles)
    # 
    str = __traite_references_in(str)

    # S'il le faut (options), ajouter la position du curseur en
    # début de paragraphe.
    str = pdf.add_cursor_position(str) if add_cursor_position?

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
      spy "item_titre = #{item_titre.inspect}".rouge
      item_id = item_id.to_sym
      bibitem = Bibliography.add_occurrence_to(bib_tag, item_id, {page: first_page, paragraph: numero})
      item_titre || bibitem.title
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
