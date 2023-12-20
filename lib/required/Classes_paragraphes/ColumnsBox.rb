module Prawn4book
class PdfBook
class ColumnsBox

  attr_reader :book, :pdf
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
  def initialize(book, **params)
    @book       = book
    @params     = params
    @paragraphs = []
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
    hauteur_total = calc_height(pdf)

    # Largeur d’une colonne, avec sa gouttière
    column_fullwidth = width / column_count
    # Largeur d’une colonne, hors gouttière
    column_width     = column_fullwidth - gutter
    # Hauteur pour une des colonnes, dans l’absolu
    column_height = (hauteur_total / column_count) #+ 6 * pdf.line_height
    # Pour récupérer plus facilement les données
    ColumnData.count      = column_count
    ColumnData.full_width = column_fullwidth
    ColumnData.width      = column_width
    ColumnData.height     = column_height
    ColumnData.gutter     = gutter


    if space_before > 0
      pdf.update do
        move_down(my.space_before)
        move_to_next_line
      end
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
    hrest = column_height.dup
    while hrest > 0
      required_height = [hrest, pdf.cursor].min
      # required_height =
      #   if pdf.cursor < hrest
      #     pdf.cursor
      #   else
      #     hrest + pdf.line_height * 4
      #   end

      if Prawn4book.second_turn?
        puts <<~EOT

          Hauteur total (1 colonne) : #{hauteur_total}
          Nombre de colonnes : #{column_count}
          Hauteur de colonne : #{column_height}
          hrest   : #{hrest}
          Hauteur requise pour ce tour : #{required_height}
          Cursor : #{pdf.cursor}
          Nombre de segments restants : #{segments.count}
          EOT
        # exit 12 if Q.no?("Dois-je poursuivre ?".jaune)
      end
      build_columns_for_height(required_height)
      hrest = hrest - required_height
      pdf.start_new_page
      pdf.move_to_first_line
    end


    # S’il doit y avoir du texte après
    if space_after > 0
      pdf.update do
        move_down(my.space_after)
        move_to_closest_line
      end
    end

  end

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

  # Ajoute un paragraphe à cet affichage par colonne au cours
  # du parsing du texte.
  # 
  # @param par [PfbBook::AnyParagraph]
  #   Le paragraphe ajouté
  def add_paragraph(par)
    paragraphs << par
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

      # TODO: Je ne sais pas où, mais il y a une erreur quelque part
      # car il ne faut compter la gouttière qu’entre les colonnes
      # intérieures. Pour le moment, si on regarde la première triple
      # colonne, on voit que la largeur de la dernière colonne n’atteint
      # pas le bout (parce qu’on compte aussi la gouttière).
      # Pourtant, ci-dessus, j’enlève bien le nombre - 1 de colonnes
      # multiplié à la gouttière. Donc, s’il y a deux colonnes, 
      # j’enlève seulement une fois la gouttière à la largeur 
      # totale…

      pdf.update do
        current_cursor = cursor.freeze
        bounding_box([0,bounds.top], width: column_width, height: 1000000) do
          my.paragraphs.each do |par|
            par.prepare_and_formate_text(pdf)
            str = "#{par.string_indentation}#{par.text}"
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
