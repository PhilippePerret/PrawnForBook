module Prawn4book

# ::runner
class Command
  def proceed
    PdfBook.init_new_book_or_collection
  end
end #/Command

class PdfBook
class << self

  ##
  # = main =
  # 
  # Méthode principale pour définir la recette du livre
  # Soit on demande simplement un template, soit on utilise
  # l'assistant, mais il n'est pas tout à fait à jour.
  # 
  # @param cdata {Hash|Nil} Les données qui peuvent permettre de
  # définir des premières chose sur le livre dont il faut définir ou
  # redéfinir la recette.
  # 
  def init_new_book_or_collection(cdata = nil, force = false)
    clear
    @inited = case choose_what
    when NilClass     then return
    when :book        then InitedBook.new
    when :collection  then InitedCollection.new
    end
    # 
    # On y va
    # 
    @inited.init

  end

  def choose_what
    Q.select("Que dois-je initier ?".jaune) do |q|
      q.choice 'Un livre', :book
      q.choice 'Une collection', :collection
      q.choice 'Renoncer', nil
      q.per_page 3
    end
  end

end #/<< self
end #/class PdfBook
end #/module Prawn4book
