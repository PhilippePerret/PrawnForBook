=begin

  Pour lancer ce test : 

  rake test TEST=tests/format/numerotation_test.rb

  Pour tester toutes les numérotations en faisant un essai grandeur
  nature avec :
    - une table des matières
    - un index
    - une bibliographie
    - pied de page avec numéro de page/paragraphe
  Avec au choix :
    - la numérotation par page
    - la numérotation par paragraphe

  TODO
    J'en suis à 
=end
require 'test_helper'
require_relative 'generated_book/required'
class NumerotationTestor < Minitest::Test

  def setup
    super
    @book = nil
  end

  def teardown
    super
  end

  def focus?
    true # pour jouer seulement celui qui commente sa 1re ligne
    # false # pour les jouer tous
  end

  def pdf
    @pdf ||= PDF::Checker.new(book.book_path)
  end

  # Instance GeneratedBook::Book (réinitialisée à chaque test)
  def book
    @book ||= begin
      GeneratedBook::Book.erase_if_exist
      GeneratedBook::Book.new
    end
  end

  def tester_un_livre_avec(props)
    # - Préparation -
    props.merge!({
      page_de_garde:        true,  # pour voir si pas de numérotation
      page_de_titre:        true,  # idem
      numeroter_titre:      true,  # TODO Rendre opérationnel
      titre1_on_next_page:  true,
      logo:                 'logo.jpg', 
    })
    resume "
    Test de la numérotation du livre
    "
    # ===> TEST <===
    recipe = Factory::Recipe.new(book.folder)
    recipe.build_with(**props)
    book.build_text(Factory::Text.long_text_with_tdm_and_index)
    book.build
    # ===> VÉRIFICATIONS <===
    # -

    mini_success "XXX"
  end

  def tester_numerotation_par_page_avec(props)
    props.merge!(numerotation: 'pages')
    tester_un_livre_avec(props)
  end
  def tester_numerotation_par_paragraphes_avec(props)
    props.merge!(numerotation: 'parags')
    tester_un_livre_avec(props)
  end

  def test_simple_valeurs_par_defaut_num_page
    return if focus?
    tester_numerotation_par_page_avec({})
  end

  def test_simple_valeurs_par_defaut_num_paragraphs
    # return if focus?
    tester_numerotation_par_paragraphes_avec({})
    page(10).has_text("Non anim in nulla proident").at(576 - 10 - 14)
  end

  def page(x)
    pdf.page(x)
  end

end #/class GeneratedBookTestor
