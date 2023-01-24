module Prawn4book

ERRORS = {

  # --- Application --- #

  require_a_book_or_collection: "Il faut se trouver dans un dossier de livre ou de collection.",
  unfound_folder: "Le dossier '%s' est introuvable…",

  # --- Général --- #

  required_property: "La propriété %s est requise.",
  required_asterisk_properties: "Toutes les propriétés marquées d'un astérisque rouge sont requises.",
  
  invalid_data: "La donnée %s de value %s est invalide.", 

  # --- Texte du livre ---
  
  unfound_text_file: "Le fichier texte %s est introuvable…",

  # --- Recette en général --- #

  recipe: {
    main_folder_not_defined: "La propriété :main_folder n'est pas définie, dans la recette…",

  }, #/ :recipe

  # --- Maison d'éditions ---

    publishing: {
      logo_unfound: "Logo introuvable à l'adresse '%s'",
      logo_not_same_extname: "Les deux images doivent avoir la même extension.", 
    },

  # --- Bibliographie --- #

  biblio: {
    biblio_undefined: "La bibliographie d'identifiant '%s' est inconnue de la recette… Impossible d'enregistrer l'élément d'identifiant '%s'.",
    bib_item_unknown: "Impossible de trouver l'item %s dans la bibliographie '%s'…",
    title_already_exists: "Ce titre existe déjà.",
    tag_already_exists: "Ce tag est déjà utilisé. Choisissez-en un autre.",
    bad_tag: 'Tag non conforme. Il ne devrait contenir que des lettres minuscules.',
    not_an_existing_file: "Le path fourni ne renvoie ni à un fichier ni à un dossier (en valeur absolue ou relative).",
    warn_end_with_s: "Ce tag finit par 's'. En général, les tags sont au singulier.\nMais si vous êtes sûr de vous, pas de problème.",

  }, #/biblio

  # --- Références --- #
  references: {
    cross_book_undefined: "Le livre d'identifiant '%s' n'est pas défini pour les références croisées…",
    cross_path_undefined: "Aucune path n'est définie pour le livre '%s'…",
    cross_book_unfound: "Le livre d'identifiant '%s' est introuvable au path '%s'…",
    cross_book_data_unfound: "Le livre '%s' (%s) ne possède pas de fichier 'references.yaml' définissant ses références…",
    cross_ref_undefined: "La référence '%s' dans le livre identifié '%s' est introuvable.",
    bib_livre_not_defined: "La bibliographie 'livre' n'est pas définie. Consultez le manuel pour plus d'information.",
    book_undefined_in_bib_livre: "Le livre d'identifiant '%s' n'est pas défini dans la bibliographie 'livre'.",
  }, #/:references


}
end #/module Prawn4book
