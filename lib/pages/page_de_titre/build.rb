module Prawn4book
class Pages
class PageDeTitre

  attr_reader :pdfbook

  # = main =
  #
  # Méthode principale permettant de construire la page
  # 
  def build(pdf)
    @pdfbook = pdf.pdfbook
    line_height = pdf.line_height
    
    if collection?
      titre_collection = pdfbook.collection.name
    end

    #
    # Nouvelle page
    # 
    pdf.start_new_page

    # 
    # Le titre de la collection s'il est requis
    if collection?
      redef_current_font(v('fonts-collection_title'), pdf)
      pdf.move_cursor_to pdf.bounds.height
      pdf.text titre_collection, {align: :center, size: v('sizes-collection_title')}      
    end

    redef_current_font(v('fonts-title'), pdf)
    pdf.move_down(v('spaces_before-title') * line_height)
    pdf.text( book_title, {align: :center, size: v('sizes-title')})

    if book_subtitle
      redef_current_font(v('fonts-subtitle'), pdf)
      pdf.move_down(v('spaces_before-subtitle') * line_height)
      pdf.text( book_subtitle, {align: :center, size:v('sizes-subtitle')})
    end

    redef_current_font(v('fonts-author'), pdf)
    pdf.move_down(v('spaces_before-author') * line_height)
    pdf.text(authors, {align: :center, size: v('sizes-author')})

    # 
    # L'édition et le logo
    # 
    if publisher
      redef_current_font(v('fonts-publisher'), pdf)
      name_height = pdf.height_of(publisher.name)
      hauteur_totale = name_height
      hauteur_totale += v('logo-height').mm if logo?
      pdf.move_cursor_to(hauteur_totale)
      pdf.text(publisher.name, {align: :center, size:v('sizes-publisher')})
      if logo?
        pdf.image(publisher.logo, {height: v('logo-height').mm, position: :center})
      end
    end

    # 
    # Le recto
    # 
    pdf.start_new_page

  end

  # - Predicate methods -
  def collection? ; :TRUE == @iscollection ||= true_or_false(pdfbook.collection?) end
  def logo?
    :TRUE == @withlogo ||= true_or_false(publisher.logo? && logo)
  end

  # - shortcuts -
  def book_title    ; @book_titre ||= pdfbook.titre end
  def publisher     ; @publisher ||= pdfbook.publisher end
  def book_subtitle ; @book_subtitle ||= pdfbook.formated_sous_titre end
  def authors       ; @authors ||= pdfbook.formated_auteurs end
  def logo          ; @logo ||= pdfbook.publisher.logo end


end #/class PageDeTitre
end #/class Pages
end #/module Prawn4book
