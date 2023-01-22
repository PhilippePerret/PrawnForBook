require_relative 'headfooter' # class abstraite

module Prawn4book
class HeadersFooters
class Footer < Headfooter

  def header? ; false end
  def footer? ; true  end

  ##
  # @return [Integer] Le nombre de points post-script pour positionner
  # le header en fonction de la taille du livre.
  # 
  # @api public
  def top
    @top ||= (pdf.bounds.bottom - (6 + disposition.footer_vadjust)).round
  end

end #/class Footer
end #/class HeadersFooters
end #/module Prawn4book
