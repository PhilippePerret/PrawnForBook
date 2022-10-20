module Prawn4book

ERRORS = {


  # --- Bibliographie --- #
  biblio: {
    biblio_undefined: "La bibliographie d'identifiant '%s' est inconnue de la recette… Impossible d'enregistrer l'élément d'identifiant '%s'.",
    bib_item_unknown: "Impossible de trouver l'item %s dans la bibliographie '%s'…",
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
