=begin
  
  Module pour tester la fabrication de la page de titre

=end
require 'test_helper'

class PageTitreTest < Minitest::Test

  def test_page_titre_sans_options_est_conforme

    resume "
    Une page de titre sans options particulière est conforme
    à la recette.
    "
    
    folder_book = File.join(ASSETS_FOLDER,'all_books','books','for_page_titre')
    pdf_path = File.join(folder_book, 'book.pdf')

    # --- Préliminaires ---
    File.delete(pdf_path) if File.exist?(pdf_path)

    # ===> TEST <===
    action "Je me place dans le dossier et je demande la construction du livre."
    tosa = new_tosa
    tosa.new_window
    tosa.run "cd '#{folder_book}'; pfb build"
    tosa.finish

    # --- Vérifications ---
    sleep 1 # le temps que le livre se construise
    assert File.exist?(pdf_path)
    pdf = PDF::Checker.new(pdf_path)

    # Les formules que j'aimerais bien avoir : 
    pdf.has(10.pages)
    pdf.page(2).contains("Bonjour").close_to(100,20).with({font:'Helvetica', style: :normal})

    pdf.should_have(3.pages)
    page(2).of(pdf).should_contain("Bonjour").close_to(100,20)
    pdf.should_contain("Bonjour").at(page: 2, close_to: [100,20])
    pdf.page(2)

  end

end #/class PageTitreTest
