module Prawn4book
class PdfBook
class << self

  # @api
  # (on s'en sert notamment pour déterminer au tout départ si la 
  #  commande est jouée dans un dossier de livre)
  def is_book?(fold)
    File.exist?(File.join(fold,'recipe.yaml')) ||
    File.exist?(File.join(fold,'recipe_collection.yaml')) ||
    File.exist?(File.expand_path(File.join(fold,'..','recipe_collection.yaml')))
  end

  # S'assure que la commande a été jouée depuis un livre ou une
  # collection et retourne l'instance, ou lève une exception.
  # 
  # @return [Prawn4book::PdfBook]
  # 
  # @api public
  def ensure_current
    return current if current?
    raise PFBFatalError.new(1, { path: File.expand_path('.') })
  end

  # @return true si on se trouve dans un dossier de livre
  # ou de collection
  def current?
    is_book?(cfolder)
  end


  def in_collection?
    current? && File.exist?(File.join(cfolder,'recipe_collection.yaml'))
  end

  def cfolder
    @cfolder ||= begin
      compun = BOOK_DIR
      compun && File.exist?(compun) && File.directory?(compun) || begin
        raise "Dossier du livre non défini."
      end
      compun
    end
  end

  # Pour les tests
  def reset
    @cfolder = nil
  end

  # @return une instance du book courant
  #
  # Soit ce livre est défini par le dossier courant (s'il contient
  # les éléments requis) soit il est défini par le premier argument
  # 
  def get_current
    @current ||= begin
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
  end
  alias :current :get_current

  def current=(pdfbook)
    @current = pdfbook
    @cfolder = pdfbook.folder
  end

end #/<< self
end #/class PdfBook
end #/module Prawn4book
