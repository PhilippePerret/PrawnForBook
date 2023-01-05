module Prawn4book
class PrawnView

  # Pour placer le curseur sur la ligne de référence la plus
  # proche de la hauteur +hauteur+
  # 
  def move_cursor_to_lineref(hauteur)
    move_cursor_to(hauteur)
    move_cursor_to(line_reference.dup)
  end

  # @return la hauteur de la ligne de référence au cursor
  def line_reference
    lr_inf = (cursor.to_i / line_height) * line_height
    lr_sup = lr_inf + line_height
    lr = 
      if lr_sup - cursor > cursor - lr_inf
        lr_inf
      else
        lr_sup
      end
    lr += ecart_line_reference
    # puts "Cursor: #{round(cursor)} => Line reference: #{lr}"
    lr - line_height
  end

  # @prop Différence entre la ligne supérieure et la première
  # ligne de référence. Cette valeur permet de calculer la position
  # exacte de la ligne de référence par rapport à la page, entendu 
  # que cette ligne de référence est un multiple de la hauteur de
  # ligne (line_height) auquel on ajoute cet écart (cf. la méthode
  # @line_reference ci-dessus).
  def ecart_line_reference
    @ecart_line_reference ||= begin
      tp = bounds.top
      lrabs = (tp.to_i / line_height) * line_height
      tp - lrabs
    end
  end

  # Avec l'option -g/--grid, on peut afficher une grille de référence
  # sur toutes les pages
  # TODO: Pouvoir ne la dessiner que sur certaines pages avec :
  #     --grid=4-12
  def print_reference_grid
    while h > 0
      float {
        move_cursor_to(h + 4)
        span(20, position: bounds.left - 20) do
          font pdfbook.second_font, size:7
          text round(h).to_s
        end
      }
      stroke_horizontal_line(0, bounds.width, at: h)
      h -= line_height
    end
  end


  ##
  # Méthode qui définit le leading par défaut en fonction de :
  # - la police par défaut
  # - la taille par défaut
  # - le line_height du livre (~ grille de référence)
  # 
  def define_default_leading
    self.default_leading = font2leading(
      default_font_name, default_font_size, line_height
    )
  end

  ##
  # @input  Reçoit la fonte concernée (*) et
  #         Reçoit la hauteur de ligne voulue
  # @output Return le leading à appliquer
  # 
  # Note : ne pas oublier d'indiquer la fonte en sortant de cette
  # méthode jusqu'à (TODO) je sache remettre l'ancienne fonte en la
  # prenant à l'entrée dans la méthode
  def font2leading(fonte, size, hline, options = {})
    lead  = 0.0
    font fonte, size:size
    h = height_of("A", leading:lead, size: size)
    if (h - hline).abs > (h - 2*hline).abs
      options.merge!(:greater => true) unless options.key?(:greater)
    end
    # puts "h = #{h}"
    if h > hline && not(options[:greater] == true)
      while h > hline
        h = height_of("A", leading: lead -= 0.01, size: size)
      end
    else
      while h % hline > 0.01
        h = height_of("A", leading: lead += 0.01, size: size)
      end
    end
    return lead
  end

  def default_font_name
    @default_font_name ||= config[:default_font_name]
  end

  def default_font_size
    @default_font_size ||= config[:default_font_size]
  end

  def default_font_style
    @default_font_style ||= config[:default_font_style]
  end

  def line_height
    @line_height ||= pdfbook.recette[:line_height]||DEFAULT_LINE_HEIGHT
  end

end #/class PrawnView
end #/module Prawn4book
