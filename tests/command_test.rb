=begin

  Test basique de la commande prawn-for-book
=end
require 'test_helper'

class PrawForBookCommandTest < Minitest::Test

  # On tester que la commande 'prawn-for-book' existe et 
  # fonctionne.
  # Note : elle est définie dans les constantes de l'application
  # (lib/required/constants)
  def test_la_commande_existe
    `#{COMMAND_NAME}` rescue nil
    # `prawn-for-book` rescue nil
    assert_equal 0, $?, "la commande devrait exister et fonctionner sans arguments"
  end

end
