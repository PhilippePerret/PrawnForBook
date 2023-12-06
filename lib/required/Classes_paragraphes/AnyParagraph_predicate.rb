module Prawn4book
class PdfBook
class AnyParagraph

  def title?    ; false end
  def paragraph?; false end
  def printed?  ; false end 
  # def some_text? ; false end # surclassé par les filles
  def pfbcode?  ; false end
  def citation? ; false end
  def list_item?; false end
  def note_page?; false end
  def empty_paragraph?; false end
  def image?    ; false end
  def table?    ; false end

  # @return true si c’est un paragraphe textuel à enrouler autour
  # d’une image (s’il commence, donc, par un "!")
  def wrapped?  ; false end

  def has_unknown_target?
    @unknown_targets.any?
  end

  # Sera mis à true pour les paragraphes qui ne doivent pas être
  # imprimés, par exemple les paragraphes qui définissent des 
  # propriétés pour les paragraphes suivants.
  def not_printed?
    @isnotprinted === true
  end

  def kerning?
    not(kerning.nil?)
  end

  def character_spacing?
    not(character_spacing.nil?)
  end

end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
