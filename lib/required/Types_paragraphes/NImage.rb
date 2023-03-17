require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class NImage < AnyParagraph

  attr_reader :data
  attr_accessor :page_numero

  def initialize(pdfbook, data)
    super(pdfbook)
    dispatch_style(data[:style]) if data.key?(:style)
    @data = data.merge!(type: 'image')
  end

  def dispatch_style(style)
    style.split(';').each do |propval|
      prop, val = propval.split(':').map{|n|n.strip}
      self.instance_variable_set("@#{prop}", val)
    end
  end

  def pourcent_to_real_value(value, pdf)
    # 
    # Vérifier les valeurs en %
    # 
    if value.end_with?('%')
      pct = value[0...-1].strip.to_i
      value = (pdf.bounds.width * pct).to_f / 100
      # puts "new value = #{value}"
      # puts "pdf.width = #{pdf.bounds.width.inspect}"
      # puts "87mmm = #{87.mm}"
    end
    return value
    
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
