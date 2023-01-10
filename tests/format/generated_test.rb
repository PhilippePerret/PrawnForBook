=begin

  Je voudrais, avec ce module de test, pouvoir générer des recettes
  et des textes rapidement et construire les livres pour voir si
  tout correspond.

=end
require 'test_helper'
require_relative 'generated_book_utils'
class GeneratedBookTestor < Minitest::Test

  # Instance GeneratedBook::Book (réinitialisée à chaque test)
  attr_reader :book

  def setup
    super
    GeneratedBook::Book.erase_if_exist
    @book = GeneratedBook::Book.new
  end

  def teardown
    super
  end

  def test_book_is_built_only_with_simple_text
    resume "
    On peut construire un livre avec un simple fichier texte
    de nom 'texte.pfb.md'
    "
    book.build
  end

  def test_simple_book
    # 
    # HOT: L'idée, en travaillant ce test, et de voir les données
    # minimales qu'il faut fournir pour pouvoir construire un livre
    # Dans l'idéal, seul le texte devrait être nécessaire
    # props = {margin: 10.mm}
    # book.build_recipe_with(**props)
    book.build
  end

end #/class GeneratedBookTestor
