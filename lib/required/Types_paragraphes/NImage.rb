module Prawn4book
class PdfBook
class NImage

  attr_reader :data
  attr_accessor :page_numero

  def initialize(data)
    @data = data.merge!(type: 'image')
  end

  # --- Helpers Methods ---

  def margin_bottom 
    20
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
