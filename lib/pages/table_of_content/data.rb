=begin

  Module les données de la page
  
=end
module Prawn4book
class Pages
class TableOfContent

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
    font:         {name: 'Police par défaut', default: 'Times', values: :police_names},
    line_height:  {name:'Hauteur de ligne', default: 14},
    from_top:     {name:'Nombre de lignes depuis le haut', default: 4},
    separator:    {name:'Caractère entre titre et numéro de page', default: '.'},
    add_to_numero_with: {name:'Espace (points) entre dernier séparateur et num. page', default: 0},
    level1: {
      font: {name: 'Police titre niveau 1', default: 'Times', values: :police_names},
      size: {name: 'Taille titre niveau 1', default: 12},
      indent: {name:'Indentation titre niveau 1', default: 0},
      separator: {name: 'Séparateur titre 1/num. page', default: 'same', values: :separateurs},
    },
    level2: {
      font: {name: 'Police titre niveau 2', default: 'Times', values: :police_names},
      size: {name: 'Taille titre niveau 2', default: 10},
      indent: {name:'Indentation titre niveau 2', default: '10mm'},
      separator: {name: 'Séparateur titre 2/num. page', default: 'same', values: :separateurs},
    },
    level3: {
      font: {name: 'Police titre niveau 3', default: 'Times', values: :police_names},
      size: {name: 'Taille titre niveau 3', default: 9},
      indent: {name:'Indentation titre niveau 3', default: '20mm'},
      separator: {name: 'Séparateur titre 3/num. page', default: 'same', values: :separateurs},
    },
  }

  # 
  # Ci-dessous, définition des méthodes utiles aux données, à 
  # commencer par les méthodes qui doivent définir les :values des
  # propriétés à valeurs définies
  # 
  def police_names(default_name = nil)
    (get_data_in_recipe[:fonts]||polices_default).map do |font_name, dfont|
      {name: font_name, value: font_name}
    end
  end
  def polices_default
    {'Times' => true, 'Helvetica' => true, 'Courier' => true}
  end

  def separateurs
    [
      {name: 'Le caractère général', value: 'same'},
      {name: 'Pas de séparateur', value: 'none'},
      {name: 'Traits plats', value: '_'},
    ]
  end

end #/class TableOfContent
end #/class Pages
end #/module Prawn4book
