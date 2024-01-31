Prawn4book::Manual::Feature.new do


  subtitle "Personnalisation des bibliographiques"

  description <<~EOT
    Comme pour tout élément de _PFB_, on peut le garder simple ou au contraire le formater tel qu’on le désire. C’est pratiquement incontournable pour les bibliographies, au moins au niveau de la *liste des sources*.

    ##### Définir la fonte

    Il n’est pas très heureux de modifier la fonte à l’intérieur d’un texte, ça le rend beaucoup plus compliqué à lire et même à afficher. En revanche, on peut profitablement introduire des pictogrammes discrets qui permettent de caractériser les éléments.

    ##### Formatage de la liste des sources bibliographiques

    Si la propriété `format` de la bibliographie est fournie dans la recette, elle se sert de marques de type "`\\%\\{\\<propriété>}`" où "`\\<propriété>`" est une donnée des items de la bibliographie (à commencer par "`title`", le titre, le nom) pour définir le format à utiliser.
    La valeur de cette propriété peut être gardée telle quelle où modifiée, par exemple mise en capitales, en minuscule, sous format de date si c’est une date, etc. On ajoute pour ça le nom de la méthode de transformation après un trait droit "|" :
    (( line ))
    (( {align: CENTER} ))
    `\\%\\{<propriété>|\\<méthode transformation>}`
    *(voir plus bas les méthodes de transformation par défaut dans _PFB_)*
    Par exemple :
    (( line ))
    (( {align: :left} ))
    `format: "%{title|all_caps} (%{year} — %{year|age}, réalisation : %{director|person}, acteurs : %{actors|person}, durée : %{duration|horloge})"`
    (( line ))
    Ce *format* va afficher le titre, tout en majuscules (`all_caps`), puis, entre parenthèses, l’année de sortie (`year` qui signifie "année" en anglais), le réalisateur (précédé du terme "réalisation :" et traité comme un individu) et enfin la liste des acteurs et actrices, traités comme des individus, précédée de la marque "acteurs :".
    Optionnellement, si la liste des références ne doit pas s’afficher à la suite de l’*item* après un double-point, ajouter `%\\{pages}` à l’endroit voulu.
    Vous pouvez voir ci-dessous le rendu de ce formatage.

    ##### Méthode de formatage de propriété communes

    * `all_caps` | Met la donnée en majuscule.
    * `person` | Transforme une donnée "Prénom NOM" en "Prénom Nom" ou une liste de personnes de la même manière.
    * `age` | Transforme une donnée "année" en âge par rapport à maintenant.
    * `horloge` | Tranforme une donnée secondes en horloge de type `h:mm:ss`.
    * `minute_to_horloge` | Tranforme une donnée minutes en horloge de type `h:mm:ss`.
    (( line ))
    En mode expert (cf. [[expert/bibliographies]]) vous pouvez également définir toutes formes de méthodes de transformation.

    EOT


  sample_real_recipe(:bibliographies, "Extrait de la recette")

  sample_texte <<~EOT
    Un costum\\(cravate) pour voir.
    \\(( new_page ))
    \\(( biblio\\(costum) ))
    \\(( new_page ))
    EOT

  texte(:as_sample)

  init_recipe([:bibliographies])

end
