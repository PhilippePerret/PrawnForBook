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
    thing = choose_what
    this_thing = thing == :book ? 'ce livre' : 'cette collection'
    thing_name = Q.ask("Nom du dossier de #{this_thing} :".jaune) || return
    thing_path = File.expand_path(File.join('.', thing_name))
    Q.yes?("Le chemin d'accès à #{this_thing} sera-t-il bien le dossier #{thing_path.inspect} ?".jaune) || return
    mkdir(thing_path)
    @inited = case thing
    when NilClass     then return
    when :book        then InitedBook.new(thing_path)
    when :collection  then InitedCollection.new(thing_path)
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
