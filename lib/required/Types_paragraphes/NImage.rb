module Prawn4book
class PdfBook
class NImage

  attr_reader :data
  attr_accessor :page_numero

  def initialize(data)
    @data = data.merge!(type: 'image')
  end

  # --- Helpers Methods ---

  ##
  # Méthode principale qui "imprime" le paragraphe dans le PDF
  # du livre
  # 
  def print(pdf, cursor_on_grid)
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

  # --- Predicate Methods ---

  def paragraph?; false end

  def svg?
    :TRUE == @issvg ||= true_or_false(extname == '.svg')
  end

  # 
  def extname
    @extname ||= File.extname(filename)
  end

  def filename
    @filename ||= data[:path]
  end

  def path
    @path ||= PdfBook.current.image_path(filename)
  end

end #/class NImage
end #/class PdfBook
end #/module Prawn4book
