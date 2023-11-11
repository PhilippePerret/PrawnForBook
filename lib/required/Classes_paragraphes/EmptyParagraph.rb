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

  def print(pdf)
    # On ne fait rien
  end

  def add(str)
    @text = "#{text}\n#{str}"
  end

  def paragraph?; false end
  def empty_paragraph?; true end
  def some_text? ; false end
  def title?    ; false end
  def citation? ; false end
  def list_item?; false end

  # @return true si c'est un commentaire
  def comment?
    self.is_comment === true
  end
  
  attr_accessor :is_comment

end #/class EmptyParagraph
end #/class PdfBook
end #/module Prawn4book
