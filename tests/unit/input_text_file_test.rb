require 'test_helper'

require 'lib/required'

class InputTextFileTest < Minitest::Test

  def setup
    super
  end
  def teardown
    super
  end

  def build_main_text_with(texte)
    File.write(main_file_path, texte)    
  end

  def inputfile
    @inputfile ||= Prawn4book::PdfBook::InputTextFile.new(book, nil)
  end

  def folder
    @folder ||= mkdir(File.join(ASSETS_FOLDER, 'all_books','essais','try'))
  end

  def book
    @book ||= Prawn4book::PdfBook.new(folder)
  end

  def main_file_path
    @main_file_path ||= File.join(folder,'texte.pfb.md')    
  end

  def test_texte_simple
    resume "
    Un texte simple peut être parsé en instances de paragraphes
    "
    parags = [
      "Un paragraphe.", "Autre paragraphe.", "Troisième paragraphe."
    ]
    build_main_text_with(parags.join("\n\n"))
    actual = inputfile.paragraphes.count
    expected = 3
    assert_equal(expected, actual, "Inputfile devrait contenir #{expected} paragraphes. Il en contient #{actual}.")
    inputfile.paragraphes.each_with_index do |parag, idx|
      actual = inputfile.paragraphes[idx].text
      expected = parags[idx]
      assert_equal(expected, actual, "Le paragraphe #{idx + 1} devrait contenir #{expected.inspect}. Il contient #{actual.inspect}…")
    end
  end

  def test_les_commentaires_sont_passes
    resume "
    Le parser de texte ne prend pas les commentaires.
    "

    parags = [
      "Premier paragraphe.", "<!-- Commentaire à passer -->",
      "Autre paragraphe."
    ]
    build_main_text_with(parags.join("\n\n"))
    actual    = inputfile.paragraphes.count
    expected  = 2
    assert_equal(expected, actual, "Le texte ne devrait contenir que #{expected} paragraphes. Il en contient #{actual}.")

  end

  def test_include_text
    build_main_text_with("Un paragraphe normal\n(( include intro.pfb ))\nDernier paragraphe.")
    intro_file_path = File.join(folder, 'intro.pfb.md')
    File.write(intro_file_path, "Un paragraphe inclus\nAutre paragraphe inclus.\nUn troisième paragraphe inclus.")

    # ===> TEST <===
    # inputfile.parse # sera fait lors de l'appel inputfile.paragraphes ci-dessous

    # ===> Vérification <===
    actual = inputfile.paragraphes.count
    expected = 5
    assert_equal(expected, actual, "L'input file devrait avoir #{expected} paragraphes. Il en possède #{actual}…")

    [
      [2, "Autre paragraphe inclus."],
      [4, "Dernier paragraphe."]
    ].each do |indice, expected|
      actual = inputfile.paragraphes[indice].text
      assert_equal(expected, actual, "Le 3e paragraphe devrait être '#{expected}'. Son texte est '#{actual}'.")
    end
  end

  def test_include_raise_a_error_with_bad_path
    skip "à implémenter"
  end

  def test_include_if_texte_in_collection
    skip "à implémenter"
  end


end #/class InputTextFileTest
