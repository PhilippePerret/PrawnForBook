module Prawn4book
class PdfBook
class ParagraphAccumulator

  # @api stable group
  # 
  # Accumulateur de paragraphes
  # 
  # Classe abstraite qui permet d’accumuler des paragraphes lorsqu’il
  # s’agit d’un bloc, par exemple un bloc de code initié par `~~~’
  # ou un bloc de commentaires.
  # 

  def initialize(book:)
    @book       = book
    @paragraphs = []
  end

  def add(paragraph)
    @paragraphs << paragraph
  end
  alias :<< :add

  def count
    @paragraphs.count
  end

  def each_paragraph(&block)
    if block_given?
      @paragraphs.each do |par, idx|
        yield par
      end
    end
  end

end #/class ParagraphAccumulator
end #/class PdfBook
end #/module Prawn4book
