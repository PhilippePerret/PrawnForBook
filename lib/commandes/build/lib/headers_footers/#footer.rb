# require_relative 'headfooter' # class abstraite

# module Prawn4book
# class HeadersFooters
# class Footer < Headfooter

#   def header? ; false end
#   def footer? ; true  end

#   RECTIF = -10

#   ##
#   # @return [Integer] Le nombre de points post-script pour positionner
#   # le header en fonction de la taille du livre.
#   # 
#   # @note
#   #   La valeur ajoutée (RECTIF) est 
#   #   ajoutée à la louche pour que par défaut le numéro de page
#   #   soit bien affiché.
#   # 
#   # @api public
#   def top
#     @top ||= (pdf.bounds.bottom + RECTIF - (6 + disposition.footer_vadjust)).round
#   end

# end #/class Footer
# end #/class HeadersFooters
# end #/module Prawn4book
