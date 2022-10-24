module ParserParagraphModule

  ##
  # La méthode ci-dessous est appelée sur chaque paragraphe de
  # texte pour en tirer les informations voulues.
  # 
  def __paragraph_parser(paragraphe)
    # Parse le paragraphe {PdfBook::NTextParagraph}
    str = paragraphe.text

    # # Par exemple, le code ci-dessous tient à jour une table
    # # d'index qui relèvera toutes les balises 'index(mot)' dans les
    # # paragraphe en relevant le numéro des paragraphes où on le 
    # # trouve
    # @table_index ||= {}
    # str = str.gsub(/index\((.+?)\)/) do
    #   mot_indexed = $1.freeze
    #   @table_index.key?(mot_indexed) || @table_index.merge!(mot_indexed => [])
    #   @table_index[mot_indexed] << paragraphe.numero
    #   mot_indexed # remplacement
    # end

  end

end #/module
