module Prawn4book
class PdfBook

  ##
  # Instanciation du PdfBook qui va permettre de générer le fichier
  # PDF prêt à l'impression.
  # 
  def initialize(folder)
    @folder         = folder
  end

  # Pour actualiser le fichier recette
  # S'il s'agit d'une collection, on actualise le fichier recette
  # de cette collection. C'est pour cette raison que pdfbook.recipe
  # ne doit pas être appelée directement par les méthodes.
  # 
  # @param new_data {Hash} Table ne contenant que les nouvelles
  #                 données à enregistrer.
  # 
  def update_recipe(new_data)
    if collection?
      recipe.update_collection(new_data)
    else
      recipe.update(new_data)
    end
  end


  # Pour ouvrir le livre dans Aperçu, en double pages
  def open_book
    if File.exist?(pdf_path)
      `osascript "#{APP_FOLDER}/resources/bin/open_book.scpt" "#{pdf_path}"`
    else
      puts "Il faut produire le livre, avant de pouvoir le lire ! (jouer `prawn-for-book build')".rouge
    end
  end

  # --- Helpers Methods ---

  def ensured_title
    @ensured_title ||= title || File.basename(folder)
  end

  # --- Objects Methods ---

  def font_or_default(font_name)
    fontes.key?(font_name) ? font_name : second_font  
  end

  ##
  # Première fonte définie (pour valeur par défaut de certains
  # texte majeurs)
  # 
  def first_font
    @first_font ||= fontes.keys[0]
  end
  alias :default_font :first_font

  # @prop Seconde fonte définie (ou première si une seule) pour 
  # valeur par défaut de certains texte mineurs.
  def second_font
    @second_font ||= fontes.keys[1] || first_font
  end

  def fontes
    @fontes ||= recette[:fonts]
  end

  # @prop Instance {PdfBook::Recipe} de la recette du livre
  # @usage
  #   <book>.recette[key] # => valeur dans la recette du livre
  #                       #    ou la recette de la collection
  def recette
    @recette ||= Recipe.new(self)
  end
  alias :recipe :recette

  def page_index
    @page_index ||= PageIndex.new(self)
  end

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


  def pagination_page?
    :TRUE == @haspagenum ||= true_or_false(recette[:num_page_style] == 'num_page')  
  end

  # @return true si le document appartient à une collection
  def collection?
    recette.collection?
  end

  def has_text?
    File.exist?(text_file)
  end


  # --- Data Methods ---

  def titre; recette.title end
  alias :title :titre


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

  def pdf_path
    @pdf_path ||= File.join(folder,'book.pdf')
  end



end #/class PdfBook
end #/module Prawn4book
