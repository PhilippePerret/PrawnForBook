module Prawn4book
class PdfBook

  ##
  # Instanciation du PdfBook qui va permettre de générer le fichier
  # PDF prêt à l'impression.
  # 
  # @param [String] folder Path to folder book.
  def initialize(folder)
    @folder = folder
  end

  def sous_titre  ; recette.subtitle  end
  alias :subtitle :sous_titre
  def auteurs     ; recette.auteurs   end


  # # Pour actualiser le fichier recette
  # # S'il s'agit d'une collection, on actualise le fichier recette
  # # de cette collection. C'est pour cette raison que pdfbook.recipe
  # # ne doit pas être appelée directement par les méthodes.
  # # 
  # # @param new_data {Hash} Table ne contenant que les nouvelles
  # #                 données à enregistrer.
  # # 
  # def update_recipe(new_data)
  #   if in_collection?
  #     recipe.update_collection(new_data)
  #   else
  #     recipe.update(new_data)
  #   end
  # end


  # Pour ouvrir le livre dans Aperçu, en double pages
  def open_book
    if File.exist?(pdf_path)
      `osascript "#{APP_FOLDER}/resources/bin/open_book.scpt" "#{pdf_path}"`
    else
      puts "Il faut produire le livre, avant de pouvoir le lire ! (jouer `prawn-for-book build')".rouge
    end
  end

  # --- Helpers Methods ---


  # --- Objects Methods ---

  def font_or_default(font_name)
    fontes.key?(font_name) ? font_name : second_font  
  end

  def page_index
    @page_index ||= PageIndex.new(self)
  end

  def collection
    @collection ||= in_collection? ? Collection.new(self) : nil
  end

  # @prop L'instance du fichier texte qui contient le texte à
  # traiter.
  # 
  def inputfile
    @inputfile = InputTextFile.new(self, recette[:text_path])
  end


  # --- Predicate Methods ---
  
  # @return true si le document appartient à une collection
  def in_collection?
    recette.in_collection?
  end

  def is_collection?
    false
  end

  def has_text?
    File.exist?(text_file)
  end

  # --- Paths Methods ---

  def text_file
    @text_file ||= begin
      filepath = nil
      ['.pfb.md', 'md','txt','text'].each do |ext|
        ['text','texte','content','contenu'].each do |affixe|
          pth = File.join(folder, "#{affixe}.#{ext}")
          filepath = pth and break if File.exist?(pth)
        end
        break unless filepath.nil?
      end
      filepath
    end
  end

  def pdf_path
    @pdf_path ||= File.join(folder,'book.pdf')
  end

  # @return [String] Nom du fichier recette
  def recipe_name ; 'recipe.yaml' end

end #/class PdfBook
end #/module Prawn4book
