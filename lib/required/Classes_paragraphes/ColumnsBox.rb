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

  # Tous les paragraphes ont été rentrés, il faut les graver 
  # dans la page.
  # 
  # @note
  #   On ne se sert pas de column_box de Prawn qui est trop limité,
  #   qui n’est pas capable, par exemple, d’ajuster la hauteur des
  #   colonnes en fonction du texte pour avoir un traitement optimal.
  # 
  def print(pdf)
    my = self
    @pdf = pdf

    # Dans un premier temps, il faut calculer la hauteur qu’il faudra
    # utiliser dans l’absolue, en fonction de la longueur du texte.
    # 
    calc_height(pdf)

    options = {
      width: width||pdf.bounds.width,
      # height: 200, # réagit à ça
      columns: column_count,
      spacer: gutter,
      reflow_margins: true,
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

  def text_options
    @text_options ||= {
      align: :justify,
      inline_format: true
    }
  end


  private

    # Principe de calcul simple : on fait une colonne unique qui 
    # contient tout le texte et l’on en demande la hauteur, qu’on
    # divise par le nombre de colonnes demandées.
    def calc_height(pdf)
      h = nil # La valeur cherchée
      my = self

      @gutter ||= pdf.line_height
      @width  ||= pdf.bounds.width

      # Liste pour mettre tous les textes obtenus
      text_ary = []

      # Pour calculer, on met tout dans une colonne qui fait
      # la taille de colonne voulue
      column_width = (width - (gutter * (column_count - 1)) ) # largeur en retirant les gouttières
      column_width = column_width / column_count

      pdf.update do
        bounding_box([0,bounds.top], width: column_width, height: 1000000) do
          my.paragraphs.each do |par|
            par.prepare_and_formate_text(pdf)
            str = "#{par.string_indentation}#{par.text}"
            p = []
            text_ary += text_formatter.format(str, *p)
          end
          h = height_of_formatted(text_ary, my.text_options)
          @segments = text_ary # TODO: S’en servir pour écrire dans les colonnes
        end
      end #/pdf.update
      # 
      return h
    end

end #/class ColumnsBox
end #/class PdfBook
end #/module Prawn4book
