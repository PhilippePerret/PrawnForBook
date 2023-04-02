require 'prawn'
module Prawn
  class RectifiedDocument < Document

    ##
    # Ré-écriture de la méthode :move_cursor_to pour qu'elle se
    # synchronise avec l'utilisation de :at dans un draw_text par
    # exemple.
    # 
    # Comportement original
    # ---------------------
    # À l'origine (Prawn::Document), quand on utilise le code :
    #   <code>
    #   move_cursor_to(12)
    #   text "Mon texte"
    #   </code>
    # … et
    #   <code>
    #   draw_text "Mon texte", at: [0,12]
    #   </code
    # … on obtient un premier texte situé à [0.0, 3.384]  # text
    #            et un second texte situé à [0.0, 12.0]   # draw_text
    # 
    # La ré-écriture de cette méthode permet d'obtenir dans tous les
    # cas [0.0, 12.0]
    # 
    def move_cursor_to(new_y)
      # self.y = new_y + font.ascender + bounds.absolute_bottom
      # Original is : 
      self.y = new_y + bounds.absolute_bottom
    end
  end #/class MyDocument
end #/module Prawn
