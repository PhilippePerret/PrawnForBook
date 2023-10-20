#
# Extension de Prawn::View qui permet de dessiner des éléments
# optionnels comme les marges, la grille de référence, etc.
# 
module Prawn4book
class PrawnView

  # Pour dessiner les marges sur toutes les pages (ou seulement
  # celles choisies)
  # Option : -display_margins
  def draw_margins
    stroke_color(88,0,58,28)
    line_width(0.3)
    if CLI.options[:grid]
      pfirst, plast = CLI.params[:grid].split('-').map {|n|n.to_i}
      kpages = (pfirst..plast)
    else
      kpages = :all
    end
    repeat kpages do
      print_margins
    end
    stroke_color 0,0,0,100
  end
  def print_margins
    stroke_horizontal_line(0, bounds.width, at: bounds.top)
    stroke_horizontal_line(0, bounds.width, at: bounds.bottom)
    stroke_vertical_line(0, bounds.top, at: bounds.left)
    stroke_vertical_line(0, bounds.top, at: bounds.right)
  end


  # @helper
  def add_cursor_position(str)
    "<font size=\"8\" name=\"#{book.second_font}\" color=\"grey\">[#{round(cursor)}]</font> #{str}"
  end

end #/class PrawnView
end #/module Prawn4book
