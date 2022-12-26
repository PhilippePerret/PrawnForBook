require 'test_helper'

require 'lib/required'
require 'lib/pages/page_de_titre'

class PageTitreUnitTest < Minitest::Test

  def setup
    super
    make_book_valid
  end
  def teardown
    super
  end

  def page_titre
    @page_titre ||= Prawn4book::Pages::PageDeTitre.new(book_folder)
  end

  def page_titre_collection
    @page_titre_collection ||= Prawn4book::Pages::PageDeTitre.new(collection_folder)
  end

  def test_tag_name
    assert_respond_to page_titre, :tag_name
    expected  = 'page_de_titre'
    actual    = page_titre.tag_name
    assert_equal expected, actual, "Le tag_name de la page devrait être #{expected.inspect}. Or, c'est #{actual.inspect}"
  end

  def test_book?
    assert_respond_to page_titre, :book?
    assert page_titre.book?
    refute page_titre_collection.book?
  end

  def test_get_data_in_recipe
    assert_respond_to page_titre, :get_data_in_recipe
    assert_instance_of Hash, page_titre.get_data_in_recipe
    File.delete(book.recipe_path) if File.exist?(book.recipe_path)
    assert_instance_of Hash, page_titre.get_data_in_recipe
    expected = {}
    assert_equal( expected, page_titre.get_data_in_recipe, "Les données devraient être vides…")
  end

  def test_set_data_in_recipe
    assert_respond_to page_titre, :set_data_in_recipe

    # --- Préparation du test ---
    # Pour ce test, on peut détruire le fichier recette ?
    File.delete(book.recipe_path) if File.exist?(book.recipe_path)

    # ===> Test <===
    newd = {
      sizes: {title: 12, subtitle: 11, author: 10, publisher:9, collection_title:8},
      spaces_before: {title: 4, subtitle:3, author:2},
      logo: {height: 20}
    }
    page_titre.set_data_in_recipe(newd)
    
    # --- Vérifications ---
    yaml = YAML.load_file(File.join(book_folder,'recipe.yaml'), aliases:true, symbolize_names:true)
    yaml = yaml[:page_de_titre]
    assert yaml.key?(:sizes)
    assert yaml.key?(:spaces_before)
    assert yaml.key?(:logo)
    refute yaml.key?(:pourvoir)
    [
      ['Taille de titre', yaml[:sizes][:title], 12],
      ['Taille de sous-titre', yaml[:sizes][:subtitle], 11],
      ['Taille de auteur', yaml[:sizes][:author], 10],
      ['Taille des éditions', yaml[:sizes][:publisher], 9],
      ['Taille du titre de collection', yaml[:sizes][:collection_title], 8],
      ['Espace avant titre', yaml[:spaces_before][:title], 4],
      ['Espace avant sous-titre', yaml[:spaces_before][:subtitle], 3],
      ['Espace avant auteur', yaml[:spaces_before][:author], 2],
      ['Hauteur de logo', yaml[:logo][:height], 20],
    ].each do |what, expected, actual|
      assert_equal(expected, actual, "#{what} devrait valoir #{expected.inspect}. Il vaut #{actual.inspect}.")
    end
  end


  private

  def make_book_valid
    if not File.exist?(book.recipe_path)
      File.write(book.recipe_path, "---\n:book_title: Un livre pour test\n:book_id: livre_essais")
    end
  end

  def book
    @book ||= Prawn4book::PdfBook.new(book_folder)
  end

  def collection
    @collection ||= Prawn4book::Collection.new(collection_folder)
  end
  
  def book_folder
    @book_folder ||= File.join(TEST_FOLDER,'essais','books','un_livre_pour_tests')
  end

  def collection_folder
    @collection_folder ||= File.join(TEST_FOLDER,'essais','books','une_collection')
  end

end #/class PageTitreUnitTest
