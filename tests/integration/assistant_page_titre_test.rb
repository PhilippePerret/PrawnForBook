require 'test_helper'

class PageTitreAssistant < Minitest::Test

  def setup
    super
    # set_mode_interactive
  end

  def teardown
    super
    # set_mode_inputs
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

    book_folder = File.join(TEST_FOLDER,'essais','books','un_livre_pour_tests')
    book_recipe = File.join(book_folder,'recipe.yaml')
    book_path   = File.join(book_folder,'book.pdf')

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
    tosa << [:DOWN, :RET] # Helvetica
    tosa.fast Array.new(7, :DOWN) << :RET # définir la taille de sous-titre
    tosa << ['18', :RET] # taille de sous-titre
    tosa << :RET # enregistrer

    # --- Vérification ---
    yaml = YAML.load_file(book_recipe)
    dpage = yaml[:page_de_titre]
    assert dpage
    [
      ['La taille de police de sous-titre', 18, dpage[:sizes][:subtitle]],
      ['La police de sous-titre', 'Helvetica', dpage[:fonts][:subtitle]],
    ].each do |what, expected, actual|
      assert_equal expected, actual, "La taille de la police de sous-titre devrait être #{expected}. Elle vaut #{actual.inspect}."
    end
    action "Je demande la construction du livre"
    File.delete(book_path) if File.exist?(book_path)
    refute File.exist?(book_path)
    tosa.run 'pfb build'
    sleep 4
    assert File.exist?(book_path)
    mini_success "Le livre a été reconstruit avec succès."

    tosa.finish
  end

end #/ class PageTitreAssistant
