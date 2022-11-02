=begin

  class TestedBook
  ----------------

  Elle doit permettre de tester en profondeur les livres produits.

=end

class TestedBook
  
  include Minitest::Assertions
  attr_accessor :assertions

  attr_reader :folder
  def initialize(folder)
    @folder = folder
    self.assertions = 0
  end
  # = main =
  # 
  # Méthode principale pour checker le livre produit sans erreur
  # 
  def check
    assert File.exist?(book_path), "Le livre n'a pas été produit…"
    assert File.exist?(checkup_path), "Le fichier checkup.txt n'existe pas…"
    File.readlines(checkup_path).each do |line|
      next if line.start_with?('#')
      line = line.strip
      next if line.empty?
      # puts "Traitement de la ligne #{line.inspect}".jaune
      dline = line.split(":::").map{|n|eval(n.strip)}
      assertion = dline.shift
      args = dline
      send(assertion, *args)
    end
  end

  # --- ASSERTIONS METHODS ---

  def should_have_texte(textes)

    textes = [textes] if textes.is_a?(String)
    textes.each do |texte|
      assert_include text_inspector.strings, texte
    end
  end


  # --- Propriétés utiles ---

  def text_inspector
    @text_inspector ||= PDF::Inspector::Text.analyze(book_path)
  end

  def pages_inspector
    @pages_inspector ||= PDF::Inspector::Page.analyze(book_path)
  end

  # --- Fonctional Methods ---

  def delete_pdf
    File.delete(book_path) if File.exist?(book_path)
  end

  # --- Path Properties ---

  # @prop Fichier contenant le check du pdf à faire
  def checkup_path
    @checkup_path ||= File.join(folder,'checkup.txt')
  end

  def name # le nom du dossier
    @name ||= File.basename(folder)
  end

  def book_path
    @book_path ||= File.join(folder,'book.pdf')
  end

  def recipe_path
    @recipe_path ||= File.join(folder,'recipe.yaml')
  end

  def collection_recipe_path
    @collection_recipe_path ||= File.join(collection_folder,'recipe_collection.yaml')
  end

  def collection_folder
    @collection_folder ||= File.dirname(folder)
  end
end
