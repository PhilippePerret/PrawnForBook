module Prawn4book
class PrawnView

  # - raccourci -
  def line_height
    @line_height ||= book.recipe.line_height
  end

  def leading
    @leading ||= default_leading
  end


  # Déplace le curseur sur la ligne +x+
  # 
  # @param [Integer] x Indice 1-start de la ligne
  # @return l'indice 1-start de la ligne
  # 
  def move_to_line(x)
    # Top ligne
    # ---------
    next_line_top  = (x - 1) * line_height
    # Déplacement du curseur
    move_cursor_to(bounds.height - next_line_top + ascender)
    return x
  end

  def move_to_first_line
    move_to_line(1)
  end

  # Déplacement du curseur à la prochaine ligne de référence
  def move_to_next_line
    # Ligne courante
    # --------------
    # C'est la distance entre la position actuelle du curseur et le
    # haut de la page (marge considérée), divisée par la hauteur de
    # ligne. On l'arrondit à la valeur plancher
    current_line = ((bounds.height - cursor).to_f / line_height).ceil

    move_to_line(current_line + 1)
  end

  # @ascender
  # 
  # Il permet de savoir de combien on doit remonter la ligne pour
  # qu'en fonction de sa taille, elle soit posée sur la ligne de
  # référence.
  # 
  # Sa valeur est changée dès que la fonte est modifiée pour le
  # document (avec la méthode #font refactorisée pour Prawn-for-book.
  # 
  def ascender
    @ascender
  end

  alias :real_font :font
  # Définit la fonte ou récupère la fonte courante
  def font(font_name = nil, **font_options)
    return @current_font if font_name.nil?
    case font_name
    when String
      font_name     = font_name
      font_options  = font_options
    when Prawn4book::Fonte
      font_options  = font_name.options.merge(font_options)
      font_name     = font_name.name
    end
    @current_font = real_font(font_name, **font_options)
    @ascender = @current_font.ascender
  end

  def current_leading
    line_height - height_of('X')
  end

  def lines_down(x)
    move_cursor_to(x * line_height + ascender)
  end



  # ##
  # # Méthode qui définit le leading par défaut en fonction de :
  # # - la police par défaut
  # # - la taille par défaut
  # # - le line_height du livre (~ grille de référence)
  # # @note
  # #   Idéalement, cette valeur ne doit pas être modifiée, elle doit
  # #   permettre d'obtenir une grille de référence qui va aligner 
  # #   tous les textes par défaut. 
  # #   Lorsqu'on a besoin de changer le leading dans un texte ponctuel
  # #   on doit le faire en réglant la valeur :leading des options de
  # #   la méthode utilisée ('text' par exemple).
  # # 
  # # 
  # def define_default_leading(fonte, line_height)
  #   #
  #   # Ici, je tente quelque chose : je pars du principe qu'on ne
  #   # passe par cette méthode que lorsqu'on change la grille de
  #   # référence en changeant la hauteur de ligne. Donc, ici, en plus
  #   # du calcul, on mémorise la page courante pour savoir qu'il y a
  #   # eu ce changement de grille de référence. 
  #   # Puis, au moment de dessiner la grille de référence (option 
  #   # -grid) on regardera dans la définition de la grille de référence
  #   # dans pdf.leadings.
  #   # 
  #   self.default_leading = calc_leading_for(fonte, line_height)
  #   # (re)définir les valeurs
  #   @leading      = default_leading
  #   @line_height  = line_height

  #   # -- Mémoriser ce leading --
  #   @leadings ||= {}
  #   @leadings.merge!(page_number => {page: page_number, fonte: fonte, line_height: line_height})
  #   spy "default_leading mis à #{self.default_leading.inspect}".bleu
  # end

  # ##
  # # @input  Reçoit la fonte concernée (*) et
  # #         Reçoit la hauteur de ligne voulue
  # # 
  # # @output Return le leading à appliquer par rapport à la police et
  # #         la taille voulue.
  # # 
  # # Cette méthode est utilisée non seulement en tout début de 
  # # construction pour pouvoir connaitre le leading par défaut à 
  # # appliquer au livre, mais aussi chaque fois qu'on change de fonte
  # # ou de taille, pour connaitre le leading à appliquer localement.
  # # 
  # # @param [Prawn4book::Fonte] La fonte à prendre en considération
  # # 
  # #   Maintenant, on passe forcément par une instance Fonte, pour
  # #   obliger à utiliser cette classe très pratique.
  # # 
  # def font2leading(fonte, hline)
  #   fonte.leading(self, hline)
  # end


  # ##
  # # Quel que soit la position actuelle du curseur, on le place sur la
  # # prochaine ligne de référence (grille de référence pour aligner
  # # toutes les lignes de texte)
  # # 
  # def move_to_next_line
  #   line_ref = calc_ref_line
  #   spy "line_ref pour prochaine écriture du curseur : #{line_ref.inspect}".bleu
  #   move_cursor_to(line_ref)
  #   if cursor < 0
  #     spy "Nécessité de passer à la page suivante (curseur trop bas)".orange
  #     start_new_page 
  #     move_to_next_line
  #   end
  # end

  # ##
  # # Calcul et renvoie la ligne de référence en fonction de la 
  # # position actuelle du curseur.
  # # 
  # def calc_ref_line

  #   cur_dist_from_top = bounds.top - cursor # la bonne
  #   cur_num_ref_line  = (cur_dist_from_top / line_height).floor
  #   new_num_ref_line  = cur_num_ref_line + 1
  #   new_dist_from_top = new_num_ref_line * line_height
  #   absolute_line_ref = bounds.top - new_dist_from_top
  #   line_ref          = absolute_line_ref + font.ascender

  #   return line_ref    
  # end


end #/class PrawnView
end #/module Prawn4book
