module Prawn4book
class PdfBook
class NTextParagraph

  def self.get_next_numero
    @@last_numero ||= 0
    @@last_numero += 1
  end

  attr_reader :data
  attr_reader :numero
  alias :number :numero

  def initialize(data)
    @data   = data.merge!(type: 'paragraph')
    @numero = self.class.get_next_numero
  end

  # --- Helper Methods ---

  # def margin_bottom; 0  end
  def margin_bottom; 10  end

  # --- Predicate Methods ---

  def paragraph?; true end

  # --- Data Methods ---

  def text  ; @text ||= data[:text]||data[:raw_line] end

end #/class NTextParagraph
end #/class PdfBook
end #/module Prawn4book
