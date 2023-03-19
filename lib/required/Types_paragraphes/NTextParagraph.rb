require_relative 'AnyParagraph'
module Prawn4book
class PdfBook
class NTextParagraph < AnyParagraph

  @@last_numero = 0

  def self.reset
    @@last_numero = 0
  end

  def self.init_first_turn
    reset
  end
  def self.init_second_turn
    reset
  end

  def self.get_next_numero
    @@last_numero += 1
  end

  attr_reader :data
  attr_reader :numero
  alias :number :numero

  # Liste des balises de style de paragraphe
  attr_accessor :styled_tags

  def initialize(pdfbook,data)
    super(pdfbook)
    @data   = data.merge!(type: 'paragraph')
    @numero = self.class.get_next_numero
    prepare_text # pour obtenir tout de suite les balises initiales
  end

  # --- Predicate Methods ---

  def paragraph?; true end
  def sometext? ; true end # seulement ceux qui contiennent du texte

  # --- Data Methods ---

  REG_LEADING_TAG   = /^[a-z_0-9]+::/.freeze
  REG_LEADING_TAGS  = /^((?:(?:[a-z_0-9]+)::){1,6})(.+)$/.freeze
  def text
    @text 
  end

  def text=(value)
    @text = value
  end

  def prepare_text
    tx = data[:text]||data[:raw_line]
    if tx.match?(REG_LEADING_TAG)
      # 
      # <= Le texte contient des balises de style
      # => Il faut relever ces balises et les retirer du
      #    texte.
      tx = tx.gsub(REG_LEADING_TAGS) do
        tags = $1.freeze
        text = $2.freeze
        self.styled_tags = tags.split('::')
        text
      end
    end
    @text = tx
  end

end #/class NTextParagraph
end #/class PdfBook
end #/module Prawn4book
