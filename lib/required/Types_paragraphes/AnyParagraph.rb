module Prawn4book
class PdfBook
class AnyParagraph

  # @prop Première et dernière page du paragraphe
  attr_accessor :first_page
  attr_accessor :last_page
  attr_accessor :page_numero

  def titre?; false end

end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
