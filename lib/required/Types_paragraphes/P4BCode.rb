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
    when 'new_page', 'nouvelle_page'
      pdf.start_new_page
    when 'tdm', 'toc'
      pdf.numero_page_toc = pdf.page_number
      pdf.start_new_page
    when 'index'
      pdfbook.page_index.build(pdf)
    when /^biblio/
      treate_as_biblio(pdf)
    else
      puts "Je ne sais pas traiter #{raw_code.inspect}"
    end

  end

  # --- Formatage Methods ---

  ##
  # Traitement spécial quand le code est une marque de bibliographie,
  # comme par exemple '(( biblio(livre) ))'
  # Il faut :
  #   - extraire le tag de la bibliographie
  #   - prendre la bibliographie instanciée
  #   - l'imprimer dans le livre
  def treate_as_biblio(pdf)
    bib_tag = raw_code.match(/^biblio\((.+)\)$/)[1]
    bib = Bibliography.get(bib_tag) || begin
      puts "Impossible de trouver la bibliographie '#{bib_tag}'…".rouge
      return
    end
    bib.print(pdf)
  end

  # --- Predicate Methods ---
  def paragraph?; false end

end #/class P4BCode
end #/class PdfBook
end #/module Prawn4book
