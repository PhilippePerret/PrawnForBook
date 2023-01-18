=begin

  Module les données de la page
  
=end
module Prawn4book
class Pages
class TableOfContent < SpecialPage

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
    title:        {name: 'Titre à donner à la page', default: 'Table des matières'},
    title_level:  {name:'Niveau de titre pour « Table des matières »', default: 1},
    font:         {name: 'Police par défaut', default: 'Times', values: :police_names},
    line_height:  {name:'Hauteur de ligne', default: 14},
    from_top:     {name:'Nombre de lignes depuis le haut', default: 4},
    separator:    {name:'Caractère entre titre et numéro de page', default: '.'},
    add_to_numero_with: {name:'Espace (points) entre dernier séparateur et num. page', default: 0},
    numeroter:    {name:'Numéroter de page (ou de paragraphe) ?', default: true},
    level1: {
      font: {name: 'Police titre niveau 1', default: 'Times', values: :police_names},
      size: {name: 'Taille titre niveau 1', default: 12},
      indent: {name:'Indentation titre niveau 1', default: 0},
      separator: {name: 'Séparateur titre 1/num. page', default: 'same', values: :separateurs},
    },
    level2: {
      font: {name: 'Police titre niveau 2', default: 'Times', values: :police_names},
      size: {name: 'Taille titre niveau 2', default: 10},
      indent: {name:'Indentation titre niveau 2', default: 10.mm},
      separator: {name: 'Séparateur titre 2/num. page', default: 'same', values: :separateurs},
    },
    level3: {
      font: {name: 'Police titre niveau 3', default: 'Times', values: :police_names},
      size: {name: 'Taille titre niveau 3', default: 9},
      indent: {name:'Indentation titre niveau 3', default: 20.mm},
      separator: {name: 'Séparateur titre 3/num. page', default: 'same', values: :separateurs},
    },
    level4: {
      font: {name: 'Police titre niveau 4', default: 'Times', values: :police_names},
      size: {name: 'Taille titre niveau 4', default: 8},
      indent: {name:'Indentation titre niveau 4', default: 30.mm},
      separator: {name: 'Séparateur titre 4/num. page', default: 'same', values: :separateurs},
    },
  }

  # 
  # Ci-dessous, définition des méthodes utiles aux données, à 
  # commencer par les méthodes qui doivent définir les :values des
  # propriétés à valeurs définies
  # 
  def police_names(default_name = nil)
    (get_data_in_recipe[:fonts]||DEFAULT_FONTS).map do |font_name, dfont|
      {name: font_name, value: font_name}
    end
  end

  def separateurs
    [
      {name: 'Le caractère général', value: 'same'},
      {name: 'Pas de séparateur', value: 'none'},
      {name: 'Traits plats', value: '_'},
    ]
  end

  def choices_numeroter
    [
      {name: 'Mettre le numéro de page ou de paragraphe', value: true},
      {name: 'Ne pas numéroter', value: false},
    ]
  end

end #/class TableOfContent
end #/class Pages
end #/module Prawn4book
