=begin

  Module les données de la page
  
=end
module Prawn4book
class Pages
class PageDeTitre

  PAGE_DATA = {
    fonts: {
      title: {name:"Police du titre", default: 'Times', values: :police_names},
      subtitle: {name:"Police du sous-titre", default: 'Times', values: :police_names},
      author: {name:"Police de l'auteur", default: 'Times', values: :police_names},
      publisher: {name:"Police de l'édition", default: 'Times', values: :police_names},
      collection_title: {name:"Police du nom de la collection", default: 'Times', values: :police_names},
    },
    sizes: {
      title: {name:"Taille du titre", default: 18},
      subtitle: {name:'Taille du sous-titre', default: 16},
      author:   {name:'Taille de l’auteur', default: 12},
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


  def self.police_names(default_name = nil)
    (get_data_in_recipe[:fonts]||DEFAUT_FONTS).map do |font_name, dfont|
      {name: font_name, value: font_name}
    end
  end

end #/class PageDeTitre
end #/class Pages
end #/module Prawn4book
