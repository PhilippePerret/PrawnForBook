module CustomIndexModule

  # def index_lettre(lettre, output, context)
  #   return lettre
  # end

end

module PrawnHelpersMethods
  def lettre(lettre, context)
    return (name + ' = <font name="PictoPhil" size="16">' + lettre + '</font>')
  end
end

module Prawn4book
  class PdfBook::NTextParagraph
  end
end