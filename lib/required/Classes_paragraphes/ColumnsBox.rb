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
    my = self
    @pdf = pdf

    options = {
      width: width||pdf.bounds.width, 
      columns: column_count,
      spacer: gutter,
    }

    text_options = {
      align: :justify,
      inline_format: true
    }

    pdf.update do
      column_box([0, cursor], **options) do
        my.paragraphs.each do |par|
          # par.print(pdf)
          par.prepare_and_formate_text(pdf)
          text("#{par.string_indentation}#{par.text}", **text_options)
        end
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
