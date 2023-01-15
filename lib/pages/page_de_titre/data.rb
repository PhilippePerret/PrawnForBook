=begin

  Module les données de la page
  
=end
module Prawn4book
class Pages
class PageDeTitre

  # On peut récupérer ces valeurs par
  #   recipe.page_de_titre
  # 
  PAGE_DATA = {
    fonts: {
      title: {name:"Police du titre", default: ->(){self.first_police_name}, values: :police_names},
      subtitle: {name:"Police du sous-titre", default: ->(){self.first_police_name}, values: :police_names},
      author: {name:"Police de l'auteur", default: ->(){self.first_police_name}, values: :police_names},
      publisher: {name:"Police de l'édition", default: ->(){self.first_police_name}, values: :police_names},
      collection_title: {name:"Police du nom de la collection", default: ->(){self.first_police_name}, values: :police_names},
    },
    sizes: {
      title: {name:"Taille du titre", default: 18},
      subtitle: {name:'Taille du sous-titre', default: 11},
      author:   {name:'Taille de l’auteur', default: 15},
      publisher: {name:'Taille de l’édition', default: 12},
      collection_title: {name:'Taille du nom de collection', default: 12},
    },
    spaces_before: {
      title: {name:'Nombre de lignes avant le titre', default: 4},
      subtitle: {name:'Nombre de lignes avant le sous-titre', default: 1},
      author: {name:'Nombre de lignes avant l’auteur', default: 2},
    },
    logo: {
      height: {name:'Hauteur du logo (pixels)', default: 10},
    },
  }

end #/class PageDeTitre
end #/class Pages
end #/module Prawn4book
