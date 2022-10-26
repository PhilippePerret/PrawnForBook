module Prawn4book

# --- Toutes les données permettant de renseigner les recettes
# --- 
# --- Sert autant aux templates qu'à l'assistant
# ---

DATA_VALUES_MINIMALES = [
  {k: :thing_title, q:'Titre du livre ou de la collection', df: 'Title'},
  {k: :thing_id, q: 'ID (seulement des minuscules et tiret_plat', df: 'monlivre'}
]

RECIPE_VALUES_FOR_PUBLISHER = [
  # k: pour 'key', q: pour 'question', df: pour 'défaut', t: pour 'type'
  {k: :publisher_name, q:"Nom de l'éditeur", df: "Publisher Name"},
  {k: :publisher_address, q:"Adresse de l'éditeur", df:'', t: :text},
  {k: :publisher_site, q:"Site de l'éditeur", df: 'https://editeur.com'},
  {k: :publisher_logo, q:"Chemin au logo (commencer par 'images/...')", df:'images/logo.jpg'},
  {k: :publisher_mail, q:"Mail de l'éditeur", df: 'mail@editor.com'},
  {k: :publisher_contact, q:"Mail de contact de la maison d'édition", df: 'contact@editor.com'},
]

RECIPE_VALUES_FOR_FORMAT = [
  {k: :book_width, q:"Largeur du livre (avec unité)", df: '127mm'},
  {k: :book_height, q:'Hauteur du livre (avec unité)', df: '203.2mm'},
  {k: :orientation, q:'Orientation (landscape/portrait)', df:'portrait'},
  {k: :topmargin, q:'Marge du haut (avec unité)', df:'25mm'},
  {k: :extmargin, q:'Marge extérieure (avec unité)', df:'10mm'},
  {k: :botmargin, q:'Marge du bas (avec unité)', df:'15mm'},
  {k: :intmargin, q:'Marge intérieure (avec unité)', df:'25mm'},
]
RECIPE_VALUES_FOR_WANTED_PAGES = [
  {k: :pagegarde, q:'Dois-je imprimer une page de garde ?', df:true, t: :yes},
  {k: :fauxtitre, q:'Dois-je imprimer la page de faux titre (titre seul) ?', df:false, t: :yes},
  {k: :pagetitre, q:'Dois-je imprimer la page de titre (titre et infos) ?', df:true, t: :yes},
  {k: :pageinfos, q:'Dois-je imprimer la page d’informations (fin du livre) ?', df:true, t: :yes},
]
RECIPE_VALUES_FOR_INFOS = [
  {k: :isbn, q: 'ISBN du livre', df: 'null'}
]

RECIPE_VALUES_FOR_OPTIONS = [
  {k: :numparag, q:'Dois-je numéroter les paragraphes ?', df:false, t: :yes},
  {k: :numpage, q:'Pagination avec :', df: 'num_page', t: :select, values:[{name:'numéro page', value:'num_page'},{name:'numéros paragraphes', value:'num_parag'}]},
]

DIM_VALUES = [
  {name:'12,7 cm x 20,32 cm (5 x 8 po)' , value:[127, 203.2]   },
  {name:'A4 (21 x 29.7)'                , value:[210, 297]     },
  {name:'15,24 x 22,86 (6 x 9 po)'      , value:[152.4, 228.6] },
  {name:'A5 (14.85 x 21)'               , value:[148.5, 210]   },
  {name:'Autre dimension…'              , value: nil }
]

TITLES_TAILLES_DEFAULT = [nil, 30, 26, 20, 18, 16, 14]
TITLES_MARGIN_TOP_DEFAULT = [nil, 0, 3, 2, 1, 0, 0]
TITLES_MARGIN_BOT_DEFAULT = [nil, 4, 3, 2, 1, 0, 0]
TITLES_DATAS = [
  ['Fonte pour le niveau %{level}', :font, 'Arial'],
  ['Taille pour la font %{font} du niveau %{level}', :size, ->(level){TITLES_TAILLES_DEFAULT[level]}],
  ['Marge top (en nombre de lignes) pour le niveau %{level}', :margin_top, ->(level){TITLES_MARGIN_TOP_DEFAULT[level]}],
  ['Marge bottom (en nombre de lignes) pour le niveau %{level}', :margin_bottom, ->(level){TITLES_MARGIN_BOT_DEFAULT[level]}],
  ['Leading (espacement lignes) pour le niveau %{level}', :leading, 0],
]

end # module Prawn4book
