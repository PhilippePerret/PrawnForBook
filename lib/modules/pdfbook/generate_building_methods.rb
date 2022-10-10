=begin

  Méthodes de construction du livre

=end
module Prawn4book
class PdfFile < Prawn::Document

  ##
  # Construction du faux titre
  #
  def build_faux_titre(pdfbook)
    require_relative 'generate_builder/faux_titre'
    insert_faux_titre(pdfbook)
  end

  def build_page_de_titre(pdfbook)
    require_relative 'generate_builder/page_de_titre'
    insert_page_de_titre(pdfbook)
  end



end #/PdfFile
end #/Prawn4book
