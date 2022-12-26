=begin
  
  Méthodes communes pour la construction

=end
module Prawn4book
class SpecialPage

  # [Prawn4book::PdfBook|Prawn4book::Collection] La chose éditée (livre ou collection)
  attr_reader :thing

  ##
  # Instanciate la page
  # 
  # @param [Book|Collection] thing Le livre ou la collection courante
  # 
  def initialize(thing)
    @thing = thing  
  end

end #/class SpecialPage
end #/module Prawn4book
