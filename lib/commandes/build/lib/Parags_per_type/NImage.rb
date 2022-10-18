module Prawn4book
class PdfBook
class NImage < AnyParagraph

  # --- Helpers Methods ---

  ##
  # Méthode principale qui "imprime" le paragraphe dans le PDF
  # du livre
  # 
  def print(pdf)
    if svg?
      pdf.svg IO.read(path), color_mode: :cmyk
    else
      pdf.image path, x: 0
    end
  end

  def margin_top
    2
  end
  def margin_bottom 
    2
  end

end #/class NImage
end #/class PdfBook
end #/class Prawn4book
