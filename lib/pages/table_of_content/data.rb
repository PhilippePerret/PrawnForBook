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
    #   title: {name:"Police du titre", default: 'Times-Roman', values: :police_names},
    #   subtitle: {name:"Police du sous-titre", default: 'Times-Roman', values: :police_names},
    # },
    # sizes: {
    #   title: {name:"Taille du titre", default: 18},
    #   subtitle: {name:'Taille du sous-titre', default: 16},
    # },
    title:        {name:'Titre à donner à la page', default: 'Table des matières'},
    no_title:     {name:'Ne pas inscrire le titre «Table des matières»', default: false, type: :bool, values: :yes_no_answers},
    title_level:  {name:'Niveau de titre pour « Table des matières »', default: 1},
    level_max:    {name:'Jusqu’au niveau de titre :', default: 3, values:(1..6).to_a},
    line_height:  {name:'Hauteur de ligne', default: 14},
    lines_before: {name:'Nombre de lignes après le grand titre', default: 10},
    separator:    {name:'Caractère entre titre et numéro de page', default: '.'},
    add_to_numero_width: {name:'Espace (points) entre dernier séparateur et num. page', default: 0},
    numeroter:    {name:'Numéroter (page ou paragraphe) ?', default: true},
    level1: {
      font_n_style: {name:'Police titre niveau 1', default: 'Times-Roman/normal', values: Fonte.method(:as_choices)},
      size:         {name:'Taille titre niveau 1', default: 12},
      numero_size:  {name:'Taille pour le numéro', default: 10},
      indent:       {name:'Indentation titre niveau 1', default: 0},
      separator:    {name:'Séparateur titre 1/num. page', default: '.', values: :separateurs},
    },
    level2: {
      font_n_style: {name:'Police titre niveau 2', default: 'Times-Roman/normal', values: Fonte.method(:as_choices)},
      size:         {name:'Taille titre niveau 2', default: 10},
      numero_size:  {name:'Taille pour le numéro', default: 10},
      indent:       {name:'Indentation titre niveau 2', default: 10.mm},
      separator:    {name:'Séparateur titre 2/num. page', default: '.', values: :separateurs},
    },
    level3: {
      font_n_style: {name:'Police titre niveau 3', default: 'Times-Roman/normal', values: Fonte.method(:as_choices)},
      size:         {name:'Taille titre niveau 3', default: 9},
      numero_size:  {name:'Taille pour le numéro', default: 10},
      indent:       {name:'Indentation titre niveau 3', default: 20.mm},
      separator:    {name:'Séparateur titre 3/num. page', default: '.', values: :separateurs},
    },
    level4: {
      font_n_style: {name:'Police titre niveau 4', default: 'Times-Roman/normal', values: Fonte.method(:as_choices)},
      size:         {name:'Taille titre niveau 4', default: 8},
      numero_size:  {name:'Taille pour le numéro', default: 10},
      indent:       {name:'Indentation titre niveau 4', default: 30.mm},
      separator:    {name:'Séparateur titre 4/num. page', default: '.', values: :separateurs},
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
      {name: 'Le caractère général', value: '.'},
      {name: 'Pas de séparateur', value: ''},
      {name: 'Traits plats', value: '_'},
      {name: 'Tirets', value: '-'},
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
