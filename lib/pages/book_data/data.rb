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
    # Par exemple :
    # fonts: {
    #   title: {name:"Police du titre", default: 'Times', values: :police_names},
    #   subtitle: {name:"Police du sous-titre", default: 'Times', values: :police_names},
    # },
    # sizes: {
    #   title: {name:"Taille du titre", default: 18},
    #   subtitle: {name:'Taille du sous-titre', default: 16},
    # },
    book_title: {name:'Titre du livre', default:'Mon beau livre'},
    book_subtitle: {name:'Sous-titre du livre (\n pour retour ligne)', default: nil},
    collection: {name: 'Appartient à une collection', default: 'false', values: :yes_no_answers},
    book_id: {name: 'ID du livre (lettres simples et "_"', default:'beau_livre'},
    auteurs: {name: 'Auteurs du livre (Prenom NOM, Prenom NOM,...)', default:'Auteur BOOK'},
    isbn: {name: 'ISBN', default: nil},
    publisher: {
      name: {name:'Nom de l’éditeur', default: 'Mes Éditions'},
      adresse: {name:'Adresse (num rue - code ville)', default: nil},
      site: {name:'Site internet', default: nil},
      logo: {name:'Logo (chemin dans dossier)', default: nil},
      siret: {name: 'Numéro SIRET', default: nil},
      mail: {name: 'Mail général', default: nil},
      contact: {name:'Mail de contact', default: nil},
    },
  }

  # 
  # Ci-dessous, définition des méthodes utiles aux données, à 
  # commencer par les méthodes qui doivent définir les :values des
  # propriétés à valeurs définies
  # 
  # Par exemple :
  # def police_names(default_name = nil)
  #   (get_data_in_recipe[:fonts]||polices_default).map do |font_name, dfont|
  #     {name: font_name, value: font_name}
  #   end
  # end
  # def polices_default
  #   {'Times' => true, 'Helvetica' => true, 'Courier' => true}
  # end
end #/class BookData
end #/class Pages
end #/module Prawn4book
