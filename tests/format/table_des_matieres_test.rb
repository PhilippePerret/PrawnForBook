=begin

  Pour tester tout ce qui concerne la table des matières du 
  livre

  TODO
    * Faire des tests plus précis :
      - pour voir les positionnements
      - en modificants les valeurs par défaut
        (cf. abstract_recipe pour ajouter les clés de correspondance)
=end
require 'test_helper'
require_relative 'generated_book/required'

class TableDesMatieresTest < Minitest::Test

  def setup
    super
  end
  def teardown
    super
  end


  # Pour se concentrer sur un test en particulier
  # Utiliser 'return if focus?' en début des tests sauf celui qu'on
  # travaille.
  def focus?
    true
    # false # pour jouer tous les tests
  end

  # Le livre généré (spécial pour les tests)
  # @note
  #   On s'assure qu'il n'existe pas physiquement à l'instanciation 
  def book
    @book ||= begin
      GeneratedBook::Book.erase_if_exist
      GeneratedBook::Book.new
    end
  end

  # Le checker du livre
  def pdf
    @pdf ||= PDF::Checker.new(book.book_path)
  end

  def recide_minimal_data
    {
      book_titre: "Livre avec index",
      titre1_lines_before: 0,
      numerotation: 'parags',
      page_de_garde: false,
    }
  end

  def recipe_data_with_styles
    recide_minimal_data.merge({
      tdm_line_height: 8,
      tdm_font_name:   'Courier',
      tdm_font_size:   7,
      tdm_font_style:  :regular,
      tdm_indent_per_level: 5.mm,
    })
  end

  def texte_avec_titres
    <<~TEXT
    # Un grand titre
    #{text1}
    # Autre grand titre
    ## Premier sous-titre
    #{text2}
    ## Deuxième sous-titre
    #{text3}
    # Un dernier grand titre
    TEXT
  end

  def text1; @text1 ||= "Du texte pour voir." end
  def text2; @text2 ||= "Du texte dans le sous-titre" end
  def text3; @text3 ||= "Du texte pour le deuxième sous-titre" end

  def test_table_des_matiers_sans_marque
    return if focus?
    resume "
    Sans la marque de l'endroit où doit être inscrite la table des
    matières, elle ne s'inscrit pas.
    "
    book.recipe.build_with(recide_minimal_data)
    book.build_text(texte_avec_titres)
    book.build

    ptrois = pdf.page(3)
    ptrois.not.has_text("Table des matières")
    ["Un grand titre", "Autre grand titre", "Premier sous-titre","Deuxième sous-titre", "Un dernier grand titre"
    ].each do |str|
      ptrois.not.has_text(str)
    end
  end

  def test_table_des_matieres_par_defaut
    # return if focus?
    resume "
    La table des matières peut s'inscrire même sans aucun réglage.
    "
    book.recipe.build_with(recide_minimal_data)
    book.build_text("(( table_of_contents ))\n#{texte_avec_titres}")
    book.build

    ptrois = pdf.page(3)
    ptrois.has_text("Table des matières")
    ["Un grand titre", "Autre grand titre", "Premier sous-titre","Deuxième sous-titre", "Un dernier grand titre"
    ].each do |str|
      ptrois.has_text(str)
    end
    [text1,text2, text3].each do |str|
      ptrois.not.has_text(str)
    end
  end

end #/IndexPageTest
