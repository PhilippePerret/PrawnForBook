module Prawn4book
class Pages
class PageIndex

  attr_reader :table_index

  def initialize(*args)
    super
    @table_index = {}
  end

  # = main =
  #
  # Méthode principale permettant de définir la page
  # 
  def define
    super
  end

  #
  # Ci-dessous les méthodes spéciales pour définir la page
  # @note
  #   Les principales méthodes se trouvent dans la classe mère
  # 

end #/class PageIndex
end #/class Pages
end #/module Prawn4book
