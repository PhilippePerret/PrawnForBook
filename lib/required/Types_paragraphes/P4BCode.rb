require_relative 'AnyParagraph'
module Prawn4book
class PdfBook
class P4BCode < AnyParagraph

  attr_reader :raw_code

  def initialize(pdfbook, raw_code)
    super(pdfbook)
    @raw_code = raw_code[3..-3].strip
  end

  def print(pdf)
    
    case raw_code
    when 'new_page'
      pdf.start_new_page
    when 'index'
      pdfbook.page_index.build(pdf)
    else
      puts "Je ne sais pas traiter #{raw_code.inspect}"
    end

  end

  # --- Predicate Methods ---
  def paragraph?; false end

end #/class P4BCode
end #/class PdfBook
end #/module Prawn4book
