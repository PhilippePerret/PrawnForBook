module Prawn4book
class PrawnView

  # - raccourci -
  def line_height
    @line_height ||= pdfbook.recipe.line_height
  end

  def leading
    @leading ||= default_leading
  end

  ##
  # Méthode qui définit le leading par défaut en fonction de :
  # - la police par défaut
  # - la taille par défaut
  # - le line_height du livre (~ grille de référence)
  # @note
  #   Idéalement, cette valeur ne doit pas être modifiée, elle doit
  #   permettre d'obtenir une grille de référence qui va aligner 
  #   tous les textes par défaut. 
  #   Lorsqu'on a besoin de changer le leading dans un texte ponctuel
  #   on doit le faire en réglant la valeur :leading des options de
  #   la méthode utilisée ('text' par exemple).
  # 
  # TODO : Il faut pouvoir modifier la grille sur plusieurs pages
  # 
  def define_default_leading(fonte, line_height)
    #
    # Ici, je tente quelque chose : je pars du principe qu'on ne
    # passe par cette méthode que lorsqu'on change la grille de
    # référence en changeant la hauteur de ligne. Donc, ici, en plus
    # du calcul, on mémorise la page courante pour savoir qu'il y a
    # eu ce changement de grille de référence. 
    # Puis, au moment de dessiner la grille de référence (option 
    # -grid) on regardera dans la définition de la grille de référence
    # dans pdf.leadings.
    # 
    self.default_leading = font2leading(fonte, line_height)
    # (re)définir les valeurs
    @leading      = default_leading
    @line_height  = line_height

    # -- Mémoriser ce leading --
    @leadings ||= {}
    @leadings.merge!(page_number => {page: page_number, fonte: fonte, line_height: line_height})
    spy "default_leading mis à #{self.default_leading.inspect}".bleu
  end

  ##
  # @input  Reçoit la fonte concernée (*) et
  #         Reçoit la hauteur de ligne voulue
  # 
  # @output Return le leading à appliquer par rapport à la police et
  #         la taille voulue.
  # 
  # Cette méthode est utilisée non seulement en tout début de 
  # construction pour pouvoir connaitre le leading par défaut à 
  # appliquer au livre, mais aussi chaque fois qu'on change de fonte
  # ou de taille, pour connaitre le leading à appliquer localement.
  # 
  # @param [Prawn4book::Fonte] La fonte à prendre en considération
  # 
  #   Maintenant, on passe forcément par une instance Fonte, pour
  #   obliger à utiliser cette classe très pratique.
  # 
  def font2leading(fonte, hline)
    fonte.leading(self, hline)
  end


  ##
  # Quel que soit la position actuelle du curseur, on le place sur la
  # prochaine ligne de référence (grille de référence pour aligner
  # toutes les lignes de texte)
  # 
  def move_cursor_to_next_reference_line
    line_ref = calc_ref_line
    spy "line_ref pour prochaine écriture du curseur : #{line_ref.inspect}".bleu
    move_cursor_to(line_ref)
    if cursor < 0
      spy "Nécessité de passer à la page suivante (curseur trop bas)".orange
      start_new_page 
      move_cursor_to_next_reference_line
    end
  end

  ##
  # Calcul et renvoie la ligne de référence en fonction de la 
  # position actuelle du curseur.
  # 
  def calc_ref_line

    cur_dist_from_top = bounds.top - cursor # la bonne
    cur_num_ref_line  = (cur_dist_from_top / line_height).floor
    new_num_ref_line  = cur_num_ref_line + 1
    new_dist_from_top = new_num_ref_line * line_height
    absolute_line_ref = bounds.top - new_dist_from_top
    line_ref          = absolute_line_ref + font.ascender

    return line_ref    
  end

  # Méthode appelée quand on doit dessiner la grille de base
  # dans le document.
  # 
  def draw_reference_grids
    # 
    # Définit le leading à appliquer en fonction de la hauteur de
    # ligne à obtenir, par rapport à la fonte courante.
    # 
    # define_default_leading(Fonte.default, line_height)
    # 
    # Définition de la fonte à utiliser
    # 
    # font(Fonte.default)
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
    repeat kpages, **{dynamic: true} do
      #
      # Si la grille de référence change à cette page, il faut la
      # changer
      # 
      if @leadings.key?(page_number)
        data_leading = @leadings[page_number]
        @line_height = data_leading[:line_height]
        spy "Line Height à #{line_height} à partir de page #{page_number.inspect}".jaune
      end
      # 
      # Imprimer la grille de référence
      # 
      print_reference_grid
    end
  end

  # Pour dessiner la grille de référence sur toutes les pages ou 
  # seulement les pages choisies.
  # Option : -display_grid
  def print_reference_grid
    # 
    # Aspect des lignes (bleues et fines)
    # 
    stroke_color 51, 0, 0, 3  # bleu ciel
    fill_color 51, 0, 0, 3    # bleu ciel
    line_width(0.1)
    #
    # On commence toujours en haut
    # 
    h = bounds.top.dup #
    while h > 0
      # 
      # Prochaine position (définition de l'écartement entre les lignes)
      # 
      h -= line_height
      # puts "Position : #{h.inspect}"
      #
      # Si on atteint le bas, on s'arrête
      # 
      break if h < 0
      # 
      # Écriture de la position top
      # 
      float {
        move_cursor_to(h + 4)
        # spy "[Grille référence] Cursor à #{cursor.inspect}".bleu_clair
        span(40, position: bounds.left - 20) do
          font pdfbook.second_font, size:6
          text round(h + 20).to_s
        end
      }
      # stroke_horizontal_line(0, bounds.width, at: h)
      stroke_horizontal_line(-100, bounds.width + 100, at: h)
    end
    # 
    # On remet la couleur initiale pour retourner en noir
    # 
    stroke_color  0, 0, 0, 100
    fill_color    0, 0, 0, 100
  end

  def default_font_name
    @default_font_name ||= default_font_and_style.split('/')[0]
  end

  def default_font_style
    @default_font_style ||= default_font_and_style.split('/')[1].to_sym
  end

  def default_font_and_style
    @default_font_and_style ||= pdfbook.recipe.default_font_and_style
  end

  def default_font_size
    @default_font_size ||= pdfbook.recipe.default_font_size
    # @default_font_size ||= Metric.default_font_size
  end


end #/class PrawnView
end #/module Prawn4book
