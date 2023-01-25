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
    instanciation_requires_book: "Une livre est requis, pour l'instanciation d'une bibliographie.",
    data_undefined: "La recette du livre ou de la collection ne définit aucun donnée bibliographique (consulter le mode d'emploi pour remédier au problème ou lancer l'assistant bibliographies).",
    biblios_malformed: "La recette bibliographie (:biblios) devrait être une table (un item par type d'élément).",
    formater_required: "Un fichier 'formater.rb' devrait exister dans '%s' pour définir la mise en forme à adopter pour la bibliographie.",
    formater_malformed: "Le fichier formater.rb devrait définir le module 'FormaterBibliographiesModule'\n(bien vérifier le nom, avec un pluriel)…",
    biblio_malformed: "La donnée recette de la bibliographie '%s' est malformée : ",
    malformation: {
      title_undefined: "Le titre (:title) doit être défini",
      path_undefined: "Le chemin d'accès au dossier des items doit être défini (:path) et non nil.",
      path_unfound: "Le dossier des fiches bibliographiques est introuvable… ('%s' cherché en tant que chemin absolu ou relatif dans le dossier du livre ou de la collection)",
    },
    bad_format_bibitem: "Le format '%s' est un format de données bibliographique invalide.",
    biblio_method_required: "Le module FormaterBibliographiesModule dans formater.rb doit définir la méthode 'biblio_%s'…",
    biblio_undefined: "La bibliographie d'identifiant '%s' est inconnue de la recette…",
    biblio_item_undefined: "La bibliographie d'identifiant '%s' est inconnue de la recette… Impossible d'enregistrer l'élément d'identifiant '%s'.",
    bib_item_unknown: "Impossible de trouver l'item %s dans la bibliographie '%s'…",
    title_already_exists: "Ce titre existe déjà.",
    tag_already_exists: "Ce tag est déjà utilisé. Choisissez-en un autre.",
    bad_tag: 'Tag non conforme. Il ne devrait contenir que des lettres minuscules.',
    not_an_existing_file: "Le path fourni ne renvoie ni à un fichier ni à un dossier (en valeur absolue ou relative).",
    warn_end_with_s: "Ce tag finit par 's'. En général, les tags sont au singulier.\nMais si vous êtes sûr de vous, pas de problème.",
    # - cross-referenre -
    uncrossable: "Le livre %s n'est pas “croisable”. ",
    crossable_requires_refs_path: "Un livre “croisable” nécessite de définir le chemin d'accès à son dossier ou son fichier de références (:refs_path dans sa fiche).",
    book_requireds_building_for_refs:"Il faut construire le livre pour obtenir ses références",
    crossable_refs_path_unfound: "Le chemin d'accès au fichier de référence du livre est introuvable (in %s)",
    crossable_requires_recipe_or_refsfile: "Un livre ”croisable” nécessite un fichier recette (quand c'est un prawn-book) ou un fichier références 'references.yaml' (quand c'est un livre quelconque).",
  }, #/biblio

  # --- Références --- #
  references: {
    cross_book_undefined: "Le livre d'identifiant '%s' n'est pas défini pour les références croisées…",
    cross_path_undefined: "Aucune path n'est définie pour le livre '%s'…",
    cross_book_unfound: "Le livre d'identifiant '%s' est introuvable au path '%s'…",
    cross_book_data_unfound: "Le livre '%s' (%s) ne possède pas de fichier 'references.yaml' définissant ses références…",
    cross_ref_unfound: "La référence '%s' dans le livre identifié '%s' est introuvable.",
    bib_livre_not_defined: "La bibliographie 'livre' n'est pas définie. Consultez le manuel pour plus d'information.",
    book_undefined_in_bib_livre: "Le livre d'identifiant '%s' n'est pas défini dans la bibliographie 'livre'.",
  }, #/:references


}
end #/module Prawn4book
