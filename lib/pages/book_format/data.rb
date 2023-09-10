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
      width:        {name:'Largeur du livre (avec unité)' , default:'127mm'},
      height:       {name:'Hauteur du livre (avec unité)' , default:'203.2mm'},
      orientation:  {name:'Orientation'                   , default:'portrait', values: [{name:'Portrait',value:'portrait'}, {name:'Paysage', value:'landscape'}] },
    },
    page: {
      margins: {
        top: {name:'Marge haute (avec unité)'      , default: '20mm'},
        ext: {name:'Marge extérieure (avec unité)' , default: '10mm'},
        bot: {name:'Marge basse (avec unité)'      , default: '15mm'},
        int: {name:'Marge intérieure (avec unité)' , default: '25mm'},
      },
      numerotation:             {name:'Numérotation du livre'             , default:'pages', values: :values_numerotations},
      format_numero:            {name:'Format de la numérotation'         , default:'first-last', values: :values_format_numerotation},
      no_num_empty:             {name:'Pas de numéro sur pages vides'     , default: true   , type: :bool},
      num_only_if_num:          {name: 'Numéroter page seulement si parag.', if: :numerotation_parag?, default: true, type: :bool},
      num_page_if_no_num_parag: {name: 'Numéro de la page si aucun parag.' , if: :numerotation_parag?, default: true, type: :bool},
      no_headers_footers:       {name: 'AUCUN pied de page ou entête'     , default: false, type: :bool},
      skip_page_creation:       {name:'Passer la page de création'      , default: true, type: :bool},
    },
    text: {
      default_font_and_style:   {name:'Fonte/style par défaut'            , default: nil, values: Prawn4book::Fonte.method(:as_choices)},
      default_size:             {name:'Taille de fonte par défaut'        , default: 12},
      indent:                   {name:'Indentation du premier paragraphe' , default: '0mm'},
      line_height:              {name:'Hauteur de lignes (en points-pdf)' , default: 14.0},
      leading:                  {name:'Espace entre paragraphes'          , default: 0.0},
      parag_num_vadjust:        {name:'Ajustement vertical du numéro de paragraphe'   , if: :numerotation_parag?, values: (-20..20), default: 1},
      parag_num_dist_from_text: {name:'Ajustement horizontal du numéro de paragraphe' , if: :numerotation_parag?, values: (-20..20), default: 5},
      parag_num_size:           {name:'Taille du numéro de paragraphe', if: :numerotation_parag?, values: (7..25), default: 9},
      parag_num_strength:       {name:'Force (\% d’opacité) du numéro de paragraphe', if: :numerotation_parag?, values: (20..100), default: 75},
    },
  }

  # 
  # Ci-dessous, définition des méthodes utiles aux données, à 
  # commencer par les méthodes qui doivent définir les :values des
  # propriétés à valeurs définies
  # 

  def numerotation_parag?
    get_value('page-numerotation') == 'parags'
  end

  def values_numerotations
    [
      {name:'Numéroter les pages'       , value: 'pages'  },
      {name:'Numéroter les paragraphes' , value: 'parags' },
      {name:'Pas de numérotation'       , value: 'none'   },
    ]
  end

  # @return [Array<Hash>] Les choices pour choisir le format de
  # numéro de page.
  def values_format_numerotation
    case get_value('page-numerotation')
    when 'pages'
      [
        {name: 'Numéro de page seul', value: 'first'},
        {name: 'Page X'             , value: 'Page first'},
        {name: 'P. X'               , value: 'P. first'},
      ]
    when 'parags'
      [
        {name:'x-y'   , value: 'first-last'},
        {name:'x/y'   , value: 'first/last'},
        {name:'x à y' , value: 'first à last'},
      ]
    end
  end

end #/class BookFormat
end #/class Pages
end #/module Prawn4book
