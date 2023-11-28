Prawn4book::Manual::Feature.new do


  subtitle "Personnalisation des bibliographiques"

  description <<~EOT
    Comme pour tout éléménet de _PFB_, on peut le garder simple ou au contraire le formater tel qu’on le désire. C’est pratiquement incontournable pour les bibliographies, au moins au niveau de la *liste des sources*.

    ##### Définir la fonte

    Il n’est pas très heureux de modifier la fonte à l’intérieur d’un texte, ça le rend beaucoup plus compliqué à lire et même à afficher. En revanche, on peut profitablement introduire des pictogrammes discrets qui permettent de caractériser les éléments.
    EOT


  sample_real_recipe(:bibliographies, "Extrait de la recette")

  sample_texte <<~EOT
    Un custom\\(premier) pour voir.
    \\(( new_page ))
    \\(( biblio(custom) ))
    \\(( new_page ))
    EOT

  texte(:as_sample)

  init_recipe([:bibliographies])

end
