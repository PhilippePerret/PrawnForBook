# 
# Ce test d'avril 2023 valide le travail du parseur principal
# 
# Il travaille "hors" de l'application, en appelant simplement la
# méthode Prawn4book::PdfBook::AnyParagraph.__parse avec un faux
# paragraphe (instance capable de renvoyer @text, @first_page et
# @numéro).
# 
# Pour le jouer :
# 
#   - ouvrir un Terminal au dossier de l'application
#   - jouer : rake test TEST=tests/unit/parser_formater_test.rb
# 
require 'test_helper'

#
# Il faut tout charger pour faire ces tests
# 
require './lib/required'
Dir["./lib/commandes/build/lib/**/*.rb"].each { |m| require(m) }
require 'lib/pages/bibliographies'

# - raccourci -
CLASSE = Prawn4book::PdfBook::AnyParagraph

#
# Pseudo classe pour les paragraphes
# (pour bénéficier de certaines méthodes sans avoir à tout initialiser)
# 
class PseudoClassParagraphe
  attr_accessor :text
  attr_accessor :first_page, :numero
  attr_accessor :class_tags
end

class ParserFormaterTest < Minitest::Test

  def setup
    super
    book_folder = File.join(ASSETS_FOLDER,'all_books','books','hello_book')
    File.exist?(book_folder) && File.directory?(book_folder) || begin
      puts "Il faut que le livre #{book_folder.inspect} existe.".rouge
      puts "Ça n'est pas le cas. Il faut le reconstruire (avec une recette définissant le livre externe) ou changer le livre défini ici.".rouge
      exit
    end
    Prawn4book::PdfBook.current = Prawn4book::PdfBook.new(book_folder)
    #
    # On requiert tous les formateurs
    # 
    require 'lib/commandes/build/build'
    pdfbook.require_custom_parsers_formaters
    #
    # On donne le dossier à la ligne de commande
    # 
    CLI.components[1] = book_folder
    #
    # Initialisation des bibliographies
    # 
    Prawn4book::Bibliography.init
  end

  # - raccourci vers le book courant -
  def pdfbook
    Prawn4book::PdfBook.current
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

  def parag5
    @parag5 ||= begin
      PseudoClassParagraphe.new().tap do |inst|
        inst.text = "Paragraphe avec une cible de référence croisée à la (( ->(livre_externe:cible_externe) ))."
        inst.first_page = 6
        inst.numero     = 5
      end
    end
  end

  def parag6
    @parag6 ||= begin
      PseudoClassParagraphe.new().tap do |inst|
        inst.text = "Référence croisée vers un livre non défini à la (( ->(unknown_book:cible_externe) ))."
        inst.first_page = 7
        inst.numero     = 6
      end
    end
  end

  def parag7
    @parag7 ||= begin
      PseudoClassParagraphe.new().tap do |inst|
        inst.text = "Référence croisée vers un livre défini mais une référence non définie à la (( ->(livre_externe:unknown_target) ))."
        inst.first_page = 12
        inst.numero     = 7
      end
    end
  end

  def parag8
    @parag8 ||= begin
      PseudoClassParagraphe.new().tap do |inst|
        inst.text = "Un firstbiblio(lien_bibliographique) personnalisé et un autre firstbiblio(lien_bibliographique)."
        inst.first_page = 12
        inst.numero     = 8
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
    pindex = pdfbook.page_index
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
    table = pdfbook.table_references
    expected = {paragraph:3, page:2}
    actual = table.table[:refintern]
    assert_equal(expected, actual, "La table de référence devrait bien définir la référence :refintern. Elle contient #{table.table.inspect}.")
  end

  def test_bad_cross_reference_with_unknown_book
    err = assert_raises(PrawnBuildingError){CLASSE.__parse(parag6.text, {paragraph:parag6})}
    expected = "Le livre d'identifiant 'unknown_book' n'est pas défini pour les références croisées…"
    actual = err.message
    assert_equal(expected, actual)
  end
  def test_bad_cross_reference_with_unknown_target
    err = assert_raises(PrawnBuildingError){CLASSE.__parse(parag7.text, {paragraph:parag7})}
    expected = "La référence 'unknown_target' dans le livre identifié 'livre_externe' est inconnue."
    actual = err.message
    assert_equal(expected, actual)
  end

  def test_good_cross_reference
    actual   = CLASSE.__parse(parag5.text, {paragraph:parag5})
    expected = "Paragraphe avec une cible de référence croisée à la page 12 de <i>Mon beau livre externe</i>."
    assert_equal(expected, actual)
    # - la référence doit être mémorisée -
    # TODO    
  end

  def test_bibliographie
    #
    # Le texte est bien corrigé
    # 
    actual = CLASSE.__parse(parag8.text, {paragraph:parag8})
    expected = "Un lien bibliographique personnalisé et un autre lien bibliographique."
    assert_equal(expected, actual)
    #
    # La bibliography existe
    # 
    biblio = Prawn4book::Bibliography.get('firstbiblio')
    assert(biblio, "La bibliographie 'firstbiblio' devrait exister.")
    # - le lien bibliographique doit avoir été mémorisé -
    bibitem = biblio.get('lien_bibliographique')
    assert_instance_of(Prawn4book::Bibliography::BibItem, bibitem)
    occs = bibitem.occurrences
    assert_equal(1, occs.count, "Il ne devrait y avoir qu'une seule occurrence (même paragraphe)")
    expected = {page:12, paragraph:8}
    actual   = occs.first
    assert_equal(expected, actual)
  end

  def parag10
    @parag10 ||= begin
      PseudoClassParagraphe.new().tap do |inst|
        inst.text = "Je cite livre(Narration) pour la première fois."
        inst.first_page = 13
        inst.numero     = 10
      end
    end
  end

  def parag11
    @parag11 ||= begin
      PseudoClassParagraphe.new().tap do |inst|
        inst.text = "Je cite à nouveau livre(Narration) à moins de 10 pages."
        inst.first_page = 13
        inst.numero     = 11
      end
    end
  end

  def parag12
    @parag12 ||= begin
      PseudoClassParagraphe.new().tap do |inst|
        inst.text = "Je cite encore livre(Narration) à plus de 10 pages."
        inst.first_page = 24
        inst.numero     = 12
      end
    end
  end

  def test_custom_bibliography
    #
    # Test pour voir le formatage personnalisé d'une bibliographie
    # Sans autre définition, une bibliographie remplace simplement la
    # marque par le titre (@title) de l'item de bibliographie. Mais
    # on peut obtenir un traitement beaucoup plus fin.
    # 
    # Ici, on va tester avec les livres (bibliographie "livre") avec 
    # un formater assez complexe qui tient compte de présence du livre
    # avec ces conditions :
    #   - si c'est la première apparition, le livre indique l'auteur,
    #     et l'année (premier formatage)
    #   - si c'est une autre apparition à moins de 10 pages, on indique
    #     seulement le titre (deuxième formatage)
    #   - si c'est une ré-apparition à plus de 10 pages, on remet l'année
    #     (troisième formatage)
    # 
    actual   = CLASSE.__parse(parag10.text, {paragraph: parag10})
    expected = "Je cite <i>Narration</i> (Philippe Perret, 2023) pour la première fois."
    assert_equal(expected, actual)

    actual   = CLASSE.__parse(parag11.text, {paragraph: parag11})
    expected = "Je cite à nouveau <i>Narration</i> à moins de 10 pages."
    assert_equal(expected, actual)

    actual   = CLASSE.__parse(parag12.text, {paragraph: parag12})
    expected = "Je cite encore <i>Narration</i> (Perret, 2023) à plus de 10 pages."
    assert_equal(expected, actual)
  end

  def parag9
    @parag9 ||= begin
      PseudoClassParagraphe.new().tap do |inst|
        inst.text = "Ce texte possède du reformate(formatage particulier) de mot. Il reformate(reformate) certains mots en les gardant."
        inst.first_page = 13
        inst.numero     = 9
      end
    end
  end

  def test_custom_parser
    actual = CLASSE.__parse(parag9.text, {paragraph:parag9})
    expected = "Ce texte possède du <font name=\"Courrier\" size=\"12\">formatage particulier</font> de mot. Il <font name=\"Courrier\" size=\"12\">reformate</font> certains mots en les gardant."
    assert_equal(expected, actual)
    #
    # Le mot a été conservé 
    # 
    liste = CLASSE.liste_formatage
    assert_equal(2, liste.count, "La liste de capture des mots devrait en contenir 2")
    assert(liste.key?('formatage particulier'))
    assert(liste.key?('reformate'))
    assert_equal({page:13, paragraph:9}, liste['formatage particulier'])
    assert_equal({page:13, paragraph:9}, liste['reformate'])
  end


  def parag14
    @parag14 ||= begin
      PseudoClassParagraphe.new().tap do |inst|
        inst.text = "gras::italic::Mon texte avec des class-tags."
        inst.first_page = 16
        inst.numero     = 14
      end
    end
  end

  def test_class_tags
    context = {paragraph:parag14}
    actual = CLASSE.__parse(parag14.text, context)
    expected = "<i><b>Mon texte avec des class-tags.</b></i>"
    assert_equal(expected, actual)
  end

end #/class Minitest
