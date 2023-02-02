require 'test_helper'

# On requiert le minimum
require 'lib/required'

class Praw4bookFontesTest < Minitest::Test

  def setup
    super
  end

  def teardown
    super
  end


  # Méthode de test s'assurant que la fonte +fonte+ possède bien les
  # données +values+
  # 
  # @param [Prawn4book::Fonte] fonte L'instance de la fonte
  # @param  [Array] values Les valeurs : [name, style, size]
  #         [Hash]  values            ou {:name, :style, :size}
  def assert_la_fonte(fonte, values)
    if values.is_a?(Array)
      values = {name: values[0], style: values[1], size: values[2]}
    end
    values.each do |prop, expected|
      actual = fonte.send(prop)
      assert_equal(expected, actual, "La propriété #{prop.inspect} de la fonte devrait être #{expected.inspect}. Elle vaut #{actual.inspect}.")
    end
  end

  def test_default_default_font_exist
    resume "
    Quand rien du tout n'est défini, une fonte par
    défaut existe quand même
    "
    assert(Prawn4book::Fonte.default_fonte, "Il devrait toujours exister une fonte par défaut.")
    deff = Prawn4book::Fonte.default_fonte
    assert_instance_of(Prawn4book::Fonte, deff)
    assert_la_fonte(deff, ["Times-Roman", :roman, 11])
  end

end
