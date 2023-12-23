module Prawn4book
class PdfBook
class ParagraphAccumulator

  attr_reader :book, :pdf

  # @api stable group
  # 
  # Accumulateur de paragraphes
  # 
  # Classe abstraite qui permet d’accumuler des paragraphes lorsqu’il
  # s’agit d’un bloc, par exemple un bloc de code initié par `~~~’
  # ou un bloc de commentaires.
  # 

  def initialize(book)
    @book       = book
    @paragraphs = []
  end

  def add(paragraph)
    @paragraphs << paragraph
  end

  def print(pdf)
    # Exposer
    @pdf = pdf
  end

  def count
    @paragraphs.count
  end

  def each_paragraph(&block)
    if block_given?
      @paragraphs.each do |par|
        pdf && par.prepare_and_formate_text(pdf)
        yield par
      end
    end
  end

end #/class ParagraphAccumulator
end #/class PdfBook
end #/module Prawn4book
