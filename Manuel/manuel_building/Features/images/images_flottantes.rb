Prawn4book::Manual::Feature.new do

  titre "Images flottantes"


  description <<~EOT
    Cette partie décrit comment obtenir une image flottante dans le texte. Pour définir une image flottante, il faut définir deux choses indispensables :
    * Une image définissant la propriété `float` (cf. ci-dessous),
    * Un texte, *avant cette image*, commençant par "!".

    (( line ))
    Les paramètres pour gérer l’image flottante sont les suivants :
    * **`float`** | Définit que l’image est flottante. Ce paramètre peut avoir la valeur `:left` ("gauche" en anglais) pour "flottante à gauche" (l’image sera donc à gauche du texte) ou `:right` ("droite" en anglais) pour "flottante à droite" (l’image sera donc à droite du texte).
    * **`lines_before`** | Définit le nombre de lignes qui vont passer au-dessus de l’image. Par défaut à 0, la première ligne de texte est alignée au haut de l’image (en fonction de ligne de référence du texte).
    * **`margin_top`** | Définit la hauteur à laisser au-dessus de l’image, qu’il y ait ou non des lignes au-dessus.
    * **`margin_left`** | Marge à gauche. Quand l’image est flottante à gauche, détermine la distance de l’image avec la marge gauche. Quand l’image est flottante à droite, détermine la distance de l’image avec le texte à gauche.
    * **`margin_right`** | Marge à droite. Quand l’image est flottante à gauche, détermine la distance de l’image avec le texte à droite. Quand l’image est flottante à droite, déterminer la distance entre l’image et la marge droite.
    Note : on ne permet pas l’utilisation d’une image flottante au milieu, ce qui ne se fait jamais dans un livre qui n’est pas purement graphique.

    ##### Positionnement exact de l’image

    On peut déterminer le positionnement exact de l’image de façon générale, dans le recette (pour que toutes les images disposent de la même présentation) ou pour chaque image en particulier.

    {{QUESTION: Avec le système actuel, on ne peut que laisser la hauteur d’une ligne (<) au-dessus ou en dessous de l’image. Sinon, la place est remplie par une autre ligne. Il faudrait donc deux valeurs : une indiquant le nombre de lignes de texte au-dessus (aussi au-dessous) et l’écartement de l’image (margin_top) par rapport à ces lignes de texte. Pareillement, le margin_bottom indiquera l’espace entre le bas de l’image et la première ligne de texte restante.

    }}
    {{TODO: montrer comment une valeur négative pour :float_top permet de commencer l’image au-dessud du texte
      - montrer comment une valeur négative pour :right (quand c’est le flottement à gauche qui est demandé) permet de couvrir l’image
      - montrer comment un texte plutôt court n’écrit aucune ligne sous l’image
      - montrer comment un texte long écrit ses lignes sous l’image
      - montrer comment un texte long écrit ses lignes sous l’image mais en tenant compte du :float_bottom
      - montrer comment un left_margin éloigne de la marge gauche pour un float: :left
      - montrer comment un right_margin éloigne le texte de l’image
        pour un float: :left
      - montrer qu’il y a toujours une valeur par défaut pour le
        right_margin (quand float: :left) et le left_margin quand
        float: :right
      - montrer comment jouer sur left_margin et right_margin, avec les deux float, pour position l’image exactement où l’on veut et montrer l’incidence que ça peut avoir sur le texte (en montrant comment le texte s’adapte à ces valeurs)
      - voir comment les choses se passent quand on arrive en bas de page (par exemple, le cas piège serait celui où un peu de texte doit rester sur la page précédente et l’image doit passer à la page suivante)
      - montrer comment deux paragraphes courts, mais précédés de "!", s’enroulent autour de l’image. Contre : deux paragraphes courts, mais dont le deuxième n’est précédé de "!".

    }}
    EOT

  new_page_before(:sample_texte)

  sample_texte <<~EOT #, "Autre entête"
    \\!Un texte qui va simplement se placer à droite de l’image, sans dépasser ni en haut ni en bas.
    \\!\\[exemples/moins_large_border.jpg](float: :left, width: 100)
    \\(( line \\))
    \\!Texte placé à gauche d’une image qui porte le float à :right (flottante à droite) et le :width à 100.
    \\!\\[exemples/moins_large_border.jpg](float: :right, width: 100)
    \\(( line \\))
    \\!Un texte qui va commencer au-dessus de l’image, sur deux lignes, puis s’enrouler à droite de l’image pour repasser ensuite ses dernières lignes sous l’image. Aucune marge n’est ajouté à gauche (`margin_left: 0`) et une marge de 2 (donc toute petite) est définie entre l’image et le texte (`margin_right: 2`).
    \\!\\[exemples/moins_large_border.jpg](float: :left, lines_before: 2, floating_top: 30, width: 100, margin_left: 0, margin_right: 2)
    EOT

  texte(:as_sample)

end
