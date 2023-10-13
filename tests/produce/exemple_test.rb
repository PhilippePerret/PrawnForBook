require 'test_helper'


class TemplateTest < Minitest::Test

  def test_document_simple_avec_titres
    assert_silent { produce_book('books/simples/titres') }
  end

  def test_document_printer
    assert_silent { produce_book('books/printer') }
  end
  
end
