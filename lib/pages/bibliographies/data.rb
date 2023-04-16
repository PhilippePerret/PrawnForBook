=begin

  Module les données de la page
  
=end
module Prawn4book
class Pages
class Bibliography

  # 
  # Table des données recette pour la page
  # telles qu'elles sont définies dans le fichier recipe.yaml
  # 
  PAGE_DATA = {
    # book: {
    #   width:        {name:'Largeur du livre (avec unité)' , default:'127mm'},
    #   height:       {name:'Hauteur du livre (avec unité)' , default:'203.2mm'},
    #   orientation:  {name:'Orientation'                   , default:'portrait', values: [{name:'Portrait',value:'portrait'}, {name:'Paysage', value:'landscape'}] },
    # },
    titre:  {name:'Titre de la bibliographie', default: nil},
    prefix: {name:'Préfixe d’un appel dans le texte', default: 'page'},
  }

end #/class Bibliography
end #/class Pages
end #/module Prawn4book
