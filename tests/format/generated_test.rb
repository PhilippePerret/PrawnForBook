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
  #
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


  def test_texte_simple_on_first_line
    return true if focus?
    GeneratedBook::Book.erase_if_exist
    resume "
    S'assure qu'une simple ligne de texte s'affiche bien sur
    la première ligne de référence.
    "  

    Object.const_set('StrucData', Struct.new(:book, :line_height, :margin_top, :margin_bot, :book_height, :texte) do
      def test
        # ===> TEST <===
        book.recipe.build_with({
          margin_top:   margin_top,
          margin_bot:   margin_bot,
          book_height:  book_height,
          line_height:  line_height,
        })
        book.build_text(texte)
        book.build

        # === VÉRIFICATION ===
        pdf.page(3).has_text(texte).at(book_height - (margin_top + line_height))        
      end
      def pdf
        @pdf ||= PDF::Checker.new(book.book_path)
      end
    end)

    StrucData.new(
      book,
      line_height = 30,
      margin_top  = 0,
      margin_bot  = 0, # la définir permet d'avoir un compte rond
      book_height = 600,
      texte       = "zéro marge et hauteur de 600 pt"
    ).test

    StrucData.new(
      book,
      line_height = 30,
      margin_top  = 40,
      margin_bot  = 40, # la définir permet d'avoir un compte rond
      book_height = 700,
      texte       = "Marge 40 et hauteur de 700 pt"
    ).test

    StrucData.new(
      book,
      line_height = 15,
      margin_top  = 20,
      margin_bot  = 20, # la définir permet d'avoir un compte rond
      book_height = 500,
      texte       = "Marges 20 et hauteur de 500"
    ).test

  end

  def test_simple_grand_titre
    # return true if focus?
    GeneratedBook::Book.erase_if_exist
    resume "
    S'assure qu'un grand titre se place bien dans la page
    "

    action "J'écris un grand titre sans autres pages"
    grand_titre = "Un Grand Titre"
    book.recipe.build_with({
      book_height:            750,
      margin_top:             0,
      margin_bot:             0, # la définir permet d'avoir un compte rond
      line_height:            30,
      titre1_on_next_page:    false,
      titre1_on_belle_page:   false,
      titre1_lines_before:    0,
      page_de_garde:          false,
      page_de_titre:          false,
      page_infos:             false,
    })
    book.build_text("# #{grand_titre}")
    book.build

    # ===> Vérifications <===
    pdf.page(1).has_text(grand_titre).at(720)
    
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
    return if focus?

    resume "
    Dans ce test, je regarde si même avec des titres, les choses
    reste bien situés au même endroit.
    "
    # return true if focus?
    GeneratedBook::Book.erase_if_exist
    line_height = 20
    grand_titre = "Un grand titre"
    ligne_apres = "Une ligne après le titre"
    autre_titre = "Autre titre"
    sous_titre  = "Un sous titre deuxième"
    autre_texte = "Une autre ligne de texte après le sous-titre pour voir."
    ligne_longue = "Et un paragraphe assez long pour voir si toutes ses lignes se posent bien sur des lignes de référence."
    book.recipe.build_with({
      line_height: line_height
    })
    book.build_text("Une ligne de texte.\n# #{grand_titre}\n#{ligne_apres}\n#{ligne_longue}\n# #{autre_titre}\n## #{sous_titre}\n#{autre_texte}")
    
    # ==> CONSTRUCTION <===
    book.build

    `open -a Preview "#{book.book_path}"`

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
