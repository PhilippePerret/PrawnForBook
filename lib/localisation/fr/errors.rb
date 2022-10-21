module Prawn4book

ERRORS = {

  # --- Application --- #

  require_a_book_or_collection: "Il faut se trouver dans un dossier de livre ou de collection.",

  # --- Recette --- #

  recipe: {

    headers: {
      required: 'La définition des entêtes (:headers) est absolument requise.',
    },
    footers: {
      requires: 'La définition des pieds de pages (:footers) est absolument requise.',
    },

  }, #/ :recipe

  # --- Bibliographie --- #

  biblio: {
    biblio_undefined: "La bibliographie d'identifiant '%s' est inconnue de la recette… Impossible d'enregistrer l'élément d'identifiant '%s'.",
    bib_item_unknown: "Impossible de trouver l'item %s dans la bibliographie '%s'…",
    title_already_exists: "Ce titre existe déjà.",
    tag_already_exists: "Ce tag est déjà utilisé.",
    not_an_existing_file: "Le path fourni ne renvoie ni à un fichier ni à un dossier (en valeur absolue ou relative).",

  }, #/biblio

  # --- Références --- #
  references: {
    data_undefined: "Données références (:references) non définies dans le fichier recette…",
    cross_data_undefined: "Aucune donnée livre n'est définie pour les références croisées",
    cross_book_undefined: "Le livre '%s' n'est pas défini pour les références croisées…",
    cross_path_undefined: "Aucune path n'est définie pour le livre '%s'…",
    cross_book_unfound: "Le livre d'identifiant '%s' est introuvable au path '%s'…",
    cross_book_data_unfound: "Le livre '%s' (%s) ne possède pas de fichier 'references.yaml' définissant ses références…",
    cross_ref_undefined: "La référence '%s' dans le livre identifié '%s' est introuvable.",
    bib_livre_not_defined: "La bibliographie 'livre' n'est pas définie. Consultez le manuel pour plus d'information.",
    book_undefined_in_bib_livre: "Le livre d'identifiant '%s' n'est pas défini dans la bibliographie 'livre'.",
  }, #/:references


}
end #/module Prawn4book
