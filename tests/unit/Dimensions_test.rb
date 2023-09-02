require 'test_helper'
require 'lib/required'

class DimensionsTest < Minitest::Test

  def setup
    super
  end


  def test_conversion_string_to_dimension
    [
      [1,                 '"1pt".to_f'],
      [85.03937007874016, '"3cm".to_f'],
      [2.834645669291339, '"1mm".to_f'],
      [2.834645669291339, '1.mm'],
      [3.118110236220473, '1.1.mm'],
      [1.0,               '"1.0".to_f'],
      [1,                 '1.pt'],
    ].each do |expected, expression|
      actual = eval(expression)
      assert_equal(expected, actual, "Le code #{expression} devrait retourner #{expected.inspect}, il retourne #{actual.inspect}…")  
    end
  end

end
