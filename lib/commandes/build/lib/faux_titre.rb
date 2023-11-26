module Prawn4book
class PrawnView

  def insert_faux_titre

    # Le titre du livre
    # 
    titre = book.titre

    # Les données pour le faux-titre
    # 
    dfauxtitre = book.recipe.inserted_pages[:faux_titre]||book.recipe.inserted_pages[:half_title_page]
    if dfauxtitre === true
      dfauxtitre = {paginate: false, size: 24}
    elsif dfauxtitre.key?(:font)
      dfauxtitre.merge!(font: Prawn4book.fnss2Fonte(dfauxtitre[:font]))
    end

    dfauxtitre[:font] || begin
      fs = Fonte.dup_default
      fs.size = dfauxtitre[:size] || 24
      dfauxtitre.merge!(font: fs)
    end

    # On commence une nouvelle page
    # 
    start_new_page

    # On indique qu'il ne faudra pas numéroter cette page, sauf
    # indication contraire dans la recette
    # 
    book.page(page_number).pagination = dfauxtitre[:paginate] || false

    # Mise en forme voulue
    # 
    if dfauxtitre[:font].is_a?(Prawn4book::Fonte)
      fauxtitre_font = dfauxtitre[:font]
    else
      fauxtitre_font = Fonte.new(
        name:   dfauxtitre[:font],
        size:   dfauxtitre[:size],
        style:  dfauxtitre[:style],
        color:  dfauxtitre[:color]||'000000',
      )
    end
    font(fauxtitre_font)

    # Calcul de la taille du titre pour le placer correctement
    # 
    hauteur_titre = self.height_of(titre)
    top   = 2 * (self.bounds.height / 3)

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
