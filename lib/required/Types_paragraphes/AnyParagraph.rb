module Prawn4book
class PdfBook
class AnyParagraph

  # @prop Première et dernière page du paragraphe
  attr_accessor :first_page
  attr_accessor :last_page
  attr_accessor :page_numero

  # La méthode générale pour formater le texte +str+
  # Note : on pourrait aussi prendre self.text, mais ça permettra
  # d'envoyer un texte déjà travaillé
  def formated_text(pdf, str = nil)
    str ||= text
    str.gsub(/#\{(.+?)\}/) do
      code = $1.freeze
      eval(code)
    end
  end

  def titre?; false end

end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
