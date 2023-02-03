require 'test_helper'

# On requiert le minimum
require 'lib/required'

require 'tests/format/generated_book/required'

class Praw4bookFontesTest < Minitest::Test

  def setup
    super
    Prawn4book::Fonte.reset
    Prawn4book::PdfBook.reset if defined?(Prawn4book::PdfBook)
  end

  def teardown
    super
  end

  def focus?
    false
    # true
  end

  # @param [String] test_name Le nom du test, au cas où
  # @param [Hash] props Les données à mettre dans la recette du livre
  # @param [Block] &block Le bloc à jouer
  def book_current_with_recipe(test_name, props, &block)
    gbook   = GeneratedBook::Book.new(test_name)
    recipe  = Factory::Recipe.new(gbook.folder)
    recipe.build_with(**props)
    assert(File.exist?(recipe.path), "Le fichier recette devrait exister (à l'adresse #{recipe.path.inspect})…")
    book = Prawn4book::PdfBook.new(gbook.folder)
    if block_given?
      Dir.chdir(book.folder) do
        assert(Prawn4book::PdfBook.current?, "Il devrait y avoir un livre courant.")
        yield
      end
    end
  end

  # Méthode de test s'assurant que la fonte +fonte+ possède bien les
  # données +values+
  # 
  # @param [Prawn4book::Fonte] fonte L'instance de la fonte
  # @param  [Array] values Les valeurs : [name, style, size]
  #         [Hash]  values            ou {:name, :style, :size}
  def assert_la_fonte(fonte, values)
    assert_instance_of(Prawn4book::Fonte, fonte) 
    if values.is_a?(Array)
      values = {name: values[0], style: values[1], size: values[2]}
    end
    values.each do |prop, expected|
      actual = fonte.send(prop)
      assert_equal(expected, actual, "La propriété #{prop.inspect} de la fonte devrait être #{expected.inspect}. Elle vaut #{actual.inspect}.")
    end
  end

  # --- TESTS METHODS ---

  def test_default_default_font_valide
    return if focus?
    resume "
    Quand rien du tout n'est défini, une fonte par
    défaut existe quand même
    "
    assert(Prawn4book::Fonte.default_fonte, "Il devrait toujours exister une fonte par défaut.")
    deff = Prawn4book::Fonte.default_fonte
    assert_instance_of(Prawn4book::Fonte, deff)
    assert_la_fonte(deff, ["Times-Roman", :roman, 11])
  end

  def test_default_font_valide
    return if focus?
    resume "
    Quand une première fonte est définie, c'est elle qui
    est retournée comme font par défaut.
    "
    props = {
      no_default: true,
      fonts: {
        'Avenir': {
          normal: "/System/Library/Fonts/Avenir Next.ttc",
          condensed: "/System/Library/Fonts/Avenir Next Condensed.ttc",
        }
      },
      font_size: 15,
    }
    book_current_with_recipe(self.name, props) do
      deff = Prawn4book::Fonte.default_fonte
      assert_instance_of(Prawn4book::Fonte, deff)
      assert_la_fonte(deff, ["Avenir", :normal, 15])
    end
  end

  def test_font_title1
    return if focus?
    resume "
    La fonte pour le titre de niveau 1 est toujours définie, même 
    lorsque rien n'est défini.
    "
    fo = Prawn4book::Fonte.titre1
    assert_la_fonte(fo, ['Helvetica', :bold, 24.5])
  end

  def test_font_title1_defined_in_recipe
    # return if focus?
    resume "
    La fonte pour le titre de niveau 1 à 3 peut être définie
    par la recette, même partiellement.
    "
    props = {
      no_default: true,
      fonts: {
        'Avenir': {
          normal: "/System/Library/Fonts/Avenir Next.ttc",
          condensed: "/System/Library/Fonts/Avenir Next Condensed.ttc",
        },
        'AvenirTitre': {
          regular: "/System/Library/Fonts/Avenir Next.ttc",
          bold: "/System/Library/Fonts/Avenir Next.ttc",
          italic: "/System/Library/Fonts/Avenir Next Condensed.ttc",
        }
      },
      titles: {
        level1: {font:'AvenirTitre', size: 50, style: :italic},
        level2: {font:'AvenirTitre', size: 40},
        level3: {font:'AvenirTitre', style: :regular},
      }
    }
    book_current_with_recipe(self.name, **props) do
      # - On est dans le dossier du livre -
      # - Définition complète du titre1 -
      fo = Prawn4book::Fonte.title1
      assert_la_fonte(fo, ["AvenirTitre", :italic, 50])
      # - Définition incomplète du titre 2 (sans style) -
      fo = Prawn4book::Fonte.title2
      assert_la_fonte(fo, ["AvenirTitre", :bold, 40])
      # - Définition incomplète du titre 3 (sans size) -
      fo = Prawn4book::Fonte.title3
      assert_la_fonte(fo, ["AvenirTitre", :regular, 20.5])
    end
  end

  def test_font_other_titles
    # return if focus?
    resume "La fonte pour les autres titres est toujours définie"
    (4..7).each do |niveau|
      fo = Prawn4book::Fonte.send("titre#{niveau}".to_sym)
      assert_la_fonte(fo, ['Helvetica', :bold, 24.5 - (niveau-1) * 2])
      fo = Prawn4book::Fonte.send("title#{niveau}".to_sym)
      assert_la_fonte(fo, ['Helvetica', :bold, 24.5 - (niveau-1) * 2])
    end
  end

  def test_title_method
    assert_respond_to(Prawn4book::Fonte, :title)
    fo = Prawn4book::Fonte.title(1)
    assert_equal(Prawn4book::Fonte.title1, fo)
  end

end
