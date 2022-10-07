module Narration
class PdfBook

  attr_reader :inputfile
  attr_reader :config

  ##
  # Instanciation à l'aide de l'instance {InputSimpleFile} du
  # fichier contenant le texte initial.
  # 
  def initialize(inputfile, config)
    @inputfile = inputfile
    @config    = config
  end

  ##
  # = main =
  # 
  # Méthode principale pour produire (aka "générer") le pdf
  # final
  # 
  def generate_pdf_book
    clear
    inputfile.parse
    # Object.const_set('CONFIG', config)
    PdfFile.generate(pdf_path, pdf_config) do |doc|
      # 
      # On définit les polices requises pour le livre
      # 
      # define_required_fonts(self.config[:fonts])
      doc.define_required_fonts(config[:fonts])
      #
      # Définition des numéros de page
      # 
      doc.set_pages_numbers
      #
      # On se place toujours en haut de la page pour commencer
      #
      doc.move_cursor_to_top_of_the_page

      interligne = 18

      # 
      # On boucle sur tous les paragraphes du fichier d'entrée
      # 
      # Note : chaque paragraphe est une instance de classe de
      # son type. Par exemple, les images sont des PdfBook::NImage,
      # les titres sont des PdfBook::NTitre, etc.
      # 
      # Note : 'with_index' permet juste de faire des essais
      # 
      inputfile.paragraphes.each_with_index do |paragraphe, idx|
        doc.insert(paragraphe)
        break if page_number == 24
        doc.move_down( paragraphe.margin_bottom )
      end
    end #/pdfile.generate
  end

  # --- PDF Methods & Props ---

  # @prop {PdfBook} Class Narration::PdfBook::PdfFile pour
  # produire le fichier PDF final
  # 
  def pdfile
    @pdfile ||= PdfFile
  end

  # @prop Configuration pour le second argument de la méthode
  # #generate de Prawn::Document (en fait PdfBook::PdfFile)
  def pdf_config
    @pdf_config ||= begin
      {
        margin:           PdfFile::MARGIN_ODD,
        default_leading:  5, # bon => 1
      }
    end
  end

  def pdf_path
    @pdf_path ||= begin
      inputfile.affixe_path + '.pdf'
    end
  end

end #/class PdfBook
end #/module Narration
