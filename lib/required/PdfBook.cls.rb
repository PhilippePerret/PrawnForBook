module Prawn4book
class PdfBook
class << self

  # S'assure que la commande a été jouée depuis un livre ou une
  # collection et retourne l'instance, ou lève une exception.
  # 
  # @return [Prawn4book::PdfBook]
  # 
  # @api public
  def ensure_current
    return current if current?
    puts ERRORS[:require_a_book_or_collection].rouge
    return false
  end

  # @return true si on se trouve dans un dossier de livre
  # ou de collection
  def current?
    File.exist?(File.join(cfolder,'recipe.yaml')) || 
    File.exist?(File.join(cfolder,'recipe_collection.yaml'))
  end

  def in_collection?
    current? && File.exist?(File.join(cfolder,'recipe_collection.yaml'))
  end

  def cfolder
    @cfolder ||= begin
      compun = CLI.components[1]
      if compun && File.exist?(compun) && File.directory?(compun)
        compun
      else
        File.expand_path('.')
      end
    end
  end

  # @return une instance du book courant
  #
  # Soit ce livre est défini par le dossier courant (s'il contient
  # les éléments requis) soit il est défini par le premier argument
  # 
  def get_current
    # 
    # Le livre existe-t-il vraiment ? Si oui, on le prend, sinon,
    # on lève une exception.
    # 
    if File.exist?(cfolder) && (File.exist?(File.join(cfolder,'recipe.yaml')) || File.exist?(File.join(cfolder,'texte.pfb.md')))
      PdfBook.new(cfolder)
    else
      raise "Impossible de trouver le livre '#{cfolder}'… Ce n'est pas un dossier de livre PDF."
    end
  end
  alias :current :get_current

end #/<< self
end #/class PdfBook
end #/module Prawn4book
