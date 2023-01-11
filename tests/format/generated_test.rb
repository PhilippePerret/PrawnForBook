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

  def pdf
    @pdf ||= PDF::Checker.new(book.book_path)
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
    props = {margin: 10.mm}
    book.build_recipe_with(**props)
    # ===> TEST <===
    book.build
    # --- Vérification ---
    # Hauteur du livre
    page_height = pdf.page(1).height.freeze 
    # hauteur de page (que j'ai défini par défaut à 203.2mm)
    top_margin  = 20.mm
    # Marge top que j'ai défini à 20mm
    puts "HAUTEUR PAGE - MARGE HAUT = #{page_height - 20.mm} (#{(page_height - 200.mm).to_mm})"
    hauteur_base = page_height - top_margin
    # => hauteur par défaut de la page + marge haut par défaut

    # # Obtenir les marges (PAS ENCORE)
    # puts "attributes : #{pdf.page(3).reader_page.attributes.inspect}"
    # puts "Marges : #{pdf.page(3).reader_page.margins.inspect}"

    action "Le texte 'Bonjour tout le monde doit se trouver sur la 3e page, en haut."
    pdf.page(3).has_text("Bonjour tout le monde").at(hauteur_base)

    # TODO Jouer tout de suite sur le leading pour voir si ça va 
    # fonctionner. MAIS AVANT il faut s'occuper de build_recipe du 
    # #book qui va permettre de définir la recette dynamiquement.

  end

end #/class GeneratedBookTestor
