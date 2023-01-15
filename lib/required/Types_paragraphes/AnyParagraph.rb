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

  def titre?    ; false end
  def pfbcode?  ; false end

  # Sera mis à true pour les paragraphes qui ne doivent pas être
  # imprimés, par exemple les paragraphes qui définissent des 
  # propriétés pour les paragraphes suivants.
  def not_printed?
    @isnotprinted === true
  end

  def pfbcode
    @pfbcode ||= data[:pfbcode]
  end

REG_HELPER_METHOD = /^([a-zA-Z0-9_]+)(\(.+?\))?$/

REG_REFERENCE       = /\(\( \((.+?)\) \)\)/
REG_APPEL_REFERENCE = /\(\( +\->\((.+?)\) +\)\)/

end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
