=begin

  Module les données de la page
  
=end
module Prawn4book
class Pages
class BookData

  # 
  # Table des données recette pour la page
  # telles qu'elles sont définies dans le fichier recipe.yaml
  # 
  PAGE_DATA = {
    title:        {name:'Titre du livre'                      , default:nil, required: true},
    subtitle:     {name:'Sous-titre du livre (\n = return)'   , default:nil},
    id:           {name:'ID du livre (lettres simples et "_"' , default:nil, required: true},
    auteurs:      {name:'Auteurs du livre (Prenom NOM,...)'   , default:nil},
    isbn:         {name:'ISBN', default: nil},
  }

  # 
  # Ci-dessous, définition des méthodes utiles aux données, à 
  # commencer par les méthodes qui doivent définir les :values des
  # propriétés à valeurs définies
  # 
  # Par exemple :
  # def police_names(default_name = nil)
  #   (get_data_in_recipe[:fonts]||DEFAUT_FONTS).map do |font_name, dfont|
  #       {name: font_name, value: font_name}
  #   end
  # end
end #/class BookData
end #/class Pages
end #/module Prawn4book
