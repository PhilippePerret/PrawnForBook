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
  # définir des premières choses sur le livre dont il faut définir ou
  # redéfinir la recette.
  # 
  # ATTENTION : Cette méthode a été transformée pour tenir compte
  # du fait qu'on appelle prawn-for-book avec un alias, pour le
  # jouer par bundler avec la bonne version ruby
  # 
  def init_new_book_or_collection(cdata = nil, force = false)
    clear

    # - essai -
    # InitedThing.new(nil,'mon/dossier').confirmation_finale
    # return

    thing = choose_what
    this_thing = thing == :book ? 'ce livre' : 'cette collection'
    thing_path = BOOK_DIR
    Q.yes?("Le chemin d'accès à #{this_thing} sera-t-il bien le dossier :\n  #{thing_path.inspect} ?".jaune) || return
    @inited = case thing
      when NilClass
        return
      when :book     
        InitedBook.new(PdfBook.new(thing_path), thing_path)
      when :collection
        InitedCollection.new(Collection.new(thing_path), thing_path)
      end
    # 
    # On y va
    # 
    @inited.init

  end

  def choose_what
    Q.select("Que dois-je initier dans ce dossier ?".jaune) do |q|
      q.choice 'Un livre', :book
      q.choice 'Une collection', :collection
      q.choice 'Renoncer', nil
      q.per_page 3
    end
  end

end #/<< self
end #/class PdfBook
end #/module Prawn4book
