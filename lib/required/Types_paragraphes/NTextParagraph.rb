require_relative 'AnyParagraph'
module Prawn4book
class PdfBook
class NTextParagraph < AnyParagraph

  # # @prop Première et dernière page du paragraphe
  # attr_accessor :first_page
  # attr_accessor :last_page
  # attr_accessor :page_numero

  def self.get_next_numero
    @@last_numero ||= 0
    @@last_numero += 1
  end

  attr_reader :data
  attr_reader :numero
  alias :number :numero

  def initialize(pdfbook,data)
    super(pdfbook)
    @data   = data.merge!(type: 'paragraph')
    @numero = self.class.get_next_numero
  end

  # --- Predicate Methods ---

  def paragraph?; true end

  # --- Data Methods ---

  def text  ; @text ||= data[:text]||data[:raw_line] end
  def text=(value)
    @text = value
  end

end #/class NTextParagraph
end #/class PdfBook
end #/module Prawn4book
