module Prawn4book
class PdfBook
class AnyParagraph

  attr_reader :pdfbook

  # @prop Première et dernière page du paragraphe
  attr_accessor :first_page
  attr_accessor :last_page
  attr_accessor :page_numero

  def initialize(pdfbook)
    @pdfbook = pdfbook
  end

  # La méthode générale pour formater le texte +str+
  # Note : on pourrait aussi prendre self.text, mais ça permettra
  # d'envoyer un texte déjà travaillé
  def formated_text(pdf, str = nil)
    str ||= text
    # 
    # Traitement des codes ruby 
    # 
    str = str.gsub(/#\{(.+?)\}/) do
      code = $1.freeze
      methode = nil
      if code.match?(REG_HELPER_METHOD)
        # C'est peut-être une méthode d'helpers qui est appelée
        methode = code.match(REG_HELPER_METHOD)[1].to_sym
      end
      if methode && pdfbook.pdfhelpers && pdfbook.pdfhelpers.respond_to?(methode)
        # 
        # Une méthode helper propre au livre ou à la collection
        # 
        pdfbook.pdfhelpers.instance_eval(code)
      else
        #
        # Un code général
        # 
        eval(code)
      end
    end

    # 
    # Traitement des mots indexé
    # 
    if str.match?('index:') || str.match?('index\(')
      str = str.gsub(/index:(.+?)(\b)/) do
        dmot = {mot: $1.freeze, page: first_page, paragraph:numero}
        pdfbook.page_index.add(dmot)
        dmot[:mot] + $2
      end
      str = str.gsub(/index\((.+?)\)/) do
        mot, canon = $1.freeze.split('|')
        dmot = {mot: mot, canon: canon, page: first_page, paragraph: numero}
        pdfbook.page_index.add(dmot)
        dmot[:mot]
      end
    end

    return str
  end #/formated_text

  def titre?; false end

REG_HELPER_METHOD = /^([a-zA-Z0-9_]+)(\(.+?\))?$/
end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
