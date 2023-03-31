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

    raise "Je ne dois plus passer par là."

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

    # # 
    # # Traitement des codes ruby 
    # # 
    # str = __traite_codes_ruby_in(str)
    # # spy "str après code ruby : #{str.inspect}".orange

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
