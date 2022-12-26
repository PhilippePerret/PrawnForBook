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

    tosa = OSATest.new({
      app:'Terminal',
      delay: 1,
      window_bounds: [10,10,1200,800]
    })
    action "Je rejoins un dossier de livre et je lance la commande"
    tosa.new_window
    tosa.run "cd '#{File.join(TEST_FOLDER,'essais','books','un_livre_pour_tests')}' && pfb aide page-de-titre"
    tosa.has_in_last_lines("Assistant Page de titre", 30)
    mini_success "Le formulaire est bien affiché."
    action "Je définis quelques valeurs"
    
    # sleep 10
    # tosa.abort.finish
  end

end #/ class PageTitreAssistant
