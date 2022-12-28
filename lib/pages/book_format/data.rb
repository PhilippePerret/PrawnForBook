=begin

  Module les données de la page
  
=end
module Prawn4book
class Pages
class BookFormat

  # 
  # Table des données recette pour la page
  # telles qu'elles sont définies dans le fichier recipe.yaml
  # 
  PAGE_DATA = {
    book: {
      width:  {name:'Largeur du livre (avec unité)', default:'127mm'},
      height: {name:'Hauteur du livre (avec unité)', default:'203.2mm'},
      orientation: {name:'Orientation', default:'portrait', values: [{name:'Portrait',value:'portrait'}, {name:'Paysage', value:'landscape'}] },
    },
    page: {
      margins: {
        top: {name:'Marge haute (avec unité)'      , default: '20mm'},
        ext: {name:'Marge extérieure (avec unité)' , default: '10mm'},
        bot: {name:'Marge basse (avec unité)'      , default: '15mm'},
        int: {name:'Marge intérieure (avec unité)' , default: '25mm'},
      },
    },
    text: {
      default_font: {name:'Fonte par défaut'                  , default: :first_police_name, values: :police_names},
      default_size: {name:'Taille de fonte par défaut'        , default: 12},
      indent:       {name:'Indentation du premier paragraphe' , default: '0mm'},
      line_height:  {name:'Hauteur de lignes (en points-pdf)' , default: 14.0},
      interline:    {name:'Espace entre paragraphes'          , default: 0.0}
    },
  }

  # 
  # Ci-dessous, définition des méthodes utiles aux données, à 
  # commencer par les méthodes qui doivent définir les :values des
  # propriétés à valeurs définies
  # 

end #/class BookFormat
end #/class Pages
end #/module Prawn4book
