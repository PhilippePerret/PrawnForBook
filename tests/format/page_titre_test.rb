=begin

  Pour lancer ce test : 

  rake test TEST=tests/format/generated_test.rb

  Je voudrais, avec ce module de test, pouvoir générer des recettes
  et des textes rapidement et construire les livres pour voir si
  tout correspond.

  S'il est bien conçu, ce module permettra de tout tester très 
  précisément, sans avoir à utiliser de longs tests.

=end
require 'test_helper'
require_relative 'generated_book/required'
class GeneratedBooPageTitreTestor < Minitest::Test

  def setup
    super
    @book = nil
  end

  def teardown
    super
  end

  def focus?
    # return false
    true
  end

  def pdf
    @pdf ||= PDF::Checker.new(book.book_path)
  end

  # Instance GeneratedBook::Book (réinitialisée à chaque test)
  def book
    @book ||= GeneratedBook::Book.new
  end


  def test_page_titre_repartie
    # return true if focus?
    GeneratedBook::Book.erase_if_exist
    resume "
    Cas normal : un livre qui contient toutes les informations 
    de titre (titre, sous-titre, collection, éditeur et logo) et 
    demande une disposition répartie présente une page conforme 
    aux attentes..
    "  

    db_collection = {
      collection_name: "La collection de livre",
    }
    db = {
      book_titre:             "Le Grand Livre",
      book_sous_titre:        "Le sous-titre du grand\\nlivre pour voir",
      book_auteur:            'Marion Michel',
      publisher_name:         'Icare éditions',
      logo:                   'logo.jpg',
      book_height:            750,
      margin_top:             20,
      margin_bot:             20, # la définir permet d'avoir un compte rond
      line_height:            30,
      page_de_garde:          true,
      page_de_titre:          true,
      page_infos:             false,
    }
    
    book.in_collection(db_collection)
    book.recipe.build_with(db)
    book.build_text("Ceci est un livre définissant sa page de titre.")
    book.build

    # ===> Vérifications <===
    pdf.page(3).has_text(db[:book_titre])#.at(720)
    pdf.page(3).has_text(db[:book_auteur])#.at(720)
    pdf.page(3).has_text(db[:publisher_name])#.at(720)
    pdf.page(3).has_image(db['logo.svg'])#.at(720)

    mini_success "La page de titre est conforme aux attentes.."
  end

  def test_book_sans_informations_raise
    return true if focus?
    GeneratedBook::Book.erase_if_exist
    resume "
    Un livre qui ne définit pas toutes les informations pour la
    page de titre ne peut pas la faire.
    "
  end

end #/class GeneratedBookTestor
