module Prawn4book
class PrawnView


  ##
  # Quel que soit la position actuel du curseur, on le place sur la
  # prochaine ligne de référence (grille de référence pour aligner
  # toutes les lignes de texte)
  # 
  def move_cursor_to_next_reference_line
    line_ref = calc_ref_line
    spy "line_ref pour prochaine écriture du curseur : #{line_ref.inspect}".bleu
    move_cursor_to(line_ref)
  end

  ##
  # Calcul et renvoie la ligne de référence en fonction de la 
  # position actuelle du curseur.
  # 
  def calc_ref_line

    cur_dist_from_top = bounds.top - cursor
    cur_num_ref_line  = (cur_dist_from_top / line_height).floor
    new_num_ref_line  = cur_num_ref_line + 1
    new_dist_from_top = new_num_ref_line * line_height
    absolute_line_ref = bounds.top - new_dist_from_top
    line_ref          = absolute_line_ref + font.ascender

    msg_spy = <<~TEXT
    [calcul line ref]
      cursor départ : #{cursor.inspect}
      Distance depuis le haut efficace = #{cur_dist_from_top}
      Indice ligne référence courante = #{cur_num_ref_line}
      (line_height = #{line_height})
      Indice nouvelle ligne référence = #{new_num_ref_line}
      Nouvelle distance depuis le haut efficace = #{new_dist_from_top}
      Absolute Line Ref (sans la fonte) = #{absolute_line_ref}
      line_ref = #{line_ref}

      font : #{font.inspect}
      ascender : #{font.ascender}
      descender: #{font.descender}
    [/calcul line ref]
    TEXT
    spy msg_spy.bleu

    return line_ref    
  end

  # Méthode appelée quand on doit dessiner la grille de base
  # dans le document.
  def draw_reference_grids
    define_default_leading # utile ?
    font = font(default_font_name, size: default_font_size)
    # 
    # Aspect des lignes (bleues et fines)
    # 
    stroke_color 51, 0, 0, 3  # bleu ciel
    fill_color 51, 0, 0, 3    # bleu ciel
    line_width(0.1)
    # 
    # La grille peut n'être inscrite que sur quelques pages, 
    # définies par le paramètre 'grid=start-end' en ligne de commande
    # 
    if CLI.params[:grid]
      pfirst, plast = CLI.params[:grid].split('-').map {|n|n.to_i}
      kpages = (pfirst..plast)
    else
      kpages = :all
    end
    # 
    # Boucle sur toutes les pages voulues pour écrire la grille de
    # référence.
    # 
    repeat kpages do
      print_reference_grid
    end
    # 
    # On remet la couleur initiale pour retourner en noir
    # 
    stroke_color  0, 0, 0, 100
    fill_color    0, 0, 0, 100
  end

  # Pour dessiner la grille de référence sur toutes les pages ou 
  # seulement les pages choisies.
  # Option : -display_grid
  def print_reference_grid
    #
    # On commence toujours en haut
    # 
    h = bounds.top.dup # - line_height
    while h > 0
      # 
      # Prochaine position (définition de l'écartement entre les lignes)
      # 
      h -= line_height
      break if h < 0
      # 
      # Écriture de la position top
      # 
      float {
        move_cursor_to(h + 4)
        spy "[Grille référence] Cursor à #{cursor.inspect}".bleu_clair
        span(40, position: bounds.left - 20) do
          font pdfbook.second_font, size:6
          text round(h + 20).to_s
        end
      }
      stroke_horizontal_line(0, bounds.width, at: h)
    end
  end

  # # Pour placer le curseur sur la ligne de référence la plus
  # # proche de la hauteur +hauteur+
  # # 
  # def move_cursor_to_lineref(hauteur)
  #   move_cursor_to(hauteur)
  #   move_cursor_to(line_reference.dup)
  # end

  # # @return la hauteur de la ligne de référence au cursor
  # def line_reference
  #   lr_inf = (cursor.to_i / line_height) * line_height
  #   lr_sup = lr_inf + line_height
  #   lr = 
  #     if lr_sup - cursor > cursor - lr_inf
  #       lr_inf
  #     else
  #       lr_sup
  #     end
  #   lr += ecart_line_reference
  #   # puts "Cursor: #{round(cursor)} => Line reference: #{lr}"
  #   lr - line_height
  # end

  # # @prop Différence entre la ligne supérieure et la première
  # # ligne de référence. Cette valeur permet de calculer la position
  # # exacte de la ligne de référence par rapport à la page, entendu 
  # # que cette ligne de référence est un multiple de la hauteur de
  # # ligne (line_height) auquel on ajoute cet écart (cf. la méthode
  # # @line_reference ci-dessus).
  # def ecart_line_reference
  #   @ecart_line_reference ||= begin
  #     tp = bounds.top
  #     lrabs = (tp.to_i / line_height) * line_height
  #     tp - lrabs
  #   end
  # end

  # # Avec l'option -g/--grid, on peut afficher une grille de référence
  # # sur toutes les pages
  # # TODO: Pouvoir ne la dessiner que sur certaines pages avec :
  # #     --grid=4-12
  # def print_reference_grid
  #   while h > 0
  #     float {
  #       move_cursor_to(h + 4)
  #       span(20, position: bounds.left - 20) do
  #         font pdfbook.second_font, size:7
  #         text round(h).to_s
  #       end
  #     }
  #     stroke_horizontal_line(0, bounds.width, at: h)
  #     h -= line_height
  #   end
  # end


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
    # spy "Leading = #{leading.inspect}".bleu
    font fonte, size:size
    h = height_of("A", leading:leading, size: size)
    if (h - hline).abs > (h - 2*hline).abs
      options.merge!(:greater => true) unless options.key?(:greater)
    end
    incleading = leading.dup
    if h > hline && not(options[:greater] == true)
      while h > hline
        h = height_of("A", leading: incleading -= 0.01, size: size)
      end
    else
      while h % hline > 0.01
        h = height_of("A", leading: incleading += 0.01, size: size)
      end
    end
    return incleading
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

  # - shortcut -
  def leading     ; pdfbook.recette.leading       end
  def line_height ; pdfbook.recette.line_height   end

end #/class PrawnView
end #/module Prawn4book
