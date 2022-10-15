module Prawn4book
class PrawnView

  # @prop La table de la grille de référence
  # Elle permet d'obtenir en un instance (sans calcul) la 
  # ligne de référence la plus proche d'une position.
  # Par exemple, si le line_height (qui détermine la hauteur de
  # ligne absolu) est de 12, que le document commence (sa première
  # ligne) à 600, il y a donc trois lignes à :
  #   600, 588 et 576
  # La table indique que les lignes de 600 à 594 doivent se 
  # positionner à 600, que les curseurs de 
  #   594 (588 + 6) à 582 (588 - 6) doivent se positionner à 588,
  # etc.
  def table_reference_grid
    @table_reference_grid ||= begin
      lh = line_height.dup              # p.e. 13
      moitielh = round(lh.to_f / 2, 1)  # p.e. 6.5
      tp = bounds.top.to_i
      puts "line_height: #{lh}"
      puts "top page = #{tp.inspect}"
      tbl       = {}
      h         = tp.dup
      ilineref  = -1
      lineref   = tp
      while h > 0
        ilineref += 1
        lineref  = tp - (ilineref * lh)
        linerefsuiv = tp - ((ilineref + 1) * lh)
        linerefsuiv = nil if linerefsuiv < 0
        tbl.merge!(h.to_i => lineref)
        (0..lh).each do |n|
          if n < moitielh
            tbl.merge!( (h - n).to_i => lineref)
          else
            tbl.merge!( (h - n).to_i => linerefsuiv)
          end
        end
        h -= lh
      end
      # puts "table de référence : #{tbl.pretty_inspect}"
      tbl
    end
  end

  # @param {Cursor ?} curseur (souvent courant)
  def cursor_to_refgrid_line(cur, nombre_de_lignes = nil)
    cur_on_grid = table_reference_grid[cur.to_i]
    if cur_on_grid.nil?
      puts "cur_on_grid est nil…".rouge
      puts "Avec cur.to_i = #{cur.to_i.inspect}".rouge
      puts "Table : #{table_reference_grid}".rouge
      nombre_de_lignes ||= 1
      return cur + (nombre_de_lignes - 1) * line_height
    end
    if not(nombre_de_lignes.nil?)
      puts "line_height = #{line_height.inspect} / nombre_de_lignes:#{nombre_de_lignes} / cur_on_grid:#{cur_on_grid}"
      cur_on_grid += (nombre_de_lignes - 1) * line_height
    elsif cur_on_grid < cur
      cur_on_grid += line_height
    end
    puts "cur: #{round(cur)} / cur_on_grid: #{cur_on_grid}"
    return cur_on_grid
  end

  ##
  # Méthode qui définit le leading par défaut en fonction de :
  # - la police par défaut
  # - la taille par défaut
  # - le line_height du livre (~ grille de référence)
  # 
  def define_default_leading
    self.default_leading = font2leading(
      default_font, default_font_size, line_height
    )
    puts "\ndefault_leading = #{self.default_leading.inspect}".bleu
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
    @line_height ||= pdfbook.recette[:line_height]||DEFAULT_LINE_HEIGHT
  end

end #/class PrawnView
end #/module Prawn4book
