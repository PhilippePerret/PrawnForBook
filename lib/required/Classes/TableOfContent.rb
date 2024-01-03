#
# ATTENTION
# =========
# Cette classe ne doit pas être confondue avec la classe utilisée 
# comme page spéciale, qu’on utilise peut-être encore un peu, mais
# de moins en moins à l’avenir.
# 
require_relative 'SpecialTable'
module Prawn4book
class PdfBook
class TableOfContent < SpecialTable

  def prepare_pages(pdf, premier_tour)

    # On passe toujours sur la page suivante
    pdf.start_new_page
    # Si on ne se trouve pas sur une belle page, on passe à la page
    # suivante
    pdf.start_new_page if pdf.page_number.even?

    # Instancier un titre pour la table des matières
    # 
    unless recipe[:no_title] || title.nil? || title == '---'
      titre = PdfBook::NTitre.new(book:book, titre:title, level:title_level, pindex:nil)
      titre.print(pdf)
      book.page(page_number).add_content_length(title.length + 3)
    end

    # On mémorise le numéro de première page de cette table des
    # matières
    # book.tdm.add_page_number(pdf.page_number.freeze)
    pdf.tdm.add_page_number(pdf.page_number.freeze)

    # Le nombre de pages à ajouter est défini par :pages_count qui
    # doit impérativement être un nombre pair.
    added = page_count || 2
    if added.odd? || added == 0
      add_erreur(PFBError[853] % {num: added})
      added += 1
    end

    # On ajoute autant de pages que voulu (une page a déjà été
    # ajoutée plus haut)
    added.times { pdf.start_new_page }

  end

  def page_count
    @page_count ||= recipe[:page_count]
  end

end #/class TableOfContent
end #/class PdfBook
end #/module Prawn4book
