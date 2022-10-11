module Prawn4book
class PdfFile < Prawn::Document

  def insert_page_de_titre(pdfbook)
    #
    # Les informations du livre
    # 
    titre       = pdfbook.titre
    sous_titre  = pdfbook.formated_sous_titre
    auteurs = pdfbook.formated_auteurs
    if pdfbook.collection?
      titre_collection = pdfbook.collection.name
    end
    editor = pdfbook.editor

    #
    # On commence une nouvelle page
    # 
    start_new_page

    #
    # Mise en forme voulue
    # 
    font "Garamond" # TODO pouvoir régler

    if pdfbook.collection?
      move_cursor_to bounds.height
      text titre_collection, {align: :center, size: 14}
    end

    move_cursor_to bounds.height - 100
    text titre, {align: :center, size: 34}

    if sous_titre
      move_down 4
      text sous_titre, {align: :center, size: 14}
    end
    
    move_down 40
    text auteurs, {align: :center, size: 16}

    if editor
      font 'Garamond', size: 14 # TODO pouvoir régler
      name_height = self.height_of(editor.name)
      hauteur_totale = name_height + 10.mm
      move_cursor_to hauteur_totale
      text editor.name, align: :center, size: 14
      if editor.logo?
        # bounding_box(align: :center) do
          image editor.logo, height: 10.mm, position: :center
        # end
      end
    end

    #
    # Le recto de la page
    # 
    start_new_page
    
  end

end #/class PdfFile
end #/module Prawn4book
