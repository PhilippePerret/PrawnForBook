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

  def inputfile
    @inputfile = InputSimpleFile.new(self, data[:text_path])
  end

  def folder
    @folder ||= File.join(data[:main_folder],data[:id])
  end

  private

    # --- PDF Methods & Props ---

    # @prop Configuration pour le second argument de la méthode
    # #generate de Prawn::Document (en fait PdfBook::PdfFile)
    def pdf_config
      @pdf_config ||= begin
        {
          margin: PdfFile::MARGIN_ODD,
          default_leading:  1
        }
      end
    end

    def pdf_path
      @pdf_path ||= File.join(folder,'book.pdf')
    end

    def recipe_path
      @recipe_path ||= File.join(folder,'recipe.yaml')
    end


end #/class PdfBook
end #/module Prawn4book
