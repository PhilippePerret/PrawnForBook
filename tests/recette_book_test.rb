require 'test_helper'
=begin

  Test de l'initiation d'un nouveau livre

=end

require_relative '../lib/required'

class InitPdfBookTest < Minitest::Test

  def setup
    super
  end

  def pdfbook
    @pdfbook ||= Prawn4book::PdfBook.new(nil)
  end

  def test_pdfbook_init
    Prawn4book.require_module('pdfbook/recipe')
    assert_respond_to Prawn4book::PdfBook, :define_book_recipe
    assert_respond_to pdfbook, :create_recipe
  end

  def test_create_recipe_with_data
    return
    skip "Concentration"
    Prawn4book.require_module('pdfbook/recipe')
    assert_respond_to pdfbook, :create_recipe
    books_folder = mkdir(File.join(TEST_FOLDER,'essais','books'))
    book_folder  = File.join(books_folder,'mon_livre')
    book_folder.length > 20 || raise("Problème sur le chemin du livre… Je préfère m'arrêter là avant de faire une bêtise.")
    FileUtils.rm_rf(book_folder) if File.exist?(book_folder)
    # 
    # Le fichier recette pour le livre
    # 
    recipe_path  = File.join(book_folder,'recipe.yaml')

    refute File.exist?(recipe_path), "Le fichier recette en devrait pas encore exister."
    data = {
      titre:        "Le titre du livre à #{formate_date(Time.now)}",
      auteur:       "Philippe Perret",
      id:           'mon_livre',
      main_folder:  books_folder,
      text_path:    File.join(TEST_FOLDER,'resources','textes','book_text.txt'),
      dim:          '127x203.2',
      marges:       '10,10,10,10',
      opt_para_num: false
    }
    Dir.chdir(books_folder) do
      pdfbook.create_recipe(data)
    end
    assert File.exist?(pdfbook.folder), 'Le dossier du livre devrait exister.'
    assert File.exist?(recipe_path), "Le fichier recette devrait avoir été créé."
    assert File.exist?(pdfbook.text_path), "le fichier contenant le texte du livre devrait avoir été créé."
  end

  def test_create_with_bad_data
    return
    skip "Concentration"
    Prawn4book.require_module('recipe')
    books_folder = mkdir(File.join(TEST_FOLDER,'essais','books'))
    cdata = {
      titre:        'Un titre de livre',
      auteur:       'Auteur du livre',
      id:           "id_#{Time.now.to_i}",
      text_path:    File.join(TEST_FOLDER,'resources','textes','book_text.txt'),
      main_folder:  books_folder,
      dim:          '127x203.2',
      marges:       '10,10,10,10',
      opt_para_num: false
    }
    
    # Bad titre
    cd = cdata.dup.merge!(titre: nil)
    err = assert_raises {
      pdfbook = Prawn4book::PdfBook.new
      pdfbook.create_recipe(cd)
    }
    assert_equal "Le titre est requis", err.message

    # Bad titre (trop long)
    cd = cdata.dup.merge!(titre: "axd"* 30)
    err = assert_raises {
      pdfbook = Prawn4book::PdfBook.new
      pdfbook.create_recipe(cd)
    }
    assert_equal "Le titre est trop long", err.message

    # Bad titre (trop court)
    cd = cdata.dup.merge!(titre: "ad")
    err = assert_raises {
      pdfbook = Prawn4book::PdfBook.new
      pdfbook.create_recipe(cd)
    }
    assert_equal "Le titre est trop court", err.message

    # Bad auteur (non défini)
    cd = cdata.dup.merge!(auteur: nil)
    err = assert_raises {
      pdfbook = Prawn4book::PdfBook.new
      pdfbook.create_recipe(cd)
    }
    assert_equal "L'auteur du livre est requis", err.message

    # Bad id (non défini)
    cd = cdata.dup.merge!(id: nil)
    err = assert_raises {
      pdfbook = Prawn4book::PdfBook.new
      pdfbook.create_recipe(cd)
    }
    assert_equal "L'identifiant du livre est requis", err.message

    mkdir(File.join(books_folder,'mon_livre'))
    # Bad id (existant)
    cd = cdata.dup.merge!(id: 'mon_livre')
    err = assert_raises {
      pdfbook = Prawn4book::PdfBook.new
      pdfbook.create_recipe(cd)
    }
    assert_equal "Le dossier de ce livre existe déjà… Je ne le touche pas.", err.message

    # Bad id (invalide)
    cd = cdata.dup.merge!(id: 'mon livre !')
    err = assert_raises {
      pdfbook = Prawn4book::PdfBook.new
      pdfbook.create_recipe(cd)
    }
    assert_equal "L'identifiant n'est pas valide (que des lettres et '_')", err.message

    # Bad text_path (non défini)
    cd = cdata.dup.merge!(text_path: nil)
    err = assert_raises {
      pdfbook = Prawn4book::PdfBook.new
      pdfbook.create_recipe(cd)
    }
    assert_equal "Le chemin d'accès au texte doit être défini.", err.message

    # Bad text_path (inexistant)
    cd = cdata.dup.merge!(text_path: '/un/path/inexistant.txt')
    err = assert_raises {
      Prawn4book::PdfBook.new.create_recipe(cd)
    }
    assert_match "Le fichier texte est introuvable", err.message

    # Bad marges (inexistant)
    cd = cdata.dup.merge!(marges: nil)
    err = assert_raises {
      Prawn4book::PdfBook.new.create_recipe(cd)
    }
    assert_match "Il faut définir les marges du livre", err.message

    # Bad marges (trop peu de valeurs)
    cd = cdata.dup.merge!(marges: '10,10,10')
    err = assert_raises {
      pdfbook = Prawn4book::PdfBook.new
      pdfbook.create_recipe(cd)
    }
    assert_match "4 marges doivent être définies", err.message

    # Bad marges (trop de valeurs)
    cd = cdata.dup.merge!(marges: '10, 10, 10, 40, 30')
    err = assert_raises {
      pdfbook = Prawn4book::PdfBook.new
      pdfbook.create_recipe(cd)
    }
    assert_match "4 marges doivent être définies", err.message

    # Bad marges (mauvaises valeurs)
    cd = cdata.dup.merge!(marges: '10,10,10,60')
    err = assert_raises {
      pdfbook = Prawn4book::PdfBook.new
      pdfbook.create_recipe(cd)
    }
    assert_match "Les marges doivent mesurer entre 5 et 50 mm !", err.message

  end



  # On crée la recette d'un nouveau livre avec un test d'intégration
  # 
  # Ce test, pour le moment, doit permettre d'essayer d'utiliser
  # les possibilités de CLI_TEST (sans le charger)
  def test_init_create
    inputs = [
      'Y',
      "Le titre du nouveau bouquin", 
      nil, # Pour s'arrêter là tout de suite
    ]
    res = run_('init', inputs)
    puts "res = #{res.inspect}".jaune
  end

end #/class InitPdfBookTest
