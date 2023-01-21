require_relative 'headfooter' # class abstraite

module Prawn4book
class HeadersFooters
class Header < Headfooter

  def header? ; true  end
  def footer? ; false end

  ##
  # @return [Integer] Le nombre de points post-script pour positionner
  # le header en fonction de la taille du livre.
  # 
  # @api public
  def top
    @top ||= (pdf.bounds.top + 20).round # TODO à régler
  end

end #/class Header
end #/class HeadersFooters
end #/module Prawn4book
