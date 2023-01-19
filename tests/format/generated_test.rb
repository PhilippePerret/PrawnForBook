=begin

  Pour lancer ce test : 

  rake test TEST=tests/format/generated_test.rb

=end
require 'test_helper'
require_relative 'generated_book/required'
class GeneratedBookTestor < Minitest::Test

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


  def test_texte_simple_on_first_line
    return true if focus?
    resume "
    S'assure qu'une simple ligne de texte s'affiche bien sur
    la première ligne de référence (avec plusieurs réglages 
    différents).
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
        pdf.page(1).has_text(texte).at(book_height - (margin_top + line_height))        
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
    assert(true)
    mini_success "Sans marge le texte se positionne bien tout au-dessus"

    StrucData.new(
      book,
      line_height = 30,
      margin_top  = 40,
      margin_bot  = 40, # la définir permet d'avoir un compte rond
      book_height = 700,
      texte       = "Marge 40 et hauteur de 700 pt"
    ).test
    assert(true)
    mini_success "Avec une marge une simple ligne se place bien au-dessus"

    StrucData.new(
      book,
      line_height = 15,
      margin_top  = 20,
      margin_bot  = 20, # la définir permet d'avoir un compte rond
      book_height = 500,
      texte       = "Marges 20 et hauteur de 500"
    ).test
    assert(true)
    mini_success "Avec une autre marge et une autre auteur de ligne le texte simple se place bien."

  end

  def tester_le_texte_moyen_avec(props)
    # - Préparation -
    h     = props[:height]
    mtop  = props[:top_margin]
    hline = props[:line_height]
    size  = props[:font_size]
    resume "
    Test du placement des textes en variant la hauteur de page (#{h}),
    la marge haute (#{mtop}), la hauteur de ligne (#{hline}) et la taille de police (#{size})
    "
    # ===> TEST <===
    recipe = Factory::Recipe.new(book.folder)
    recipe.build_with(**props)
    book.build_text(Factory::Text.text_moyen)
    book.build
    # ===> VÉRIFICATIONS <===
    # -
    pageun = pdf.page(1)
    assert_equal(h, pageun.height, "La page devrait faire #{h}, elle fait #{pageun.height.inspect}.")
    # pageun.has_text("Ceci est un texte").at(475)  # height - mtop - line_height
    pageun.not.has_text("Ceci est un texte").at(h - mtop - hline + 10)
    pageun.not.has_text("Ceci est un texte").at(h - mtop - hline)
    # pageun.has_text("paragraphes.").at(460)
    pageun.has_text("paragraphes.").at(h - mtop - 2 * hline)
    # pageun.has_text("Il doit permettre").at(445)
    pageun.has_text("Il doit permettre").at(h - mtop - 3 * hline)
    # pageun.has_text("positionnement.").at(430)
    pageun.has_text("positionnement.").at(h - mtop - 4 * hline)
    # pageun.has_text("Contrairement à un long texte,").at(415) # 3 lignes
    pageun.has_text("Contrairement à un long texte,").at(h - mtop - 5 * hline) # 3 lignes
    # pageun.has_text("On se croirait dans du Proust !").at(370)
    pageun.not.has_text("On se croirait dans du Proust !").at(10 + h - mtop - 8 * hline)
    pageun.has_text("On se croirait dans du Proust !").at(h - mtop - 8 * hline)
    mini_success "Le texte est parfaitement disposé sur la page 1."
  end

  def test_placement_sur_lignes_reference_base
    # return if focus?
    tester_le_texte_moyen_avec(**{height: 500, line_height:15, font_size:7, indent:0, top_margin:10})
  end

  def test_placement_sur_lignes_reference_reduction_page
    # return if focus?
    tester_le_texte_moyen_avec(**{height: 400, line_height:10, font_size:9, indent:0, top_margin:10})
  end

  def test_placement_sur_lignes_reference_reduction_police
    # return if focus?
    tester_le_texte_moyen_avec(**{height: 400, line_height:10, font_size:7, indent:0, top_margin:10})
  end

  def test_placement_sur_lignes_reference_grande_line_height
    # return if focus?
    tester_le_texte_moyen_avec(**{height: 400, line_height:40, font_size:12, indent:0, top_margin:10})
  end

  def test_placement_sur_lignes_reference_grande_line_height_et_page
    # return if focus?
    tester_le_texte_moyen_avec(**{height: 800, line_height:40, font_size:11, indent:0, top_margin:20})
  end



end #/class GeneratedBookTestor
