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
    @inputfile = InputTextFile.new(self, data[:text_path])
  end

  # --- Predicate Methods ---

  # @return true si le document appartient à une collection
  def collection?
    not(data[:collection] === false || data[:collection] === nil)
  end


  # --- Data Methods ---

  def titre; recette.title end


  # --- Paths Methods ---

  def folder
    @folder ||= File.join(recette[:main_folder])
  end

  private

    # --- PDF Methods & Props ---


    def pdf_path
      @pdf_path ||= File.join(folder,'book.pdf')
    end

    def recipe_path
      @recipe_path ||= File.join(folder,'recipe.yaml')
    end


end #/class PdfBook
end #/module Prawn4book
