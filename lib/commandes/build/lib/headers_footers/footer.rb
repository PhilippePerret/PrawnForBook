require_relative 'headfooter' # class abstraite

module Prawn4book
class HeadersFooters
class Footer < Headfooter

  def header? ; false end
  def footer? ; true  end

end #/class Footer
end #/class HeadersFooters
end #/module Prawn4book
