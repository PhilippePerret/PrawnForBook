module Narration
class PdfBook
class NImage

  attr_reader :data

  def initialize(data)
    @data = data
  end

  # --- Helpers Methods ---

  def margin_bottom 
    20
  end

  # --- Predicate Methods ---

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
    @path ||= File.join(IMAGES_FOLDER, filename)
  end

end #/class NImage
end #/class PdfBook
end #/module Narration
