module Prawn4book
class PrawnView

  def insert_page_de_titre
    #
    # Les informations du livre
    # 
    titre       = pdfbook.titre
    sous_titre  = pdfbook.formated_sous_titre
    auteurs = pdfbook.formated_auteurs
    if pdfbook.collection?
      titre_collection = pdfbook.collection.name
    end
    publisher = pdfbook.publisher
    # 
    # Les données de mise en page
    # 
    dpagetitre = pdfbook.recipe[:page_de_titre]
    dpagetitre = {} if dpagetitre === true
    dpagetitre[:font]   ||= pdfbook.default_font
    # - tailles de fontes -
    dpagetitre[:sizes]  ||= {}
    dpagetitre[:sizes][:title]      ||= 34
    dpagetitre[:sizes][:subtitle]   ||= 20
    dpagetitre[:sizes][:author]     ||= 16
    dpagetitre[:sizes][:publisher]  ||= 14
    dpagetitre[:sizes][:collection_title] ||= 14
    # - espaces entre les éléments -
    dpagetitre[:spaces_before] ||= {}
    dpagetitre[:spaces_before][:title]    ||= 4
    dpagetitre[:spaces_before][:subtitle] ||= 1
    dpagetitre[:spaces_before][:author]   ||= 2
    # - Logo -
    unless dpagetitre[:logo] === false
      dpagetitre[:logo] ||= {}
      dpagetitre[:logo][:height] ||= 10
    end

    sizes   = dpagetitre[:sizes]
    spaces  = dpagetitre[:spaces_before]
    dlogo   = dpagetitre[:logo]

    #
    # On commence une nouvelle page
    # 
    start_new_page

    #
    # Mise en forme voulue
    # 
    font(dpagetitre[:font])

    if pdfbook.collection?
      move_cursor_to bounds.height
      text titre_collection, {align: :center, size: sizes[:collection_title]}
    end

    move_down(spaces[:title])
    text titre, {align: :center, size: sizes[:title]}

    if sous_titre
      move_down(spaces[:subtitle])
      text sous_titre, {align: :center, size: sizes[:subtitle]}
    end
    
    move_down(spaces[:author])
    text auteurs, {align: :center, size: sizes[:author]}

    if publisher
      font dpagetitre[:font], size: sizes[:publisher]
      name_height = self.height_of(publisher.name)
      if dlogo === false
        hauteur_totale = name_height
      else
        hauteur_totale = name_height + dlogo[:height].mm
      end
      move_cursor_to hauteur_totale
      text publisher.name, align: :center, size: sizes[:publisher]
      if publisher.logo? && not(dlogo === false)
        image publisher.logo, height: dlogo[:height].mm, position: :center
      end
    end

    #
    # Le recto de la page
    # 
    start_new_page
    
  end

end #/class PrawnView
end #/module Prawn4book
