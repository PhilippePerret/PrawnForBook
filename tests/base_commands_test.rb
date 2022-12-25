=begin

Test des commandes de base, comme l'ouverture du
manuel

=end
require 'test_helper'

class BaseCommandTests < Minitest::Test

  # Test de l'ouverture du manuel
  def test_open_manuel
    # skip
    preview_is_open = Osascript.on?('Preview')
    preview_is_open && Osascript.quit("Preview")
    `prawn-for-book manuel`
    assert $? == 0, "La commande n'aurait pas dû rencontrer de problème."
    path_to_manuel = File.join(APP_FOLDER,'Manuel','Manuel.pdf')
    assert Osascript::Preview.document_opened?(path_to_manuel), "Le manuel devrait être ouvert."
    preview_is_open || Osascript.quit("Preview")
  end

  # Test de l'affichage de l'aide
  def test_help_display
    # skip
    out = `prawn-for-book help`
    assert_match "AIDE DE #{'prawn-for-book'.jaune}", out
  end

end #/tests
