require 'test_helper'
require './lib/required'

class RecipeTest < Minitest::Test

  BOOK_FOLDER = "/Users/philippeperret/Programmes/Prawn4book/tests/assets/all_books/collections/first_collection/livre1coll1"
  def setup
    super
  end

  def test_chargement_sans_probleme_de_toutes_les_donnees_recettes
    owner = Prawn4book::PdfBook.new(BOOK_FOLDER)
    recipe = Prawn4book::Recipe.new(owner)
    assert_silent { recipe.send(:get_all_data) }
  end


end
