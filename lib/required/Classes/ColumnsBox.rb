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
    @params = params
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

    # Pour connaitre la ligne courante (sur la grille)
    pdf.update_current_line

    # On transforme le texte des colonnes en segments avec format
    divide_text_in_segments(pdf)

    # Premiers calcul (largeur colonnes, etc.)
    calc_dimensions(pdf)

    # Dans un premier temps, il faut calculer la hauteur qu’il faudra
    # utiliser dans l’absolue, en fonction de la longueur du texte.
    # 
    calc_column_height(pdf)

    # Y a-t-il de l’espace avant ?
    if space_before != 0
      pdf.move_down(space_before)
      pdf.update_current_line
    end

    # Y a-t-il des lignes de séparation ?
    if lines_before > 0
      lines_before.times { pdf.move_to_next_line }
    elsif lines_before < 0
      lines_before.abs.times { pdf.move_to_previous_line }
    end

    # Police propre à appliquer à toute la section
    # 
    pdf.font(fonte) if fonte

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
      
      # - Construction des colonnes pour la hauteur voulue -
      build_columns_for_height(required_height)

      hrest -= required_height
      pdf.start_new_page if hrest > 0
    end
    pdf.update_current_line

    # Reste-t-il des segments ?
    # Je ne sais pas vraiment comment m’y prendre.
    # La solution pourrait être : faire une première passe en dry_run
    # juste pour voir (mais comment gérer les changements de page =>
    # en se remettant au-dessus). S’il reste quelque chose, on ajoute
    # une ligne en dessous. Sinon, on imprime vraiment.
    # 
    # TODO Un jour, il faudra vraiment s’attaquer au problème et
    # voir d’où il vient, afin de le corriger proprement. Pour le
    # moment, tout ce qu’il me semble, c’est que ça survient en bas
    # de page, quand il reste une seule ligne. L’application devrait
    # logiquement y poser un segment de plus (une ligne de plus) mais
    # curieusement ne le fait pas.
    # 
    if segments.any?
      cursor_init = pdf.cursor.freeze
      pdf.move_to_line(pdf.current_line)
      icursor = pdf.cursor
      build_a_column_for_height(column_count - 1, icursor, pdf.line_height)
      pdf.start_new_page if cursor_init < pdf.line_height
      if segments.any?
        # raise PFBFatalError.new(180, [column_count, @debug_start_column, segments.count])
        add_erreur(PFBError[180] % [column_count, @debug_start_column, segments.count])
      else
        add_erreur(PFBError[181] % [column_count, @debug_start_column])
      end
      pdf.update_current_line
    end

    pdf.update_current_line

    # S’il faut ajouter des lignes après
    # 
    if lines_after > 0
      lines_after.times { pdf.move_to_next_line }
    elsif lines_after == 0
      # pdf.move_to_next_line
      # pdf.move_to_closest_line
      # pdf.move_to_previous_line
      pdf.move_to_line(pdf.current_line)
    elsif lines_after < 0
      lines_after.abs.times { pdf.move_to_previous_line }
    end

    # S’il doit y avoir du texte après
    if space_after != 0
      pdf.move_down(space_after)
      pdf.move_to_closest_line
    end

  end #/print

  # Construction de toutes les colonnes de texte
  # 
  def build_columns_for_height(required_height)
    init_cursor = pdf.cursor.freeze
    column_count.times do |itime|
      build_a_column_for_height(itime, init_cursor, required_height)
    end #/x nombre de colonnes
  end

  def apply_color?
    :TRUE == @generalcolorspec ||= true_or_false(fonte && fonte.color != Fonte.default.color)
  end
  # Construction d’un des colonnes de texte
  # 
  # @note
  #   La méthode est aussi utilisée pour graver le segment qui peut
  #   rester à la fin de l’opération.
  # 
  def build_a_column_for_height(column_index, icursor, required_height)
    left = ColumnData.full_width * column_index
    bb_options = {
      height: required_height,
      width:  ColumnData.width,
    }
    pdf.font(fonte || Fonte.default)
    pdf.fill_color(fonte.color) if apply_color? 
    pdf.bounding_box([left, icursor], **bb_options) do

      #####################################
      ###     ÉCRITURE DES SEGMENTS     ###
      #####################################

      @segments = pdf.formatted_text_box(segments, **text_options.merge(overflow: :truncate, leading: pdf.line_height - pdf.height_of('Xp')))
      
      # - Pour voir encadré la colonne (si options -grid)
      if stroke?
        pdf.transparent(0.4) { 
          pdf.line_width 0.2
          pdf.stroke_color '00AA00'
          pdf.stroke_bounds 
        }
      end
    end
    pdf.fill_color(Fonte.default.color) if apply_color? 
  end

  def text_options
    @text_options ||= {
      align:          align,
      inline_format:  true
    }.merge(general_font_style)
  end

  # -- Data Methods --

  def align
    @align ||= params[:align] || :justify
  end

  def fonte
    @fonte ||= begin
      ft = params[:font]||params[:fonte]
      ft = Fonte.get_in(ft).or_default() unless ft.nil?
      ft
    end
  end

  # Le style général à appliquer à tous les paragraphes
  # 
  # @return [Hash] table à ajouter aux propriétés des text box et
  # autres. La table est vide si aucune fonte n’est définie dans les
  # propriétés du deuxième paramètre de la méthode #colonnes
  # 
  def general_font_style
    @general_font_style ||= begin
      if fonte
        {
          font_name:fonte.name, 
          font_style:fonte.style,
          font_size: fonte.size
        }
      else
        {}
      end
    end
  end

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
        params[:lines_before] || 0
      end
    end
  end

  def lines_after
    @lines_after ||= begin
      if params[:lines_after] === false
        0
      else
        params[:lines_after] || 0
      end
    end
  end

  # Nombre de lignes ajoutées par colonne (propriété @add_lines)
  # Toujours au moins égal à 0
  def added_lines
    @added_lines ||= (params[:add_lines]||0).to_i
  end
  
  # Nombre forcé de lignes
  def lines_count
    @lines_count ||= begin
      params[:lines_count] ? (params[:lines_count].to_i - 1).freeze : nil
      # Pour le moment, je mets -1 parce qu’on en ajoute une chaque
      # fois, mais quand les calculs seront bon, il faudra voir…
    end
  end

  # Hauteur forcée
  def fixed_height
    @fixed_height ||= begin
      params[:height] ? params[:height].to_pps : nil
    end
  end

  def space_before
    @space_before ||= (params[:space_before] || 0.0).freeze
  end

  def space_after
    @space_after ||= (params[:space_after] || 0.0).freeze
  end

  def segments ; @segments end
  def segments=(value)
    @segments = value
  end

  # --- Predicate Methods ---

  def stroke?
    self.class.stroke?
  end
  def self.stroke?
    :TRUE == @@strockcols ||= true_or_false(PdfBook.current.recipe.show_grid?)
  end

  private

    ##
    # Première méthode pour calculer les dimensions générales du 
    # mode multicolonnes, hors hauteur des colonnes (qui fera l’objet
    # d’une méthode spéciale, ci-dessous)
    def calc_dimensions(pdf)
      col_x = column_count.freeze
      col_w = (width - (gutter * (col_x - 1)) ) # largeur en retirant les gouttières
      col_w = (col_w / col_x).freeze

      ColumnData.count      = col_x
      ColumnData.width      = col_w
      ColumnData.full_width = col_w + gutter
      ColumnData.gutter     = gutter
      
      # Vérification, le calcul doit être bon
      pagew = pdf.bounds.width.round(2)
      surfw = (col_w * col_x + (col_x - 1) * gutter).round(2)
      pagew == surfw || begin
        raise "Mauvais calcul de la largeur des colonnes du mode multicolonnes…"
      end

      # Débuggage
      if false #true
        puts <<~EOT.bleu
          Largeur page : #{pagew}
          Nombre cols  : #{col_x}
          Gouttière    : #{gutter}
          =>
          Largeur col  : #{col_w}
          Vérification (doit être égale à largeur page)
          Check: col-width x col-count + (col-count - 1) x gutter = largeur page
          Résultat : #{surfw}
          EOT
      end

    end

    ##
    # Diviser, après l’avoir récupéré, le texte des colonnes en
    # segments (@segments)
    # 
    def divide_text_in_segments(pdf)

      # Liste pour mettre tous les textes obtenus
      text_ary = []
      # Pour le texte de debuggage
      debug_txt = []


      # Pour calculer, on met tout dans une colonne qui fait
      # la taille de colonne voulue

      # Récupération des paragraphes (en les mettant sous la forme
      # de table de texte pour Prawn)
      each_paragraph do |par|
        if par.pfbcode?
          if par.for_next_paragraph?
            # TODO : plus tard il faudra prendre les styles à 
            # appliquer, qui pourront faire varier la hauteur de la
            # colonne et notamment le leading qui est très
            # important ici
          end
          next
        end #/si pfbcode
        str = par.indented_text + "\n"
        p = []
        text_ary += pdf.text_formatter.format(str, *p)
        debug_txt << par.text if debug_txt.count < 10
      end
      # On retire le dernier item, qui contient le retour 
      # chariot
      text_ary.pop
      self.segments = text_ary

      # Pour le débuggage
      @debug_start_column = debug_txt.join('').gsub(/\n/," ¶ ")
      
    end

    # Principe de calcul simple : on fait une colonne unique qui 
    # contient tout le texte et l’on en demande la hauteur, qu’on
    # divise par le nombre de colonnes demandées.
    def calc_column_height(pdf)

      # On a besoin de la largeur de colonne
      colw = ColumnData.width

      h = nil # La valeur cherchée
      my = self

      puts "\nDonnées pour section commençant par #{segments[0][:text].inspect}"

      # Si une hauteur est fixée ou un nombre fixe de lignes, on 
      # renvoie la valeur correspondante
      if fixed_height
        h = fixed_height * column_count
      elsif lines_count
        h = lines_count * pdf.line_height * column_count 
      else
        # puts "\nNombre de segments : #{segments.count}".jaune
        # puts "Segments : #{segments}"
        fbox = ::Prawn::Text::Formatted::Box::new(segments, {
          at: [0, 10000],
          width: colw,
          inline_format: true,
          document:pdf
        }.merge(general_font_style))
        fbox.render(dry_run: true)
        h = fbox.height.freeze
        puts "height totale calculée : #{h.inspect}".bleu
        # On essaie de passer par le nombre de lignes pour fixer
        # la hauteur

      end      

    # puts "\nhauteur_total = #{hauteur_total.inspect} (LH: #{pdf.line_height}/LC: #{lines_count.inspect})".bleu
      # h = h / column_count
      # h = ((h.to_i / pdf.line_height).to_f * pdf.line_height) + pdf.line_height
      # puts "Hauteur finale par colonne (#{column_count}) : #{h}".orange
      # h = nb_lignes * pdf.line_height
      # puts "Nombre de lignes par colonne : #{h/pdf.line_height}".orange

      # En passant par le nombre de lignes
      nb_lignes = (h / pdf.line_height).floor
      puts "Nombre ajusté de lignes : #{nb_lignes}".jaune
      lines_per_column = (nb_lignes.to_f / column_count).ceil
      # On ajoute (ou on retire) éventuellement les lignes ajoutées
      # ou à retirer
      lines_per_column += added_lines
      puts "Nombre de lignes par colonne : #{lines_per_column}".bleu
      h = lines_per_column * pdf.line_height + 4.121 
                          # TODO Pourquoi ce nombre ? (ça semble être
                          # le nombre exact pour le texte arial en
                          # vert dans le manuel autoproduit)
                          # NOTE : ça doit être faux maintenant que j’ai
                          # enlevé le +1
      # puts "ascender: #{pdf.font.ascender}" pas ça
      # puts "descender: #{pdf.font.descender}" pas ça
      puts "Hauteur finale par colonne : #{h}"
      ColumnData.height = h
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
