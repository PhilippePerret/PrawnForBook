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


  def test_texte_simple_on_first_line
    return true if focus?
    GeneratedBook::Book.erase_if_exist
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
    mini_success "Sans marge le texte se positionne bien tout au-dessus"

    StrucData.new(
      book,
      line_height = 30,
      margin_top  = 40,
      margin_bot  = 40, # la définir permet d'avoir un compte rond
      book_height = 700,
      texte       = "Marge 40 et hauteur de 700 pt"
    ).test
    mini_success "Avec une marge une simple ligne se place bien au-dessus"

    StrucData.new(
      book,
      line_height = 15,
      margin_top  = 20,
      margin_bot  = 20, # la définir permet d'avoir un compte rond
      book_height = 500,
      texte       = "Marges 20 et hauteur de 500"
    ).test
    mini_success "Avec une autre marge et une autre auteur de ligne le texte simple se place bien."

  end

  def test_simple_grand_titre
    return true if focus?
    GeneratedBook::Book.erase_if_exist
    resume "
    S'assure qu'un grand titre sans lignes avant (lines_before = 0)
    se place bien tout en haut de dans la page.
    "

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
    mini_success "Le grand titre s'est bien écrit sur une unique page."
  end


  def test_simple_titre_avec_lines_before
    return true if focus?
    GeneratedBook::Book.erase_if_exist
    resume "
    S'assure qu'un grand titre se place bien dans la page avec
    des lignes avant (lines_before = 4)
    "

    grand_titre = "Un Grand Titre"
    book.recipe.build_with({
      book_height:            750,
      margin_top:             0,
      margin_bot:             0, # la définir permet d'avoir un compte rond
      line_height:            30,
      titre1_on_next_page:    false,
      titre1_on_belle_page:   false,
      titre1_lines_before:    4,
      page_de_garde:          false,
      page_de_titre:          false,
      page_infos:             false,
    })
    book.build_text("# #{grand_titre}")
    book.build

    # ===> Vérifications <===
    pdf.page(1).has_text(grand_titre).at(720 - 4 * 30)
    mini_success "Le grand titre s'est bien écrit avec des lignes avant."
  end
    

  def test_simple_grand_titre_suivi_de_texte_sans_espace
    return true if focus?
    GeneratedBook::Book.erase_if_exist
    resume "
    S'assure qu'un grand titre se place bien dans la page ainsi que
    le texte qui le suit avec 0 lignes entre les deux.
    "

    line_height = 30
    grand_titre = "Un Grand Titre"
    texte_part1 = "Un long texte pour voir"
    texte = "#{texte_part1} comment il va s'afficher de ligne en ligne sous le titre"
    book.recipe.build_with({
      book_height:            750,
      margin_top:             0,
      margin_bot:             0, # la définir permet d'avoir un compte rond
      line_height:            line_height,
      titre1_on_next_page:    false,
      titre1_on_belle_page:   false,
      titre1_lines_before:    0,
      titre1_lines_after:     0,
      page_de_garde:          false,
      page_de_titre:          false,
      page_infos:             false,
    })
    book.build_text("# #{grand_titre}\n\n#{texte}")
    book.build

    # ===> Vérifications <===
    assert(File.exist?(book.book_path), "Le PDF du livre devrait exister.")
    pdf.page(1).has_text(grand_titre).at(750 - line_height)
    pdf.page(1).has_text(texte_part1).at(720 - line_height)
    mini_success "Le titre et le texte juste après se sont bien écrits."
  end


  def grand_titre_et_texte_no_margin_no_line_before(height, line_height)
    GeneratedBook::Book.erase_if_exist
    resume "
    S'assure qu'un grand titre se place bien dans la page et que le
    texte qui le suit se place bien 3 lignes plus loin (valeur par 
    défaut du lines_after du titre 1) avec height = #{height} et
    line_height = #{line_height}.
    " 

    grand_titre = "Un Grand Titre"
    texte_part1 = "Un long texte pour voir"
    texte = "#{texte_part1} comment il va s'afficher de ligne en ligne sous le titre"
    book.recipe.build_with({
      book_height:            height,
      margin_top:             0,
      margin_bot:             0, # la définir permet d'avoir un compte rond
      line_height:            line_height,
      titre1_on_next_page:    false,
      titre1_on_belle_page:   false,
      titre1_lines_before:    0,
      page_de_garde:          false,
      page_de_titre:          false,
      page_infos:             false,
    })
    book.build_text("# #{grand_titre}\n\n#{texte}")
    book.build

    # ===> Vérifications <===
    pdf.page(1).has_text(grand_titre).at(height - line_height)
    pdf.page(1).has_text(texte_part1).at(height -  5 * line_height)
    mini_success "Le grand titre et le texte sont placés."
  end


  def test_simple_grand_titre_suivi_de_texte_with_lines_after_default
    return true if focus?
    line_height = 25
    height      = 700
    grand_titre_et_texte_no_margin_no_line_before(height, line_height)
  end

  def test_sgtsdtwlad_deux
    return true if focus?
    line_height = 27
    height      = 654
    grand_titre_et_texte_no_margin_no_line_before(height, line_height)
  end


  def titre_1_et_2_dans_page_seule(
    height:, 
    line_height:, 
    titre1_lines_after:,
    titre2_lines_before:
  )
    GeneratedBook::Book.erase_if_exist
    resume "
    S'assure qu'un grand titre et un sous-titre se placent bien 
    avec height = #{height} et line_height = #{line_height}.
    lorsque line_after de grand titre est #{titre1_lines_after} et les
    lignes avant de titre 2 sont #{titre2_lines_before}.
    Quels que soient les réglages du nombres de lignes avant le sous-
    titre, seules les lignes après du titre s'appliquent.
    " 

    grand_titre = "Un Grand Titre"
    sous_titre  = "Un sous-titre"
    book.recipe.build_with({
      book_height:            height,
      margin_top:             0,
      margin_bot:             0, # la définir permet d'avoir un compte rond
      line_height:            line_height,
      titre1_on_next_page:    false,
      titre1_on_belle_page:   false,
      titre1_lines_before:    0,
      titre1_lines_after:     titre1_lines_after,
      titre2_lines_before:    titre2_lines_before,
      page_de_garde:          false,
      page_de_titre:          false,
      page_infos:             false,
    })
    book.build_text("# #{grand_titre}\n## #{sous_titre}")
    book.build

    # ===> Vérifications <===
    line_titre = height - line_height
    # titre1_lines_after = 1 if titre1_lines_after == 0
    pdf.page(1).has_text(grand_titre).at(line_titre)
    pdf.page(1).has_text(sous_titre).at(line_titre - (titre1_lines_after + 1) * line_height)
    mini_success "Le grand titre et le sous-titre sont bien placés."
  end

  def test_1_titre_1_et_2_dans_page_seule
    return true if focus?
    data = {
      height: 600,
      line_height: 25,
      titre1_lines_after: 0,
      titre2_lines_before: 0,
    }
    titre_1_et_2_dans_page_seule(**data)
  end

  def test_2_titre_1_et_2_dans_page_seule
    return true if focus?
    data = {
      height: 600,
      line_height: 25,
      titre1_lines_after: 1,
      titre2_lines_before: 0,
    }
    titre_1_et_2_dans_page_seule(**data)
  end

  def test_3_titre_1_et_2_dans_page_seule
    return true if focus?
    data = {
      height: 700,
      line_height: 20,
      titre1_lines_after: 4,
      titre2_lines_before: 0,
    }
    titre_1_et_2_dans_page_seule(**data)
  end

  def test_4_titre_1_et_2_dans_page_seule
    return true if focus?
    resume "(Annulation du lines_before du sous-titre)"
    data = {
      height: 700,
      line_height: 20,
      titre1_lines_after: 4,
      titre2_lines_before: 4, # <=== annulé par lines_after
    }
    titre_1_et_2_dans_page_seule(**data)
  end

  def test_5_titre_1_et_2_dans_page_seule
    return true if focus?
    resume "(Annulation du lines_before du sous-titre)"
    data = {
      height: 700,
      line_height: 20,
      titre1_lines_after: 0,
      titre2_lines_before: 4, # <=== annulé par lines_after
    }
    titre_1_et_2_dans_page_seule(**data)
  end








  def titre_higher_than_line_height(
    height:, line_height:, titre1_font_size:, margin_top:
  )
    GeneratedBook::Book.erase_if_exist
    resume "
    S'assure que le texte après un titre plus grand qu'une
    hauteur de ligne soit bien placé.
    "

    grand_titre = "Un Grand Titre"
    texte       = "Le texte qui suit le grand titre"
    book.recipe.build_with({
      book_height:            height,
      margin_top:             margin_top,
      margin_bot:             0, # la définir permet d'avoir un compte rond
      line_height:            line_height,
      titre1_on_next_page:    false,
      titre1_on_belle_page:   false,
      titre1_lines_before:    0,
      titre1_lines_after:     0,
      titre1_font_size:       titre1_font_size,
      page_de_garde:          false,
      page_de_titre:          false,
      page_infos:             false,
    })
    book.build_text("# #{grand_titre}\n#{texte}")
    book.build

    # ===> Vérifications <===
    line_titre = (height - margin_top) - 2 * line_height # <== c'est ici que se trouve le truc
    pdf.page(1).has_text(grand_titre).at(line_titre)
    pdf.page(1).has_text(texte).at(line_titre - line_height)
    mini_success "Grand titre et texte bien placés."


  end

  def test_1_titre_higher_than_line_height
    return true if focus?
    titre_higher_than_line_height(**{
      height: 400,
      line_height: 10,
      titre1_font_size: 20,
      margin_top: 0,
    })
  end

  def test_2_titre_higher_than_line_height
    return true if focus?
    titre_higher_than_line_height(**{
      height: 400,
      line_height: 20,
      titre1_font_size: 30,
      margin_top: 40,
    })
  end




  # TODO: Test du découpe du paragraphe en plusieurs lignes,
  # pour voir si chaque ligne se positionnera bien en fonction
  # du line_height

  # TODO: Essayer de générer une erreur lorsque le line_height
  # est trop petit par rapport à la font par défaut (on doit tester
  # line_height par rapport à pdf.height_of(texte_par_defaut))

  # TODO: Test d'un titre trop bas dans la page => il doit passer
  # sur la page suivante
  # Faut-il un paramètre "lié au paragraphe suivant" ?

  # TODO: Avec un positionnement forcé dans le texte lui-même
  # * en utilisant '(( move_down(5) ))' pour dire "descendre de
  #   5 lignes de référence"
  # * en utilisant '(( move_to(10) ))' pour dire "se positionner
  #   sur la 10e ligne de référence"
  # 

  

end #/class GeneratedBookTestor
