module Prawn4book
class PrawnView

  def insert_faux_titre
    #
    # Le titre du livre
    # 
    titre = pdfbook.titre
    # 
    # Les données pour le faux-titre
    # 
    dfauxtitre = pdfbook.recipe.inserted_pages[:faux_titre]
    dfauxtitre = {
      font:       pdfbook.first_font, 
      size:       24,
      paginate:   false
    } if dfauxtitre === true

    #
    # On commence une nouvelle page
    # 
    start_new_page

    #
    # On indique qu'il ne faudra pas numéroter cette page, sauf
    # indication contraire dans la recette
    # 
    unless dfauxtitre[:paginate] == true
      pdfbook.pages_without_pagination << page_number
    end

    #
    # Mise en forme voulue
    # 
    fauxtitre_font = Fonte.new(
      name:   dfauxtitre[:font],
      size:   dfauxtitre[:size],
      style:  dfauxtitre[:style]
    )
    font(fauxtitre_font)

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
    text_box(titre, options)

    #
    # Le recto de la page
    # 
    start_new_page
    
  end

end #/class PrawnView
end #/module Prawn4book
