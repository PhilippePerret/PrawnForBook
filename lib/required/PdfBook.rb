module Prawn4book
class PdfBook

  ##
  # Instanciation du PdfBook qui va permettre de générer le fichier
  # PDF prêt à l'impression.
  # 
  def initialize(folder)
    @folder    = folder
  end

  ##
  # = main =
  # 
  # Méthode principale pour produire (aka "générer") le pdf
  # final
  # 
  def generate
    Prawn4book.require_module('pdfbook/generate')
    generate_pdf_book
  end

  # Pour ouvrir le livre dans Aperçu, en double pages
  def open_book
    if File.exist?(pdf_path)
      `osascript "#{APP_FOLDER}/resources/bin/open_book.scpt" "#{pdf_path}"`
    else
      puts "Il faut produire le livre, avant de pouvoir le lire !".rouge
    end
  end

  # @prop Instance {PdfBook::Recipe} de la recette du livre
  # @usage
  #   <book>.recette[key] # => valeur dans la recette du livre
  #                       #    ou la recette de la collection
  def recette
    @recette ||= Recipe.new(self)
  end
  alias :recipe :recette

  # def data
  #   @data ||= YAML.load_file(recipe_path, aliases: true)
  # end

  def collection
    @collection ||= collection? ? Collection.new(self) : nil
  end

  # @prop L'instance du fichier texte qui contient le texte à
  # traiter.
  # 
  def inputfile
    @inputfile = InputTextFile.new(self, recette[:text_path])
  end

  # --- Predicate Methods ---

  # @return true si le document appartient à une collection
  def collection?
    recette.collection?
  end

  def has_text?
    File.exist?(text_file)
  end


  # --- Data Methods ---

  def titre; recette.title end


  # --- Paths Methods ---

  def text_file
    @text_file ||= begin
      if File.exist?(pth = File.join(folder,'texte.md'))
        pth
      elsif File.exist?(pth = File.join(folder,'texte.txt'))
        pth
      end
    end
  end

  def recipe_path
    @recipe_path ||= File.join(folder,'recipe.yaml')
  end

  def image_path(relpath)
    if File.exist?(relpath)
      relpath
    elsif collection? && File.exist?(pth = File.join(collection.folder,'images',relpath))
      return pth
    elsif File.exist?(pth = File.join(folder_images, relpath))
      return pth
    else
      raise "L'image '#{relpath}' est introuvable (ni dans le dossier de la collection si le livre appartient à une collection, ni dans le dossier 'images' du livre, ni en tant que path absolue)"
    end
  end

  def folder_images
    @folder_images ||= File.join(folder,'images')
  end

  def folder
    @folder ||= File.join(recette[:main_folder])
  end


  private

    # --- PDF Methods & Props ---


    def pdf_path
      @pdf_path ||= File.join(folder,'book.pdf')
    end



end #/class PdfBook
end #/module Prawn4book
