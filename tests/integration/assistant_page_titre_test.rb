require 'test_helper'
require 'timeout'

class PageTitreAssistant < Minitest::Test

  def setup
    super
  end

  def teardown
    super
  end

  def test_define_page_titre
    
    resume "
      Test de l'assistant de page de titre.
    "

    synopsis "
      - J'appelle l'assistant pour la page de titre
      - Je modifie quelques valeurs
      - je fabrique le livre
    "


    book_folder = File.join(TEST_FOLDER,'assets','essais','books','un_livre_pour_tests')
    book_recipe = File.join(book_folder,'recipe.yaml')
    book_path   = File.join(book_folder,'book.pdf')

    # checker = PDF::Checker.new(book_path)
    # page2 = checker.page(2)

    # puts "texts : #{page2.texts.inspect}"
    # puts "sentences : #{page2.sentences.inspect}"
    # puts "text : #{page2.text.inspect}"
    # puts "strings : #{checker.strings.inspect}"
    # puts "La suite explore les méthodes de PDF::Reader::Page".jaune

    # reader = checker.page(2).reader_page

    # puts "\n+++reader_page.text : #{reader.text.inspect}"
    # puts "\n+++ reader_page.fonts : #{reader.fonts.inspect}"
    # puts "\n+++ reader_page.runs : #{reader.runs.inspect}"
    # puts "\n+++ reader_page.properties : #{reader.properties.inspect}"
    # puts "\n+++ reader_page.attributes : #{reader.attributes.inspect}"
    # # puts "\n+++ reader_page.xobjects : #{reader.xobjects}"
    # puts "\n+++ reader_page.objects : #{reader.objects}"
    # puts "\n--- methodes #{reader.objects.methods}"
    # puts "\n+++ keys : #{reader.objects.keys}"
    # reader.objects.values.each_with_index do |value, idx|
    #   puts "\n+++ values[#{idx}] : #{reader.objects.values[idx]}"
    # end
    # puts reader.objects[3].inspect
    # puts "\n+++ reader_page.boxes : #{reader.boxes.inspect}"
    # puts "Méthodes :".jaune
    # puts "strings page 2 : #{checker.page(2).reader_page.methods}"
    # puts "strings page 2 : #{checker.page(2).reader_page.strings}"
    
    # receiver = PDF::Reader::RegisterReceiver.new
    # reader.walk(receiver)
    # receiver.callbacks.each do |cb|
    #   puts cb
    # end

    # puts checker.page(2).receivers_callbacks do |cb|
    #   puts cb
    # end

    # puts "Scénario de la page :".jaune
    # puts checker.page(2).scenario
    # return

    # Mettre à false pour passer directement à l'analyse du PDF
    doit = false


    if doit # mis à false pour seulement tester le pdf

      tosa = OSATest.new({
        app:'Terminal',
        delay: 0.3,
        window_bounds: [10,10,1200,800]
      })
      action "Je rejoins un dossier de livre et je lance la commande"
      tosa.new_window
      tosa.run "cd '#{book_folder}' && pfb aide page-de-titre"
      tosa.has_in_last_lines("Assistant Page de titre", 30)
      mini_success "Le formulaire est bien affiché."
      action "Je définis quelques valeurs"

      tosa.fast [:DOWN, :DOWN, :RET] # police de sous-titre
      tosa << [:DOWN, :DOWN, :RET] # Courier = 3, Helvetica = 2
      tosa.fast Array.new(7, :DOWN) << :RET # définir la taille de sous-titre
      tosa << ['18', :RET] # taille de sous-titre
      tosa << :RET # enregistrer

    end

    # --- Vérifications ---

    yaml = YAML.load_file(book_recipe)
    dpage = yaml[:page_de_titre]
    assert dpage
    [
      ['La taille de police de sous-titre', 18, dpage[:sizes][:subtitle]],
      ['La police de sous-titre', 'Courier', dpage[:fonts][:subtitle]],
    ].each do |what, expected, actual|
      assert_equal expected, actual, "#{what} de sous-titre devrait être #{expected}. Elle vaut #{actual.inspect}."
    end

    if doit # mis à false pour seulement tester le PDF
      action "Je demande la construction du livre"
      File.delete(book_path) if File.exist?(book_path)
      refute File.exist?(book_path)
      tosa.run 'pfb build'
      Timeout.timeout(20) { until File.exist?(book_path); sleep 0.2 end }
      assert File.exist?(book_path)
      mini_success "Le livre a été reconstruit avec succès."
      tosa.finish
    end

    checker = PDF::Checker.new(book_path)
    page2 = checker.page(2)
    texte = page2.text.inspect
    [
      'Un livre pour essais', 'Auteur BOOK', 'Pour pouvoir faire des essais'
    ].each do |expected|
      assert_includes texte, expected
    end
    mini_success "La page 2 contient bien tout le texte attendu"

    puts page2.texts_with_properties
  end

end #/ class PageTitreAssistant
