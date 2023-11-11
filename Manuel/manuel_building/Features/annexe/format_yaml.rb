Prawn4book::Manual::Feature.new do

  titre "Le format YAML de la recette"

  description <<~EOT
    Le format *YAML* est un format très simple de présentation et de consignation des données.
    Il est utilisé dans _PFB_ pour définir [[recette/juste_titre]], que ce soit pour un livre unique (cf. page [[recette/recette_livre]]) ou pour une collection (cf. page [[recette/recette_collection]]).

    Les données sont *imbriquées*, comme nous l'avons dit, pour s'y retrouver plus facilement, entendu que les recettes peuvent contenir de nombreuses informations. Voyez l’imbrication donnée en exemple ci-dessous.

    EOT

  sample_recipe <<~EOT
    ---
    table_de_donnees:
      sous_ensemble_liste:
        - premier item
        - deuxième item
      sous_ensemble_texte: "Ma donnée texte"
      un_nombre: 12
      une_date: "2023-11-22"
      quelquun:
        prenom: "Marion"
        nom: "MICHEL"

    EOT

end
