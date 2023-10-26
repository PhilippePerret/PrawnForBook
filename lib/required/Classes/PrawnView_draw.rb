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
    line_width(0.3)
    if CLI.params[:pages]
      pfirst, plast = CLI.params[:pages].split('-').map {|n|n.to_i}
      kpages = (pfirst..plast)
    else
      kpages = :all
    end
    repeat kpages, **{dynamic:true} do
      stroke_color(88,0,58,28)
      stroke_horizontal_line(bounds.left, bounds.width, at: bounds.top)
      stroke_horizontal_line(bounds.left, bounds.width, at: bounds.bottom)
      stroke_vertical_line(bounds.left, bounds.top, at: bounds.left)
      stroke_vertical_line(bounds.left, bounds.top, at: bounds.right)
      stroke_color 0,0,0,100
    end
  end


  # Méthode appelée quand on doit dessiner la grille de base
  # dans le document.
  # 
  def draw_reference_grids

    # -- Dessin de la grille de référence sur les pages concernées --
    repeat gridded_pages, **{dynamic: true} do
      # -- Couleur et épaisseur --
      stroke_color(51, 0, 0, 3)  # bleu ciel
      fill_color(51, 0, 0, 3)    # bleu ciel
      line_width(0.1)
      # -- Changement de hauteur de ligne --
      if leadings.key?(page_number)
        data_leading = leadings[page_number]
        @line_height = data_leading[:line_height]
        spy "Line Height à #{line_height} à partir de page #{page_number.inspect}".jaune
      end

      # -- Impression de la grille de référence --
      h = bounds.top.dup
      while h > 0
        h -= line_height
        break if h < 0
        stroke_horizontal_line(-100, bounds.width + 100, at: h)
      end

      # -- Remettre les couleurs --
      # -- Noir et Blanc --
      stroke_color(0, 0, 0, 100)
      fill_color(0, 0, 0, 100)
  
    end


  end
  # /#draw_reference_grids

  # Retourne les pages concernées par l'impression de la grille de 
  # référence
  # (:all si toutes)
  # 
  # C'est important de garder cette donnée en cache, pour la
  # fabrication auto-produite du manuel d'utilisation.
  # 
  def gridded_pages
    @gridded_pages ||= begin
      return :all if CLI.params[:grid].nil?
      pfirst, plast = CLI.params[:grid].split('-').map {|n|n.to_i}
      (pfirst..plast)
    end
  end


  # @helper
  def add_cursor_position(str)
    "<font size=\"8\" name=\"#{book.second_font}\" color=\"grey\">[#{round(cursor)}]</font> #{str}"
  end

end #/class PrawnView
end #/module Prawn4book
