# 
# Ce test d'avril 2023 valide le travail du parseur principal
# 
# Pour le jouer :
# 
#   - ouvrir un Terminal au dossier de l'application
#   - jouer : rake test TEST=tests/unit/parser_formater_test.rb
# 
require 'test_helper'
# require './lib/required/Classes/PdfBook.rb'
# require './lib/required/Classes/PdfBook.cls.rb'
# require './lib/commandes/build/lib/parser_formater.rb'
# require './lib/required/Classes/Fonte.rb'
# require './lib/pages/page_index'

#
# Il faut tout charger pour faire ces tests
# 
require './lib/required'
Dir["./lib/commandes/build/lib/**/*.rb"].each { |m|
  # puts "Requérir : #{m.inspect}"
  require(m)
}
# exit

CLASSE = Prawn4book::PdfBook::AnyParagraph

class PseudoClassParagraphe
  attr_accessor :text
  attr_accessor :first_page, :numero
end

class ParserFormaterTest < Minitest::Test

  def setup
    super
    book_folder = File.join(ASSETS_FOLDER,'all_books','books','hello_book')
    File.exist?(book_folder) && File.directory?(book_folder) || begin
      puts "Il faut que le livre #{book_folder.inspect} existe.".rouge
      puts "Ça n'est pas le cas. Il faut le reconstruire (peu importe la recette et le texte) ou changer le livre défini ici.".rouge
      exit
    end
    CLI.components[1] = book_folder
  end

  def parag1
    @parag1 ||= begin
      PseudoClassParagraphe.new().tap do |inst|
        inst.text = "le texte du paragraphe"
        inst.first_page = 4
        inst.numero     = 1
      end
    end
  end

  def parag2
    @parag2 ||= begin
      PseudoClassParagraphe.new().tap do |inst|
        inst.text = "Paragraphe avec index:mot1, un autre index(MOT2) et un troisième index(mot3|lecanon) avec canon."
        inst.first_page = 4
        inst.numero     = 2
      end
    end
  end

  def parag3
    @parag3 ||= begin
      PseudoClassParagraphe.new().tap do |inst|
        inst.text = "Paragraphe qui contient la référence interne(( <-(refintern) ))."
        inst.first_page = 2
        inst.numero     = 3
      end
    end
  end

  def parag4
    @parag4 ||= begin
      PseudoClassParagraphe.new().tap do |inst|
        inst.text = "Paragraphe avec une cible de référence à la (( ->(refintern) ))."
        inst.first_page = 6
        inst.numero     = 4
      end
    end
  end

  def test_main_parse_method
    assert_respond_to CLASSE, :__parse
    [
      ["Une chaine sans rien à parser", "Une chaine sans rien à parser"],
      ['Code ruby simple : le résultat est #{2 + 3}', "Code ruby simple : le résultat est 5"],
      ["Méthode de l'instance : \#{text}", "Méthode de l'instance : le texte du paragraphe"],
      ["À évaluer dans l'instance : \#{text.split('').reverse.join('')}", "À évaluer dans l'instance : ehpargarap ud etxet el"],
      ["*italique*, **gras**, __souligné__ et 1^er, 2^e et 1^re", "<em>italique</em>, <b>gras</b>, <u>souligné</u> et 1<sup>er</sup>, 2<sup>e</sup> et 1<sup>re</sup>"],
    ].each do |sujet, expected, context|
      actual = CLASSE.__parse(sujet, context || {paragraph: parag1})
      if actual != expected
        puts "Problème avec #{sujet.inspect}\nAttendu: #{expected.inspect}\nObtenu: #{actual.inspect}".rouge
      end
      assert_equal(expected, actual)
    end
  end

  def test_mots_indexed
    actual = CLASSE.__parse(parag2.text, {paragraph:parag2})
    expected = "Paragraphe avec mot1, un autre MOT2 et un troisième mot3 avec canon."
    # - le texte doit avoir été corrigé -
    assert_equal(expected, actual)
    # - les 3 mots indexés doivent avoir été retenus -
    pindex = Prawn4book::PdfBook.current.page_index
    table  = pindex.table_index
    assert_equal(3, table.count, "La table des index devrait posséder 3 entrées.")
    assert(table.key?('mot1'))
    assert(table.key?('mot2'))
    refute(table.key?('mot3'))
    assert(table.key?('lecanon'))
  end

  def test_references_internes
    actual   = CLASSE.__parse(parag3.text, {paragraph:parag3})
    expected = "Paragraphe qui contient la référence interne."
    assert_equal(expected, actual)
    actual = CLASSE.__parse(parag4.text, {paragraph:parag4})
    expected = "Paragraphe avec une cible de référence à la page 2."
    assert_equal(expected, actual)
    # - les références doivent être mémorisées -
    # TODO
  end

end #/class Minitest
