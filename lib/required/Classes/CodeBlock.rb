module Prawn4book
class PdfBook
class CodeBlock < ParagraphAccumulator

  attr_reader :language

  def initialize(book:, pindex:, language:)
    super(book)
    @pindex   = pindex # juste pour le situer en cas d’erreur
    @language = language
  end

  # = main =
  # 
  # Méthode affichant le bloc de code
  # 
  # @note
  #   Pour le moment, pas de colorisation syntaxique, et je ne 
  #   voudrais pas que l’application devienne un logiciel pour geek
  #   codeur…
  # 
  def print(pdf)
    super
    pdf.update do 
      font(Fonte.code_fonte)
    end
    each_paragraph do |par|
      par.prepare_and_formate_text(pdf)
      # Tous les espaces en début de texte doivent être remplacés
      # par des espaces insécables
      str = par.text.gsub(/^( +)/.freeze){ ' ' * $1.length}
      pdf.text(str)
    end
    pdf.update_current_line
  end

end #/class CodeBlock
end #/class PdfBook
end #/module Prawn4book
