=begin

  Pour tester tout ce qui concerne les index dans un livre

=end
require 'test_helper'
require_relative 'generated_book/required'

class IndexPageTest < Minitest::Test

  def setup
    super
  end
  def teardown
    super
  end


  # Pour se concentrer sur un test en particulier
  # Utiliser 'return if focus?' en début des tests sauf celui qu'on
  # travaille.
  def focus?
    true
    # false # pour jouer tous les tests
  end

  # Le livre généré (spécial pour les tests)
  # @note
  #   On s'assure qu'il n'existe pas physiquement à l'instanciation 
  def book
    @book ||= begin
      GeneratedBook::Book.erase_if_exist
      GeneratedBook::Book.new
    end
  end

  # Le checker du livre
  def pdf
    @pdf ||= PDF::Checker.new(book.book_path)
  end

  def recide_minimal_data
    {
      book_titre: "Livre avec index",
      titre1_lines_before: 0,
      numerotation: 'parags',
    }
  end

  def recipe_data_with_styles
    recide_minimal_data.merge({
      index_canon_font_name: 'Courier',
      index_canon_font_size: 16,
      index_canon_font_style: :italic,
      index_number_font_name: 'Helvetica',
      index_number_font_size: 8,
      index_number_font_style: :regular
    })
  end


  def test_mots_indexes_default_parameters
    return if focus?
    resume "
    Le programme doit relever tous les mots indexés et les inscrire
    dans une page d'index.
    "
    book.recipe.build_with(recide_minimal_data)
    book.build_text("Un texte avec un mot index:indexé.\nUn index(mot) peut être index(indexé).\nIl peut aussi être index(remplacé|mot) par un autre à l'affichage.\n(( index ))")
    book.build

    pdeux = pdf.page(2)
    pdeux.has_text("Index")
    pdeux.has_text("indexé : 1, 2")
    pdeux.has_text("mot : 2, 3")
  end


  def test_mots_indexes_with_custom_fonts
    # return if focus?
    resume "
    La fabrication de l'index tient compte des fontes définies.
    "
    book.recipe.build_with(recipe_data_with_styles)
    book.build_text("Un texte avec un mot index:indexé.\nUn index(mot) peut être index(indexé).\nIl peut aussi être index(remplacé|mot) par un autre à l'affichage.\n(( index ))")
    book.build

    pdeux = pdf.page(2)
    pdeux.has_text("Index")
    pdeux.has_text("indexé").with(**{font_name: 'Courier', font_size: 16, font_style: :italic})
    pdeux.has_text("1, 2").with(**{font_name:'Helvetica', font_size:8})
    pdeux.has_text("mot").with(**{font_name: 'Courier', font_size: 16})
    pdeux.has_text("2, 3").with(**{font_name:'Helvetica', font_size:8})

  end


end #/IndexPageTest
