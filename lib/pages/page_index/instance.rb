module Prawn4book
class Pages
class PageIndex

  attr_reader :table_index

  def initialize(*args)
    super
    @table_index = {}
  end

  # - raccourcis -
  alias :pdfbook :thing

end #/class PageIndex
end #/class Pages
end #/module Prawn4book
