Prawn4book::Manual::Feature.new do

  titre "Les Types de pages spéciales"


  description <<~EOT
    Les pages considérées comme *spéciales* dans _PFB_ sont les suivantes :
    * la **page de garde**. C’est la page vierge, après la couverture,
    * la **page de faux-titre**. Page contenant juste le titre, l’auteur,
    * la **page de titre**. Page contenant toutes les informations de la couverture, le titre, le sous-titre éventuel, les auteurs, l’éditeur et son logo,
    * la **page d’informations**. Page, à la fin du livre, contenant une sorte de *générique* du livre, avec la liste de tous les intervants (metteur en page, graphiste, concepteur de la couverture, etc.), les informations sur la maison d’édition, la date de parution, l’ISBN et tout autre renseignement utile.
    Nous allons aborder chaque page séparément. Ce que l’on peut retenir pour le moment, c’est que l’on détermine facilement dans la recette la présence ou non de ces pages dans la rubrique `inserted_pages:` (ci-dessous, ce sont les valeurs par défaut) :
    EOT

  sample_recipe <<~EOT, "Dans recipe.yaml"
    ---
    .\\..
    inserted_pages:
      page_de_garde:  true
      faux_titre:     false
      page_de_titre:  true
      credits_page:     false
    EOT

end
