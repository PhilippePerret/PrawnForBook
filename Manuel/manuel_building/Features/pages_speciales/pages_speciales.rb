Prawn4book::Manual::Feature.new do

  titre "Les Types de pages spéciales"


  description <<~EOT
    Les pages considérées comme *spéciales* dans _PFB_ sont les suivantes.
    * **Page de faux-titre**. Page contenant juste le titre et l’auteur. Par défaut, elle n’est pas placée dans un livre produit par _PFB_. Mettre `faux_titre` (ou `half_title_page`) à `true` dans la section `inserted_pages` de la recette pour l’imprimer.
    * **Page de garde**. Page vierge, après la couverture ou la page de faux titre si elle existe, qui permet de ne pas voir le titre par transparence. Par défaut, elle est placée dans un livre produit par _PFB_. Mettre `page_de_garde` (ou `endpage`) à `false` dans la section `inserted_pages` de la recette pour ne pas l’imprimer.
    * **Page de titre**. Page contenant toutes les informations de la couverture, le titre, le sous-titre éventuel, les auteurs, l’éditeur et son logo. Par défaut, elle est placée dans un livre produit par _PFB_. Mettre `page_de_titre` (ou `title_page`) à `false` dans la section `inserted_pages` de la recette pour ne pas l’imprimer.
    * **Page des crédits (colophon)**. Page, à la fin du livre, contenant une sorte de *générique* du livre, avec la liste de tous les intervants ayant contribué à la fabrication du livre (metteur en page, graphiste, concepteur de la couverture, etc.), les informations sur la maison d’édition, la date de parution, l’ISBN et tout autre renseignement utile. Par défaut, cette page n’est pas imprimée dans le livre. Mettre `page_credits` (ou `credits_page`) à `true` ou définir ses propriétés dans la section `inserted_pages` de la recette pour l’imprimer (cf. ci-dessous).
    * **Page d’index**. Page, vers la fin du livre, qui présente l’index de tous les mots… indexés.
    Nous allons aborder chaque page séparément. Ce que l’on peut retenir pour le moment, c’est que l’on détermine facilement dans la recette la présence ou non de ces pages dans la rubrique `inserted_pages:` (ci-dessous, ce sont les valeurs par défaut) :
    EOT

  sample_recipe <<~EOT, "Dans recipe.yaml"
    ---
    .\\..
    inserted_pages:
      page_de_garde:  true
      faux_titre:     false
      page_de_titre:
        title:
          font: "Times-Roman//18/000000"
          lines_before: 4
        copyright: "Tous droits réservés"
        logo:
          height: 10
      credits_page:   false
    EOT

end
