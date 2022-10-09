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

  def data
    @data ||= YAML.load_file(recipe_path, aliases: true)
  end
  alias :recette :data
  alias :recipe  :data

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

  def paragraph_number?
    :TRUE == @hasparagnum ||= true_or_false(opt_num_parag)
  end


  # --- Paths Methods ---

  def folder
    @folder ||= File.join(data[:main_folder])
  end


  # --- Data Methods ---

  def footer
    @footer ||= begin
      if collection?
        collection.data[:footer]
      else
        data[:footer] || {style:{font:'Times', font_size:9}}
      end
    end
  end

  def opt_num_parag
    @opt_num_parag ||= begin
      if data[:opt_num_parag] == :collection || data[:opt_num_parag].nil?
        collection.data[:opt_num_parag]
      else
        data[:opt_num_parag] === true
      end
    end
  end

  def num_page_style
    @num_page_style ||= begin
      if data[:num_page_style] == :collection || data[:num_page_style].nil?
        collection.data[:num_page_style]
      else
        data[:num_page_style] || 'num_page'
      end
    end
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
