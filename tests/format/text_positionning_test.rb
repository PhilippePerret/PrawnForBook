=begin

Pour tester que le texte est bien positionné dans la page

=end
require 'test_helper'
require 'lib/required/Prawn_RectifiedDocument'
class TextPositioningTest < Minitest::Test

  def setup
    super
    File.delete(pdf_path) if File.exist?(pdf_path)
  end

  def teardown
    super
    File.delete(pdf_path) if File.exist?(pdf_path)
  end

  def pdf_path
    @pdf_path ||= File.join(ASSETS_FOLDER,'essais','pos_text.pdf')
  end

  def test_text_is_positioning_with_move_cursor
    
    mon_texte = "Mon texte"
    autre_texte = "Autre texte"
    doc_props = {margin:0, left_margin: 10}
    Prawn::RectifiedDocument.generate(pdf_path, **doc_props) do 
      move_cursor_to(100)
      text mon_texte
      move_down(20)
      text autre_texte
    end

    cpdf = PDF::Checker.new(pdf_path)
    # # - premier texte -
    # props = {at: [10,100]}
    # cpdf.page(1).has_text(mon_texte).with(**props)
    # cpdf.page(1).has_text(mon_texte).at(10.0, 100.0)
    # - autre texte -
    cpdf.page(1).has_text(autre_texte).at(10.0, 80.0)
  end

end #/class TextPositioningTest
