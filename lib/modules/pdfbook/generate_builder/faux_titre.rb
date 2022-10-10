module Prawn4book
class PdfFile < Prawn::Document

  def insert_faux_titre(pdfbook)
    #
    # Le titre du livre
    # 
    titre = pdfbook.titre

    #
    # On commence une nouvelle page
    # 
    start_new_page

    #
    # Mise en forme voulue
    # 
    font "Garamond", size: 24 # TODO pouvoir le régler

    #
    # Calcul de la taille du titre pour le placer correctement
    # 
    hauteur_titre = self.height_of(titre)
    top   = 2 * (self.bounds.height / 3)

    #
    # On se positionne au bon endroit pour écrire le texte
    # 
    options = {
      at: [0, top],
      width: bounds.width,
      height: hauteur_titre,
      align: :center,
      valign: :center,
    }
    puts "Écriture du titre «  » avec #{options.inspect}"
    text_box(titre, options)

    #
    # Le recto de la page
    # 
    start_new_page
    
  end

end #/class PdfFile
end #/module Prawn4book
