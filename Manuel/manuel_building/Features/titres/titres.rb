Prawn4book::Manual::Feature.new do

  titre "Définition des titres"


  description <<~EOT
    La format de base du texte étant le format markdown, on marque un titre dans le texte simplement grâce à des dièses suivi du titre (1 dièse => titre de niveau 1, 2 dièses => titre de niveau 2, etc.)

    Le format de ces titres sont définis par défaut pour s’afficher harmonieusement avec le texte, mais on peut en définir très précisément l’aspect dans la recette, grâce à la données `titles` ("titres" en anglais) dans le format du livre (donnée `book_format` — "format du livre" en anglais)
    (( line ))
    ~~~yaml
    # ./recipe.yaml ou ../recipe_collection.yaml
    book_format:
      titles:
        # ... définition des titres 
    ~~~
    (( line ))
    On peut commencer par y définir une fonte-string^^ qui s’appliquera à tous les niveaux de titre, pour définir par exemple la police spéciale à utiliser (mais chaque niveau pourra ensuite définir précisément ses données).
    ^^ Cf. [[annexe/font_string]]
    Par exemple :
    (( line ))
    ~~~yaml
    book_format:
      titles:
        font: "Helvetica/normal//222222"
    ~~~
    (( line ))
    *Noter ci-dessus que la taille (troisième membre de la fonte-string) n’est pas définie.*
    Ci-dessus, par défaut, tous les titres seront en Helvetica, de style normal, et de couleur noir très légèrement éclaircie (`222222`).


    #### Niveaux des titres

    Dans cette section de la recette (cf. ci-dessus), on définit chaque niveau de titre grâce à la propriété `level` ("niveau" en anglais) suivi du niveau de titre, de 1 à 7 (`level1`, `level2`, `level3`…).
    *Astuce : si vous n’utilisez que 4 niveaux de titre, vous pouvez utiliser les titres restants (5 à 7) pour formater des titres tout à fait spéciaux.*
    On trouve donc:
    (( line ))
    ~~~yaml
    book_format:
      titles:
        level1:
          # Données du titre de premier niveau
        level2:
          # Données du titre de second niveau
        level3:
          # Données du titre de troisième niveau
        # etc.
    ~~~
    (( line ))

    #### Données des niveaux de titres

    Chaque niveau de titre peut définir les données/propriétés ci-dessous, à commencer par définir les données de fonte (police).

    * **`font`** | La *fonte-string* à utiliser pour le niveau de titre en question, si elle doit être radicalement différente de la fonte par défaut des titres (cf. ci-dessus). Ou on peut se limiter à définir la taille par `"//42/"` mais dans ce cas, peut-être vaudrait-il mieux utiliser la propriété `size` ci-dessous.
    * **`size`** | Pour définir la taille de police, en points.
    * **`style`** | Pour (re)définir le style de de la police. Sinon, c’est le style par défaut qui sera utilisé. Ce style, bien entendu, doit être défini dans les fontes du livre^^.
    * **`color`** | Pour (re)définir la couleur du titre. Sinon, c’est la couleur par défaut qui sera utilisée.
    ^^ Cf. [[recette/definition_fontes]].

    (( line ))
    On peut également indiquer l’emplacement du titre en terme de page :
    * **`next_page`** | Si `true` ("vrai" en anglais), le titre sera placé sur une nouvelle page (paire ou impaire en fonction du flux du texte). Par défaut, seul le titre de premier niveau (`level1`) est placé sur une nouvelle page.
    * **`belle_page`** | Si `true`, le titre sera toujours placé sur une *belle page*, c’est-à-dire une page impaire, à droite. Par défaut, seul le titre de premier niveau est placé sur une *belle page*.
    * **`alone`** | ("seul" en anglais) Si `true` le titre sera seul sur la page (`next_page` sera automatiquement mis à `true)`. Le texte qui suit le titre sera placé sur la page suivante. Dans le cas d’un titre seul, la propriété `lines_before` ("lignes avant" en anglais) permet de placer le titre dans la page (plus ou moins haut). Par défaut, seul le titre de premier niveau est placé seul sur une page.

    (( line ))
    On peut ensuite définir les lignes qu’il faut laisser avant et après le titre grâce aux propriétés :
    * **`lines_before`** | ("lignes avant" en anglais) Nombre de lignes avant le titre.
    * **`lines_after`** | ("lignes après" en anglais) Nombre de lignes après le titre.
    Les *lignes* dont il est question ci-dessus sont des *lignes de référence*^^, car les textes sont toujours alignés, dans un livre bien formaté, et il en va de la même manière pour les titres.
    ^^ Cf. [[comportement/align_on_reference_lines]].
    _PFB_, c’est sa nature, adopte autant que possible un comportement intelligent par rapport à ces définitions. Par exemple, si le titre se trouve en haut de page — et que ça n’est pas un titre seul dans la page (cf. ci-dessus `alone`) — alors il n’ajoutera pas de lignes avant même si elles sont définies.
    De la même manière, quand deux titres se suivent, les lignes ne s’additionnent pas (ce qui laisserait des écarts trop importants, disgrâcieux). C’est la valeur la plus grande qui est appliquée. Par exemple, si le titre précédent définit "4 lignes après le titre" (`lines_after: 4`) et que le titre suivant définit "3 lignes avant le titre" (`lines_before: 3`), ce ne sont pas 7 lignes qui sont laissées entre les deux titres, mais 4.

    (( line ))
    On peut également définir d’autres modifications de détail du titre :
    * **`align`** | ("alignement" en anglais) Cette propriété permet de définir l’alignement du titre. Les valeurs peuvent être `left` ("gauche" en anglais) pour un alignement à gauche, `right` ("droite" en anglais) pour un alignement à droite ou `center` ("centre" en anglais) pour un centrage dans la page.
    * **`left`** | ("gauche" en anglais) À la place de la propriété `align` on peut définir précisément le décalage avec la marge gauche en donnant une valeur numérique (p.e. `40`) ou une dimension (p.e. `52mm`) à cette propriété.
    * **`right`** | ("droite" en anglais) À la place de la propriété `align` on peut définir précisément le décalage avec la marge droite en donnant une valeur numérique (p.e. `40`) ou une dimension (p.e. `52mm`) à cette propriété.
    * **`caps`** | Si `true` ("vrai" en anglais), les titres du niveau concerné seront toujours mis en capitales.
    * **`leading`** | ("interlignage" en anglais) Permet de définir l’interlignage, quand le titre tient sur plusieurs lignes et qu’il faut le définir précisément. Cette valeur peut être négative, pour rapprocher les lignes du titre.

    EOT

end
