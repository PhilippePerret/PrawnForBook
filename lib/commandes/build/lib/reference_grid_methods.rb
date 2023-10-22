module Prawn4book
class PrawnView

  # - raccourci -
  def line_height
    @line_height ||= book.recipe.line_height
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
  # @return l'indice 1-start de la ligne
  # 
  def move_to_line(x)
    return move_to_last_line(x) if x < 0
    next_line_top  = x * line_height
    move_cursor_to(bounds.height - next_line_top + ascender)
    return x
  end

  def move_to_first_line
    move_to_line(1)
  end

  # Se déplacer sur la Xe dernière ligne
  def move_to_last_line(x)
    move_cursor_to(last_line + x.abs * line_height)
  end

  def move_to_closest_line
    prevline = bounds.height - current_line * line_height
    nextline = bounds.height - (current_line + 1) * line_height
    if cursor - prevline > nextline - cursor
      move_to_line(current_line)
    else
      move_to_line(current_line + 1)
    end
  end

  # @return la hauteur de la dernière ligne en bas de la page
  # en fonction de la hauteur de ligne (line_height)
  def last_line
    bounds.height.to_i / line_height
  end

  # @return [Integer] Nombre de lignes dans une page actuelle
  def line_count
    bounds.height.to_i / line_height
  end

  # Déplacement du curseur à la prochaine ligne de référence
  def move_to_next_line
    move_to_line(current_line + 1)
  end

  def move_to_prev_line
    move_to_line(current_line - 1)
  end

  # Ligne courante
  # --------------
  # C'est la distance entre la position actuelle du curseur et le
  # haut de la page (marge considérée), divisée par la hauteur de
  # ligne. On l'arrondit à la valeur supérieure
  def current_line
    ((bounds.height - cursor).to_f / line_height).ceil
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
    @ascender || font.ascender
  end

  # alias :real_font :font
  # # Définit la fonte ou récupère la fonte courante
  # def font(font_name = nil, **font_options)
  #   return @current_font if font_name.nil?
  #   case font_name
  #   when String
  #     font_name     = font_name
  #     font_options  = font_options
  #   when Prawn4book::Fonte
  #     font_options  = font_name.options.merge(font_options)
  #     font_name     = font_name.name
  #   end
  #   @current_font = real_font(font_name, **font_options)
  #   @ascender = @current_font.ascender
  # end

  def current_leading
    line_height - height_of('X')
  end

  def lines_down(x)
    move_cursor_to(x * line_height + ascender)
  end

end #/class PrawnView
end #/module Prawn4book
