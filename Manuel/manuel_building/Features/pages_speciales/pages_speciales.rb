Prawn4book::Manual::Feature.new do

  titre "Les Types de pages spéciales"


  description <<~EOT
    Les pages considérées comme *spéciales* dans _PFB_ sont les suivantes.
    * **Page de faux-titre**. Page contenant juste le titre et l’auteur. Par défaut, elle n’est pas placée dans un livre produit par _PFB_. Mettre `faux_titre` (ou `half_title_page`) à `true` dans la section `inserted_pages` de la recette pour l’imprimer.
    * **Page de garde**. Page vierge, après la couverture ou la page de faux titre si elle existe, qui permet de ne pas voir le titre par transparence. Par défaut, elle est placée dans un livre produit par _PFB_. Mettre `page_de_garde` (ou `endpage`) à `false` dans la section `inserted_pages` de la recette pour ne pas l’imprimer.
    * **Page de titre**. Page contenant toutes les informations de la couverture, le titre, le sous-titre éventuel, les auteurs, l’éditeur et son logo. Par défaut, elle est placée dans un livre produit par _PFB_. Mettre `page_de_titre` (ou `title_page`) à `false` dans la section `inserted_pages` de la recette pour ne pas l’imprimer.

    #### Page des mentions légales

    C’est la page du fameux *copyright*. Cette page se trouve après la page de titre. Si le copyright est défini dans la recette, cette page est automatiquement créée sans que vous ayez rien à faire.
    Le copyright doit être défini dans :
    (( line ))
    ~~~yaml
    inserted_pages:
      copyright: |
        @Philippe Perret, 2023-#{Time.now.year}

        Le Code de la propriété intellectuelle interdit etc.
    ~~~
    (( line ))

    #### Page de dédicace<-(page_dedicace)

    Si le livre est dédicacé à quelqu’un, c’est sur cette page qu’on peut l’indiquer. Une dédicace peut faire plusieurs pages. Comme vous pouvez le voir en annexe ([[annexe/pages_dun_livre]]), cette dédidace se trouve en face de la mention légale, donc sur la page suivante.
    Si elle contient plusieurs pages, alors la page de dédicace doit être numérotée. Concrètement, il faut réfléchir à l’envers : il faut retirer la page de dédice des pages à numéroter. Pour faire cela, dans le texte, avant les dédicaces (si elles ne font pas plus d’une page), il faut indiquer `\\(( stop_pagination ))` ("arrêter la pagination" en anglais) et remettre  `\\(( restart_pagination ))` ("reprendre la pagination" en anglais) à la fin de la dédicace (ces deux marques doivent se trouver toutes seules sur une ligne) :
    (( line ))
    ~~~
    (( stop_pagination ))
    Remerciements à
      Ma femme et mes enfants
      Et tous mes collaborateurs
    (( restart_ pagination ))
    ~~~
    (( line ))

    #### Table des matières

    Normalement, elle se met sur la page droite (la *belle page*) mais lorsqu’elle ne fait que deux pages, nous estimons plus harmonieux de la mettre en vis à vis, sur la page gauche et la page droite en regard.

      Cette page n’est jamais numérotée, mais il n’y a rien à faire, _PFB_ s’en charge pour vous.

    #### Page(s) des remerciements

    C’est toujours bien de remercier, avant le texte, les gens qui vous ont aidé dans la conception de votre projet de livre.
    La page des remerciements (qui peut faire plusieurs pages), se trouve toujours sur une *belle page*, donc une page impaire, à droite.
    Elle est créée par vous, dans le texte du livre, juste après la marque de la table des matières.

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
