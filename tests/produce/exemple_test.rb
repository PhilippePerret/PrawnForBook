require 'test_helper'


class TemplateTest < Minitest::Test

  def test_document_simple_avec_titres
    assert_silent { produce_book('books/simples/titres') }
  end

end
