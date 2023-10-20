require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class EmptyParagraph < AnyParagraph

  #
  # Avec la version 2 (LINE) même les paragraphes vides du fichier
  # texte source génère une instance (je ne sais pas encore pourquoi,
  # mais je préfère le faire, ça ne coûte pas grand-chose à l'échelle
  # d'un livre même épais)
  # Ça pourrait servir, par exemple, pour savoir si un paragraphe est
  # précédé ou suivi d'un paragraphe vide.
  # Les paragraphes vides sont de cette classe.
  # 

  def initialize(book:, pindex:, text: "")
    super(book, pindex)
    @type = 'empty'
    @text = text
  end

  def print
    # On ne fait rien
  end

  def add(str)
    @text = "#{text}\n#{str}"
  end

  def paragraph?; false end
  def emptypar?;  true  end
  def sometext? ; false end
  alias :some_text? :sometext?
  def titre?    ; false end
  def citation? ; false end
  def list_item?; false end


end #/class EmptyParagraph
end #/class PdfBook
end #/module Prawn4book
