module Prawn4book
class PdfBook
class ColumnsBox

  attr_reader :book, :pdf
  attr_reader :params
  attr_reader :column_count, :gutter, :width
  attr_reader :paragraphs

  def initialize(book, **params)
    @book = book
    @column_count = params[:column_count]
    @gutter       = params[:gutter]
    @width        = params[:width]
    @paragraphs   = []
  end

  def inspect
    "<<Bloc Colonne nombre:#{column_count} gutter:#{gutter}>>"
  end

  def print(pdf)
    @pdf = pdf

    options = {
      width: width||pdf.bounds.width, 
      spacer: gutter,
    }

    pdf.column_box([0, pdf.cursor], **options) do
      paragraphs.each do |paragraph|
        # paragraph.print(pdf)
        puts "Je dois écrire le paragraphe #{paragraph.pindex}"
      end
    end

  end

  # Ajoute un paragraphe à cet affichage par colonne
  # 
  # @param par [PfbBook::AnyParagraph]
  #   Le paragraphe ajouté
  def add_paragraph(par)
    paragraphs << par
  end

end #/class ColumnsBox
end #/class PdfBook
end #/module Prawn4book
