module Prawn4book
class PrawnView

  # Toutes les méthodes de Prawn::Document (en fait Prawn::View) qui
  # permettent de gérer la grille de référence, c'est-à-dire les 
  # lignes sur lesquelles se posent les textes.
  # 
  # Pour bien comprendre le positionnement des textes
  # -------------------------------------------------
  # Pour bien positionner un texte, on doit connaitre la ligne de
  # référence sur laquelle il doit se poser et l'ascender de la 
  # fonte. Car par défaut, la ligne de référence, qui correspond quand
  # elle correspond au curseur, est la ligne SOUS laquelle se posi-
  # tionne le texte. Il faut donc remonter ce texte pour qu'il se
  # positionne SUR la ligne de référence et non pas dessous.
  # 
  # Donc, pour positionner le texte exactement sur une ligne, il 
  # faut : connaitre la ligne, y placer le curseur, et remonter de la
  # valeur de l'ascender de la fonte.


  # La ligne courante
  # -----------------
  # (en fonction de la grille de référence)
  # Avant la version LINE 2, cette valeur était toujours calculée
  # en fonction de la position du curseur. Mais ça posait plein de
  # problèmes. Maintenant, elle est tenue à jour en fonction des
  # déplacement avec move_to_line, move_to_next_line, etc. et n’est
  # recalculée qu’en cas de problème.
  attr_accessor :current_line

  # Pour dessiner une ligne horizontale de repère de la couleur
  # +color+ donnée
  # 
  def rule(color, width = nil)
    color = color.to_html_color if color.is_a?(Symbol)
    initial_color = stroke_color.freeze
    initial_width = line_width.freeze unless width.nil?
    stroke_color(color)
    line_width(width) unless width.nil?
    stroke_horizontal_rule
    stroke_color(initial_color)
    line_width(initial_width) unless width.nil?
  end

  # Dans Prawn-for-book, chaque fois qu’on place le curseur quelque
  # part, on actualilse la ligne (de référence) courante en fonction
  # de la nouvelle position.
  # Si, exceptionnellement, la ligne ne doit pas être actualisée, on
  # met +no_update+ à true
  def move_cursor_to(value, no_update = false)
    super(value)
    update_current_line unless no_update
  end

  # Actualise la ligne courante en fonction de la position du 
  # curseur
  def update_current_line
    @current_line = ((bounds.top - cursor) / line_height).round
    # puts "Current line updatée : #{current_line}".bleu
  end

  # @return la hauteur de ligne courante 
  # 
  # @note
  #   Noter la tournure de la définition, qui permet de définir
  #   la constante LINE_HEIGHT
  # 
  def line_height
    @line_height ||= line_height=(book.recipe.line_height)
  end
  def line_height=(value)
    @line_height = value
    leadings.merge!(page_number => {line_height: value})
    Prawn4book.send(:remove_const, 'LINE_HEIGHT') if defined?(LINE_HEIGHT)
    Prawn4book.const_set('LINE_HEIGHT', value)
  end

  def leading
    @leading ||= default_leading
  end

  # Mis provisoirement pour garder en mémoire les leadings par
  # page (mais normalement, avec la version 2 LINE, on n'a plus 
  # besoin du leading)
  def leadings
    @leadings ||= {}
  end

  # Déplace le curseur sur la ligne +x+
  # 
  # @param [Integer] x Indice 1-start de la ligne
  # 
  # @return l'indice 1-start de la ligne (sert pour savoir sur quelle
  # ligne on se retrouve, par exemple, quand on utilise 
  # move_to_next_line)
  # 
  def move_to_line(x)
    x = last_line + x if x < 0
    move_cursor_to(bounds.top - (x * line_height) + ascender)
    @current_line = x
    return x
  end

  def move_to_first_line
    move_to_line(1)
  end

  # Se déplacer sur la Xe dernière ligne
  def move_to_last_line
    move_to_line(last_line)
  end

  def move_to_closest_line
    # raise "La méthode move_to_closest_line"
    prevline = bounds.top - (current_line - 1) * line_height + ascender
    currline = bounds.top - current_line * line_height + ascender
    nextline = bounds.top - (current_line + 1) * line_height + ascender

    dist_from_prev = (cursor - prevline).abs
    dist_from_curr = (cursor - currline).abs
    dist_from_next = (cursor - nextline).abs

    top =
      if dist_from_prev < [dist_from_curr,dist_from_next].min
        @current_line = current_line - 1
        prevline
      elsif dist_from_curr < dist_from_next
        currline
      else
        @current_line = current_line + 1
        nextline
      end

    # Déplacement du curseur
    move_cursor_to(top)

    return top
  end

  # @return la hauteur de la dernière ligne en bas de la page
  # en fonction de la hauteur de ligne (line_height)
  def last_line
    bounds.top.to_i / line_height
  end

  # @return [Integer] Nombre de lignes dans une page actuelle
  def line_count
    bounds.top.to_i / line_height
  end

  # Déplacement du curseur à la prochaine ligne de référence
  def move_to_next_line
    move_to_line(current_line + 1)
  end

  def move_to_prev_line
    move_to_line(current_line - 1)
  end

  # # Ligne courante
  # # --------------
  # # C'est la distance entre la position actuelle du curseur et le
  # # haut de la page (marge considérée), divisée par la hauteur de
  # # ligne. On l'arrondit à la valeur supérieure
  # def current_line
  #   debugit = true
  #   puts "Calcul current_line" if debugit
  #   # On prend la position actuelle du curseur
  #   c = cursor # position du curseur
  #   puts "  cursor = #{c.inspect}" if debugit
  #   if cursor < -line_height
  #     puts "Curseur sous zéro => page suivante" if debugit
  #     start_new_page
  #     return 1
  #   end
  #   # Si le cursor est placé plus haut que la limite de la marge
  #   # haute, on prend le bounds.top qui correspond à la valeur 
  #   # maximale en haut.
  #   if c > bounds.top
  #     c = bounds.top
  #     puts "  Rectif car trop haut. Mis à #{c.inspect}" if debugit
  #   end
  #   # On calcule la distance entre le bord haut maximum et la 
  #   # position actuelle du curseur. Ça donne 0 si on est tout en
  #   # haut.
  #   d = bounds.top - c 
  #   puts "  Distance du haut : #{d.inspect}" if debugit
  #   # On calcule à combien de lignes cette distance correspond.
  #   # Normalement, ça doit donner un compte à peu près rond, mais
  #   # on l'arrondit quand même
  #   cl = (d / line_height).round
  #   puts "  (#{d} / line_heigh(#{line_height}).round = #{cl}"  if debugit
  #   puts "  Valeur renvoyée : #{cl.inspect}"  if debugit
  #   return cl
  #   # ((bounds.to - cursor).to_f / line_height).ceil
  # end

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
    @ascender || font.ascender
  end

  def current_leading
    line_height - height_of('X')
  end

  def lines_down(x)
    move_cursor_to(x * line_height + ascender)
  end

end #/class PrawnView
end #/module Prawn4book
