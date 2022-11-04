# encoding: UTF-8
=begin

  class TestedBook
  ----------------

  Elle doit permettre de tester en profondeur les livres produits.

=end
require_relative 'TestedBook_Assertions'
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
    assert File.exist?(expectations_file_path), "Le fichier 'expectations' n'existe pas…"
    File.readlines(expectations_file_path).each do |line|
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


  # --- Propriétés utiles ---

  # Le texte entier simple, ligne après ligne
  def whole_string
    @whole_string ||= text_inspector.strings.join("\n")
  end

  def text_inspector
    @text_inspector ||= PDF::Inspector::Text.analyze_file(book_path)
  end
  alias :texter :text_inspector

  def pages_inspector
    @pages_inspector ||= PDF::Inspector::Page.analyze_file(book_path)
  end
  alias :pager :pages_inspector

  # --- Fonctional Methods ---

  def delete_pdf
    File.delete(book_path) if File.exist?(book_path)
  end

  # --- Path Properties ---

  # @prop Fichier contenant le check du pdf à faire
  def expectations_file_path
    @expectations_file_path ||= File.join(folder,'expectations')
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
