require_relative 'headfooter' # class abstraite

module Prawn4book
class HeadersFooters
class Header < Headfooter

  def header? ; true  end
  def footer? ; false end

  RECTIF = 12

  ##
  # @return [Integer] Le nombre de points post-script pour positionner
  # le header en fonction de la taille du livre.
  # 
  # @note
  #   La valeur ajoutée (RECTIF) est
  #   mise "à la main" pour que par défaut l'entête soit bien 
  #   placé.
  # 
  # @api public
  def top
    @top ||= (pdf.bounds.top + height + RECTIF - disposition.header_vadjust).round
  end

end #/class Header
end #/class HeadersFooters
end #/module Prawn4book
