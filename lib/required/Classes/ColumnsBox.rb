module Prawn4book
class PdfBook
class ColumnsBox < ParagraphAccumulator

  #[Hash] La table des paramètres tels qu’ils ont été transmis
  attr_reader :params
  attr_reader :column_count, :gutter, :width
  attr_reader :paragraphs
  # [Array<Hash>] La liste des segments formatés du texte
  attr_reader :segments

  # Instanciation de la multi-colonne
  # 
  # @param params [Hash]
  #     Table des paramètres
  #     --------------------
  #     column_count:   Le nombre de colonnes
  #                     Default: 2
  #     width:          Largeur sur laquelle tiennent les colonnes
  #                     Default: la largeur de page
  #     gutter:         La gouttière
  #                     Default: la hauteur de ligne
  #     space_before:   Espace vide à laisser avant les colonnes
  #     space_after:    Espace vide à laisser après les colonnes
  # 
  #     lines_before:   Nombre de lignes avant (default: 1)
  #     lines_after:    Nombre de lignes après (default: 1)
  # 
  def initialize(book, **params)
    super(book)
    @params     = params
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
    super

    my = self

    # Dans un premier temps, il faut calculer la hauteur qu’il faudra
    # utiliser dans l’absolue, en fonction de la longueur du texte.
    # 
    hauteur_total = calc_height(pdf)
    column_height = hauteur_total / column_count
    h = column_height
    unless params[:no_extra_line_height]
      h += (column_count - 1) * pdf.line_height
    end
    ColumnData.height = h

    if space_before != 0
      pdf.move_down(space_before)
      pdf.update_current_line
    end
    pdf.move_to_next_line
    if lines_before > 0
      lines_before.times { pdf.move_to_next_line }
    elsif lines_before < 0
      lines_before.abs.times { pdf.move_to_previous_line }
    end

    # Maintenant qu’on a la hauteur que prend le texte avec les
    # colonnes définies, on peut déterminer les blocs à faire. On les
    # fait et on met le texte au fur et à mesure
    # On construit des colonnes tant qu’il reste de la hauteur à 
    # mettre.
    # 
    # @noter que ça peut tenir sur des dizaines de pages, voire
    # tout le livre (même si ça ne serait pas très heureux…)
    # 
    hrest = ColumnData.height.dup
    while hrest > 0
      required_height = [hrest, pdf.cursor].min

      # if Prawn4book.second_turn?
      #   puts <<~EOT

      #     Hauteur total (1 colonne) : #{hauteur_total}
      #     Nombre de colonnes : #{ColumnData.count}
      #     Hauteur de colonne : #{ColumnData.height}
      #     hrest   : #{hrest}
      #     Hauteur requise pour ce tour : #{required_height}
      #     Cursor : #{pdf.cursor}
      #     Nombre de segments restants : #{segments.count}
      #     EOT
      #   # exit 12 if Q.no?("Dois-je poursuivre ?".jaune)
      # end

      build_columns_for_height(required_height)
      hrest = hrest - required_height
      if hrest > 0
        pdf.start_new_page
        pdf.move_to_first_line
      end
    end
    pdf.update_current_line

    if lines_after > 0
      lines_after.times { pdf.move_to_next_line }
    elsif lines_after == 0
      pdf.move_to_previous_line
    elsif lines_after < 0
      lines_after.abs.times { pdf.move_to_previous_line }
    end

    # Reste-t-il des segments ?
    if segments.any?
      puts "Il reste des segments dans un texte en double colonnes : #{segments.inspect}…".rouge
      exit 12
    end

    # S’il doit y avoir du texte après
    if space_after != 0
      pdf.move_down(space_after)
      pdf.move_to_closest_line
    end

  end #/print

  def build_columns_for_height(required_height)
    init_cursor = pdf.cursor.freeze
    column_count.times do |itime|
      left = ColumnData.full_width * itime
      bb_options = {
        height: required_height,
        width:  ColumnData.width,
      }
      pdf.bounding_box([left, init_cursor], **bb_options) do
        @segments = pdf.formatted_text_box(segments, **text_options.merge(overflow: :truncate))
      end
    end #/x nombre de colonnes
  end

  def text_options
    @text_options ||= {
      align:          :justify,
      inline_format:  true
    }
  end

  # -- Data Methods --

  def column_count
    @column_count ||= (params[:column_count] || 2).freeze
  end

  def width
    @width ||= (params[:width] || pdf.bounds.width).freeze
  end

  def gutter
    @gutter ||= (params[:gutter] || pdf.line_height).freeze
  end

  def lines_before
    @lines_before ||= begin
      if params[:lines_before] === false
        0
      else
        params[:lines_before] || 1
      end
    end
  end

  def lines_after
    @lines_after ||= begin
      if params[:lines_after] === false
        0
      else
        params[:lines_after] || 1
      end
    end
  end

  def space_before
    @space_before ||= (params[:space_before] || 0.0).freeze
  end

  def space_after
    @space_after ||= (params[:space_after] || 0.0).freeze
  end

  def segments ; @segments end
  def segments=(value); @segments = value end

  private

    # Principe de calcul simple : on fait une colonne unique qui 
    # contient tout le texte et l’on en demande la hauteur, qu’on
    # divise par le nombre de colonnes demandées.
    def calc_height(pdf)
      h = nil # La valeur cherchée
      my = self

      # Liste pour mettre tous les textes obtenus
      text_ary = []

      # Pour calculer, on met tout dans une colonne qui fait
      # la taille de colonne voulue
      column_width = (width - (gutter * (column_count - 1)) ) # largeur en retirant les gouttières
      column_width = (column_width / column_count).freeze

      ColumnData.count      = column_count
      ColumnData.width      = column_width
      ColumnData.full_width = column_width + gutter
      ColumnData.gutter     = gutter

      pdf.update do
        current_cursor = cursor.freeze
        bounding_box([0,bounds.top], width: column_width, height: 1000000) do
          # my.paragraphs.each do |par|
          my.each_paragraph do |par|
            # par.prepare_and_formate_text(pdf)
            str = par.indented_text
            p = []
            text_ary += text_formatter.format(str, *p)
          end
          h = height_of_formatted(text_ary, my.text_options)
        end
        my.segments = text_ary
        # On se remet en place
        move_cursor_to(current_cursor)
      end #/pdf.update
      
      return h
    end

end #/class ColumnsBox

# Pour manipuler plus facilement les données
class ColumnData
class << self
  attr_accessor :count, :width, :height, :full_width, :gutter
end #/<< self
end #/class ColumnData

end #/class PdfBook
end #/module Prawn4book
