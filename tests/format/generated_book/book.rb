require 'timeout'

module GeneratedBook
class Book
  include Prawn::Measurements
  # Notamment la méthode pt2mm(<pts>) qui permet d'obtenir la dimension
  # en millimètre pour la dimension en ps-points.

  def self.erase_if_exist
    FileUtils.rm_rf(folder) if File.exist?(folder)
    cfolder = GeneratedBook::Collection.folder
    FileUtils.rm_rf(cfolder) if File.exist?(cfolder)
  end

  # --- Chemins d'accès utiles ---
  #
  # @return [String] Chemin d'accès au livre. Ce sera toujours celui-là
  def self.folder
    mkdir(File.join(__dir__, folder_name))
  end
  def self.folder_books
    mkdir(File.join(__dir__, '_generated_books_'))
  end
  def self.folder_in_collection
    mkdir(File.join(GeneratedBook::Collection.folder, folder_name))
  end
  def self.folder_name
    @@folder_name ||= '_generated_book'
  end

  def self.unnamed_test
    @@iunnamed_test ||= 0
    @@iunnamed_test += 1
    "test-sans-nom-#{@@iunnamed_test}"
  end

###################       INSTANCE      ###################
  
  def initialize(test_method_name = nil)
    Prawn4book::PdfBook.reset if defined?(Prawn4book::PdfBook)
    @isincollection = false # a priori
    @test_method_name = test_method_name || self.class.unnamed_test
  end

  ##
  # Méthode appelée au tout départ pour indiquer que le livre se
  # trouve dans une collection
  def in_collection(data_collection)
    @isincollection = true
    collection.recipe.build_with(data_collection)
  end

  def in_collection?
    @isincollection == true
  end

  ##
  # = main =
  # 
  # FABRICATION DU LIVRE
  # 
  # @note
  #   Le nom de la méthode de test est importante, car il déterminera
  #   le nom du fichier final qui sera mis dans _generated_books_ 
  #   pour toujours conserver une version d'un livre construit.
  # 
  def build(check_if_book_has_been_built = true)
    ensure_book_valid
    res = `cd "#{folder}";pfb build#{' --spy' if RUN_SPY} --display_grid -display_margins 2>&1`
    # res = `cd "#{folder}";pfb build#{' --spy' if RUN_SPY}`
    # puts "res = #{res.inspect}"
    raise res if res.match?(/ERR/)

    # 
    # On attend que le livre soit construit
    # (au bout de 5 secondes, on produit une erreur car le livre,
    #  devrait avoir été construit)
    # 
    if check_if_book_has_been_built
      Timeout.timeout(5) { sleep 0.2 until File.exist?(book_path) }
    else
      sleep 1
    end
    # 
    # On fait une copie du livre
    # 
    book_name = "#{@test_method_name[5..-1]}.pdf"
    src = book_path
    dst = File.join(self.class.folder_books, book_name)
    FileUtils.cp(src, dst)
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
  # @param [String|Symbol] content  Contenu du livre. C'est soit un texte simple, soit un symbole qui renvoie à un texte du dossier 'textes' du dossier courant.
  def build_text(content = nil)
    # 
    # Construire le dossier au cas où
    # 
    mkdir(folder)
    # 
    # Définir le contenu textuel du livre
    # 
    content = case content
    when String 
      content
    when NilClass
      "Bonjour tout le monde !"
    when Symbol 
      rf = File.join(__dir__,'textes', "#{content}.pfb.md")
      File.exist?(rf) || raise("Le fichier #{rf.inspect} est introuvable.")
      File.read(rf)
    end
    # 
    # Écriture du texte
    # 
    File.write(text_path, content)
  end

  # --- Volatile Data ---

  def recipe
    @recipe ||= Recipe.new(self)
  end

  def collection
    @collection ||= GeneratedBook::Collection.new
  end

  # --- Path Data ---

  def text_path ; @text_path ||= File.join(folder,'texte.pfb.md') end
  def book_path ; @book_path ||= File.join(folder,'book.pdf')     end
  def folder
    @folder ||= begin
      if in_collection?
        self.class.folder_in_collection
      else
        self.class.folder
      end
    end
  end

end #/class Book
end #/module GeneratedBook
