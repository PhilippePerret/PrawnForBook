module Prawn4book
class PrawnView


  # Méthode pour se déplacer sur la ligne suivante
  def next_baseline(xlines = 1)
    move_up(4)
    c = cursor.freeze # p.e. 456
    d = c.to_i / line_height # p.e. 456 / 12 = 38
    newc = (d - xlines) * line_height # p.e. (38 + 1) * 12 = 468
    move_cursor_to(newc)
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

  def default_font
    @default_font ||= config[:default_font]||DEFAULT_FONT
  end

  def default_font_size
    @default_font_size ||= config[:default_font_size]||DEFAULT_SIZE_FONT
  end

  def line_height
    @line_height ||= config[:line_height]||DEFAULT_LINE_HEIGHT
  end

end #/class PrawnView
end #/module Prawn4book
