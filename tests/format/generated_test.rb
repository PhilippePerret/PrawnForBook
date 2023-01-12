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
class GeneratedBookTestor < Minitest::Test

  # Instance GeneratedBook::Book (réinitialisée à chaque test)
  attr_reader :book

  def setup
    super
    @book = GeneratedBook::Book.new
  end

  def teardown
    super
  end

  def focus?
    true
  end

  def pdf
    @pdf ||= PDF::Checker.new(book.book_path)
  end

  def test_book_is_built_only_with_simple_text
    return if focus?
    resume "
    On peut construire un livre avec un simple fichier texte
    de nom 'texte.pfb.md'
    "
    book.build
  end

  def test_book_with_line_height
    return true if focus?
    GeneratedBook::Book.erase_if_exist
    line_height = 30
    margin_top  = (20.mm).round(3)
    book.recipe.build_with({
      leading:      0, 
      line_height:  line_height,
    })
    book.build_text(:plusieurs_lignes)
    # ===> TEST <===
    book.build

    # --- Vérifications ---
    PDF::Checker.set_config(top_based: true)
    pagetrois = pdf.page(3)
    top = pagetrois.height
    puts "top = #{top.inspect}"
    (0..5).each do |i|
      puts "ligne #{i} : #{top - (i * line_height) + margin_top} (#{i * line_height  + margin_top})"
    end
    pagetrois.has_font("Times-Roman").with(**{size: 10})
    pagetrois.has_text("Bonjour tout le monde").at(20.mm)
    pagetrois.has_text("On trouve donc une première ligne").at(20.mm + 3 * line_height)
    pagetrois.has_text("La ligne très courte").at(20.mm + 4 * line_height)
  end

  def test_book_with_titre
    resume "
    Dans ce test, je regarde si même avec des titres, les choses
    reste bien situés au même endroit.
    "
    # return true if focus?
    GeneratedBook::Book.erase_if_exist
    line_height = 25
    grand_titre = "Un grand titre"
    ligne_apres = "Une ligne après le titre"
    book.recipe.build_with({
      leading:0,
      line_height: line_height
    })
    book.build_text("Une ligne de texte.\n# #{grand_titre}\n#{ligne_apres}")
    
    # ==> CONSTRUCTION <===
    book.build

    # --- Calculs ---
    ptrois  = pdf.page(3)
    pquat   = pdf.page(4)
    page_height = ptrois.height.freeze
    top_margin    = 20.mm
    margin_top    = (top_margin).round(3)
    hauteur_base  = page_height - top_margin
    puts "Hauteur de page : #{page_height.inspect}"
    puts "Top de base : #{hauteur_base.inspect}"
    puts "Position des lignes de référence :"
    puts( (0..20).map do |iline|
      (hauteur_base - (iline * line_height)).round
    end.join(", ") )

    # --- Vérifications ---

    action "Par défaut, un titre de premier niveau se met sur une nouvelle page"
    ptrois.not.has_text(grand_titre)
    pquat.has_text(grand_titre).at(hauteur_base)
    pquat.has_text(ligne_apres).at(hauteur_base + 2 * line_height)

  end


  def test_titre_bas_de_page
    return true if focus?
    GeneratedBook::Book.erase_if_exist

    resume "
    Ce texte s'assure du bon traitement d'un titre qui se retrouverait
    seul en bas de page.
    "
    
  end

  def test_simple_book
    return true if focus?
    # 
    # HOT: L'idée, en travaillant ce test, et de voir les données
    # minimales qu'il faut fournir pour pouvoir construire un livre
    # Dans l'idéal, seul le texte devrait être nécessaire
    props = {margin: 10.mm}
    book.recipe.build_with(**props)
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
