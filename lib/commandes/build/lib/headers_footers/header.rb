require_relative 'headfooter' # class abstraite

module Prawn4book
class HeadersFooters
class Header < Headfooter

  def header? ; true  end
  def footer? ; false end

end #/class Header
end #/class HeadersFooters
end #/module Prawn4book
