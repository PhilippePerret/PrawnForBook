require_relative 'AnyParagraph'
module Prawn4book
class PdfBook
class P4BCode < AnyParagraph

  def initialize(raw_code)
    @raw_code = raw_code
  end

  def print(pdf)
    
    pdf.update do

      case @raw_code
      when 'new_page'
        start_new_page
      else
        puts "Je ne sais pas traiter #{@raw_code}"
      end

    end

  end

  # --- Predicate Methods ---
  def paragraph?; false end

end #/class P4BCode
end #/class PdfBook
end #/module Prawn4book
