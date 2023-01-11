module GeneratedBook
class Book
  include Prawn::Measurements
  # Notamment la méthode pt2mm(<pts>) qui permet d'obtenir la dimension
  # en millimètre pour la dimension en ps-points.

  def self.erase_if_exist
    FileUtils.rm_rf(folder) if File.exist?(folder)
  end

  # --- Chemins d'accès utiles ---
  #
  # @return [String] Chemin d'accès au livre. Ce sera toujours celui-là
  def self.book_path
    @book_path ||= File.join(folder, 'book.pdf')
  end
  def self.recipe_path
    @recipe_path ||= File.join(folder, 'recipe.yaml')
  end
  def self.text_path
    @text_path ||= File.join(folder, 'texte.pfb.md')
  end
  def self.folder
    mkdir(File.join(ASSETS_FOLDER,'essais','generated_book'))
  end

###################       INSTANCE      ###################
  
  ##
  # Méthode principale construisant le livre
  def build
    ensure_book_valid
    `cd "#{folder}";pfb build`
  end


  def build_recipe_with(props)
    puts "Je dois apprendre à construire la recette avec #{props.inspect}".jaune
  end

  # --- Utils Methods ---

  # Méthode très importante qui s'asssure que le livre est valide
  # 
  # À la base, il s'agit simplement de s'assure que le texte et la
  # recette existe, mais ensuite, suivant la recette et le texte,
  # il y aura plus de choses à vérifier, comme les références, les
  # bibliographies etc.
  def ensure_book_valid
    texte_exist? || build_text
  end

  # --- Text Methods ---

  def texte_exist?
    File.exist?(text_path)
  end

  # Construit le fichier texte avec le contenu +content+
  def build_text(content = nil)
    mkdir(folder)
    content ||= "Bonjour tout le monde !"
    File.write(text_path, content)
  end


  def folder      ; @folder       ||= self.class.folder       end
  def recipe_path ; @recipe_path  ||= self.class.recipe_path  end
  def text_path   ; @text_path    ||= self.class.text_path    end
  def book_path   ; @book_path    ||= self.class.book_path    end

end #/class Book
end #/module GeneratedBook
