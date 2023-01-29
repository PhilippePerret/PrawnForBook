require 'test_helper'

require 'lib/required'

class BibliographiesTests < Minitest::Test

  def setup
    super
    remove_precedences
    remove_all_data_bibliographies
  end
  def teardown
    super
  end

  def remove_precedences
    command_folder = File.join(COMMANDS_FOLDER,'biblio')
    [
      File.join(command_folder, '.precedences')
    ].each do |path|
      File.delete(path) if File.exist?(path)
    end
    Dir["#{APP_FOLDER}/tmp/biblios/**/*"].each{|f|File.delete(f)}
  end

  ##
  # Avant chaque test, on détruit tout ce qui concerne les bibliographies
  # dans le livre (dossier et recette)
  # 
  def remove_all_data_bibliographies
    FileUtils.rm_rf(book_biblios_folder) if File.exist?(book_biblios_folder)
    book.recipe.insert_bloc_data('bibliographies', {})
  end

  def book_biblios_folder
    @book_biblios_folder ||= File.join(book_folder,'biblios')
  end

  def book
    @book ||= Prawn4book::PdfBook.new(book_folder)
  end

  def book_folder
    @book_folder ||= File.join(TEST_FOLDER,'assets','essais','books','un_livre_pour_tests')
  end
  def book_recipe
    @book_recipe ||= File.join(book_folder,'recipe.yaml')
  end
  def book_path
    @book_path ||= File.join(book_folder,'book.pdf')
  end

  def test_creation_new_bibitem_without_anything
    resume "
    Ce test s'assure qu'on puisse tout créer, depuis la bibliographie
    jusqu'à un nouvel item, en passant par le fichier des formats de
    données, à partir de rien.
    "

    synopsis "
    Plan détaillé
    - création assistée d'une nouvelle bibligraphie
    - création assistée du fichier de format des données
    - création assistée d'un item de bibliographie
    "
    
    tosa = OSATest.new({
      app:'Terminal',
      delay: 0.6,
      window_bounds: [0,0,1200,800]
    })

    action "Je me place dans le dossier du livre, et je joue la commande 'pfb bib'"
    tosa.new_window
    tosa.run "cd '#{book_folder}' && pfb bib"
    sleep 1 # le temps que la commande se charge (1re fois)
    tosa.has_in_last_lines("Créer un item")
    action "Je choisis l'item 'Créer un item de bibliographie'"
    tosa << [:DOWN, :return]
    tosa.has_in_last_lines("Choisir la bibliographie")
    mini_success "L'application m'invite à choisir la bibliographie"
    # - Création nouvelle bibliographie -
    # (on doit créer le dossier pour ses items)
    mkdir(File.join(book_biblios_folder,'mabibs'))
    dbiblio = {
      tag: 'mabib', title: 'Liste des mabibs étoilés',
      path: 'biblios/mabibs'
    }
    action "Je choisis d'en créer une nouvelle"
    tosa << [:DOWN, :return]
    tosa.has_in_last_lines("Données de la bibliographie")
    tosa << [:RET, dbiblio[:tag], :RET]
    tosa << [:RET, dbiblio[:title], :RET]
    tosa << [2.downs, :RET, dbiblio[:path]]
    sleep 1 # le temps de la vérification
    tosa << :RET
    tosa.fast [10.ups, :RET] # enregistrement
    # - le programme demande si l'on veut définir le format des data -
    action "Je confirme que je veux définir le format des données"
    tosa << :RET
    # - Définition du format des données -
    tosa.has_in_last_lines("Format des fiches de la bibliographie “#{dbiblio[:tag]}”")
    # TODO
    sleep 15
    # TODO
    # mini_success "L'item a bien été créé."

    tosa.abort.finish
  end


end #/ class BibliographiesTests
