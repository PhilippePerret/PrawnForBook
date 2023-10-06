require 'test_helper'
require 'lib/required'
require_folder('lib/commandes/build/lib')

class FakedBook
  def notes_manager
    @notes_manager ||= Prawn4book::PdfBook::NotesManager.new(self)
  end
end
class Prawn4book::NotesTests < Minitest::Test

  def setup
    super
    unless defined?(AnyP)
      Object.const_set('AnyP', Prawn4book::PdfBook::AnyParagraph)
    end
  end

  def teardown
    Object.send(:remove_const, 'AnyP')
  end

  def test_class_notes_manager_exist
    assert defined?(Prawn4book::PdfBook::NotesManager), "La classe Prawn4book::PdfBook::NotesManager devrait exister."
  end

  def test_method_traite_notes_in_exist
    assert_respond_to(Prawn4book::PdfBook::AnyParagraph, :__traite_notes_in)
  end

  def test_method_get_notes
    # -- Préparation --
    book = FakedBook.new
    AnyP.pdfbook = book
    book.notes_manager.drain
    str = "Un texte avec une note^2."
    # -- Test --
    assert_silent { str = AnyP.__traite_notes_in(str, nil) }
    # -- Vérification --
    expected = "Un texte avec une note <sup>2</sup>."
    assert_equal(expected, str)
    assert book.notes_manager.has_current_notes?, "Le manager de notes devrait avoir une note courante."

  end



end
