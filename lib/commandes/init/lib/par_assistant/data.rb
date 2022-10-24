module Prawn4book
class PdfBook


DIM_VALUES = [
  {name:'12,7 cm x 20,32 cm (5 x 8 po)' , value:[127, 203.2]   },
  {name:'A4 (21 x 29.7)'                , value:[210, 297]     },
  {name:'15,24 x 22,86 (6 x 9 po)'      , value:[152.4, 228.6] },
  {name:'A5 (14.85 x 21)'               , value:[148.5, 210]   },
  {name:'Autre dimension…'              , value: nil }
]

TYPE_INITIED = [
  {name:'Un livre',       value: :book}, 
  {name:'Une collection', value: :collection},
  {name:'Renoncer',       value: nil}
]


RECIPE_PROPERTIES = [
  #
  # LISTE DES PROPRIÉTÉS À DÉFINIR
  # -------------------------------
  # 
  # [1] False si le livre n'appartient pas à une collection,
  #     True s'il appartient à la collection dans le dossier de
  #     laquelle il se trouve. 
  #     Ou le string du chemin d'accès au dossier de la collec-
  #     tion
  # 
  # [C] Les propriétés marquées de [C] seront pris de la recette
  #     de la collection si définies


  :book_title,      # {String} Le titre du livre
  :collection,      # {False|True|String} [1] False si le livre n'appartient
                    # pas à un
  :book_id,         # {String} Identifiant du livre
  :auteurs,         # {Array} Auteurs du livre. Array "Prénom NOM"
  :main_folder,     # {String} Dossier principal du livre
  :text_path,       # {String} Chemin d'accès au fichier du texte original
  :dimensions,      # [C] {Array} [width, height]
  :marges,          # [C] {Hash} {:top, :int, :ext, :bot} 
  :interligne,      # [C] {Number}
  :opt_num_parag,   # [C] {Bool} Numéroter les paragraphes
  :fonts,           # [C] {Hash} Les fonts utilisées
  :num_page_style,  # [C] {String|Bool} Le type de numérotation pour la page
  # :header,
  # :footer,

]

end #/class PdfBook
end #/module Prawn4book
