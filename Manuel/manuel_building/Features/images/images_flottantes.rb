Prawn4book::Manual::Feature.new do

  new_page_before(:feature)

  titre "Les Images flottantes"

  description <<~EOT
    Cette partie décrit comment obtenir une image flottante dans le texte. Pour définir une image flottante, il faut définir deux choses indispensables :
    * Une image définissant la propriété `float` (cf. ci-dessous),
    * Un texte, *avant cette image*, commençant par "!".

    (( line ))
    Les paramètres pour gérer l’image flottante sont les suivants :
    * **`float`** | Définit que l’image est flottante. Ce paramètre peut avoir la valeur `:left` ("gauche" en anglais) pour "flottante à gauche" (l’image sera donc à gauche du texte) ou `:right` ("droite" en anglais) pour "flottante à droite" (l’image sera donc à droite du texte).
    * **`lines_before`** | Définit le nombre de lignes qui vont passer au-dessus de l’image. Par défaut à 0, la première ligne de texte est alignée au haut de l’image (en fonction de ligne de référence du texte).
    * **`margin_top`** | Définit la hauteur à laisser au-dessus de l’image, qu’il y ait ou non des lignes au-dessus. En ne jouant que sur ce paramètre, on ne peut pas faire passer de lignes au-dessus de l’image (utiliser `lines_before` pour ça).
    * **`vadjust`** | Lorsque le `margin_top` ne permet pas de positionner l’image verticalement, on peut se servir de cette propriété *traditionnelle*.
    * **`margin_left`** | Marge à gauche. Quand l’image est flottante à gauche, détermine la distance de l’image avec la marge gauche. Quand l’image est flottante à droite, détermine la distance de l’image avec le texte à gauche. Cette valeur peut être déterminée par défaut dans la recette comme indiqué ci-dessous.
    * **`margin_right`** | Marge à droite. Quand l’image est flottante à gauche, détermine la distance de l’image avec le texte à droite. Quand l’image est flottante à droite, déterminer la distance entre l’image et la marge droite. Cette valeur peut être déterminée par défaut dans la recette comme indiqué ci-dessous.
    * **`margin_bottom`** | Marge en bas entre le bas de l’image et la première ligne du texte associé à l’image. Attention : il s’agit bien du *texte associé à l’image* et non pas d’un paragraphe suivant qu’il faut éloigner de l’image soit avec `space_after` soit avec des `\\(( line ))`.
    * **`text_width`** | Largeur que doit occuper le texte à côté de l’image. Si non défini, tout l’espace possible.
    Note : on ne permet pas l’utilisation d’une image flottante au milieu, ce qui se fait rarement dans un livre qui n’est pas purement graphique.

    ##### Positionnement exact de l’image

    On peut déterminer le positionnement exact de l’image de façon générale, dans le recette (pour que toutes les images disposent de la même présentation) ou pour chaque image en particulier.

    ##### Passage naturel à la page suivante

    Pour le moment, _PFB_ ne gère pas le passage naturel à la page suivante lorsque l’image et son texte enroulé ne tiennent pas dans la page. Il faut donc le gérer *manuellement*, à l’aide de `\\(( line \\))` et de `\\(( new_page \\))` par exemple.

    ##### Rotation de l’image

    Pour le moment, en mode simple, _PFB_ ne permet pas d’effectuer une rotation de l’image. Mais cette fonctionnalité sera implémentée plus tard.
    Pour le moment, la solution consiste à faire une image déjà tournée et à jouer sur des valeurs négatives pour bien placer le texte. Ou, en mode expert, à l’imprimer explicitement avec du code ruby.

    EOT

  new_page_before(:sample_texte)

  texte <<~EOT, "Exemples divers"

    #### Texte enroulé autour de l’image

    Le paragraphe précédent est, par défaut, collé au paragraphe qui va "contenir" l’image.
    !Un texte avec deux lignes au-dessus de l’image et qui va s’enrouler ensuite par la droite jusqu’au milieu de l’image ensuite. Il est obtenu avec un *float* à *:left*, un *lines_before* à 2 et ensuite toutes les marges à 0. Le *margin_top* à 0 fait que l’image "colle" aux deux lignes supérieures. Le *margin_left* fait que l’image "colle" à la marge gauche et le *margin_right* fait que le texte "colle" à l’image. Et enfin, le *margin_bottom* fait que le texte qui passe sous l’image est collé à l’image comme le texte au-dessus. Noter cependant que le texte, se plaçant toujours sur des lignes de référence, se trouve plus éloigné de l’image en bas car la ligne de référence se trouve plus loin. En fonction du texte, on joue sur les propriétés *margin_top* et *margin_bottom* pour obtenir la meilleure harmonie. Il faut toujours s’arranger pour que l’air au-dessus et au-dessous de l’image soit toujours le même. C’est ce que l’on fait avec l’image suivante, en partant sur les mêmes bases que cette image-ci.
    ![exemples/moins_large_border.jpg](float: :left, lines_before: 2, width: 100, margin_top: 0, margin_left: 0, margin_right: 0)
    (( line ))
    Le paragraphe précédent.
    !Même chose que ci-dessus, mais la position de l’image a été ajustée avec un `margin_top: 4` pour être bien au millieu verticalement. Obtenu avec un `float: :left`, un `lines_before: 2` et les deux marges `margin_left` et `margin_right` à 0. Le *margin_left* fait que l’image "colle" à la marge gauche et le *margin_right* fait que le texte "colle" à l’image. Et enfin, le *margin_bottom* fait que le texte qui passe sous l’image est collé à l’image comme le texte au-dessus. Noter cependant que le texte, se plaçant toujours sur des lignes de référence, se trouve plus éloigné de l’image en bas car la ligne de référence se trouve plus loin. En fonction du texte, on joue sur les propriétés *margin_top* et *margin_bottom* pour obtenir la meilleure harmonie. Il faut toujours s’arranger pour que l’air au-dessus et au-dessous de l’image soit toujours le même. C’est ce que l’on fait avec cette image, en partant sur les mêmes bases que l’image précédente.
    ![exemples/moins_large_border.jpg](float: :left, lines_before: 2, width: 100, margin_top: 4, margin_left: 0, margin_right: 0)
    (( line ))
    Le paragraphe précédent.
    !Même chose que ci-dessus, mais avec les valeurs de marge droite et gauche (`margin_left` et `margin_right`) laissées à leur valeur par défaut, c’est-à-dire respectivement 0 et 10. Donc : `float: :left`, position de l’image a été ajustée avec un `margin_top: 4` pour être bien au millieu verticalement. `lines_before: 2` pour laisser deux lignes au-dessus, `margin_left` à 0 et `margin_right` à 10. Et enfin, le *margin_bottom* fait que le texte qui passe sous l’image est collé à l’image comme le texte au-dessus. Pour rappel, ce texte s’enroule autour de l’image parce qu’il est précédé d’un point d’interrogation (`!Même chose que ci-dessus, [etc.]`). En fonction du texte, on joue sur les propriétés *margin_top* et *margin_bottom* pour obtenir la meilleure harmonie. Il faut toujours s’arranger pour que l’air au-dessus et au-dessous de l’image soit toujours le même.
    ![exemples/moins_large_border.jpg](float: :left, lines_before: 2, width: 100, margin_top: 4)

    (( new_page ))

    Le paragraphe précédent.
    !Ce texte commence avec deux lignes au-dessus de l’image car `lines_before` est à 2, puis s’enroule à droite de l’image pour repasser ensuite ses dernières lignes sous l’image. Aucune marge n’est ajoutée à gauche (`margin_left: 0`) et un espace de 40 (donc plus grand que l’espace par défaut qui est de 10) est défini entre l’image et le texte grâce à la propriété `margin_right`).
    !De la même manière que pour le haut, on a mis un `margin_bottom` à une grosse valeur pour montrer comment on peut avoir beaucoup d’espace entre le texte et l’image en jouant sur toutes ces propriétés.
    !On voit aussi grâce à cet exemple comment plusieurs paragraphes peuvent être "enroulés" autour d’une image simplement en les précédant d’un point d’exclamation (voir le code du texte et le rendu). Noter que le nombre de lignes sous l’image n’a pas besoin d’être précisé, contrairement au nombre de lignes au-dessus, puisque c’est simplement tout le texte restant qui sera écrit sous l’image, au besoin. Ici, on n’aura que deux lignes, mais ça pourra dépendre encore des changements de taille du présent manuel.
    ![exemples/moins_large_border.jpg](float: :left, width: 100, lines_before: 2, margin_top: 30, margin_left: 0, margin_right: 40, margin_bottom: 30)
    (( new_page ))

    #### Texte à côté de l’image

    Le paragraphe précédent.
    !Un texte qui va simplement se placer à droite de l’image, sans dépasser ni en haut ni en bas, avec `float: :left` et `width: 100`. Code :
    !{-}`\\!Un texte qui va simplement [etc.]`.
    !{-}`\\!\\[exemples/image.jpg](float: :left, width: 100)`
    ![exemples/moins_large_border.jpg](float: :left, width: 100)
    Le paragraphe qui suit l’image se place bien en dessous et, normalement, ne doit pas être mangé par le bas de l’image.
    (( line ))
    Le paragraphe précédent.
    !Texte placé à gauche d’une image qui porte le float à :right (flottante à droite) et le :width à 100. Code :
    !{-}`\\!Text placé à gauche d’une [etc.]`
    !{-}`\\!\\[exemples/image.jpg](float: :right, width: 100)`
    ![exemples/moins_large_border.jpg](float: :right, width: 100)
    Le paragraphe qui suit l’image se place bien en dessous et, normalement, ne doit pas être mangé par le bas de l’image.
    (( new_page ))

    #### Image flottante avec légende

    Le paragraphe précédent.
    !Un texte qui s’enroule autour d’une image flottante à droite qui possède une légende normale et toutes les valeurs par défaut.
    !Code utilisé :
    !{-}`\\!Un texte qui s’enroule autour d’une [etc.]`
    !{-}`\\!\\[exemples/image.jpg](float: :right, legend: "La légende de l’image")`
    ![exemples/moins_large_border.jpg](float: :right, legend: "La légende de l’image")
    (( line ))
    Le paragraphe précédent.
    !Dans cet exemple d’image avec une légende, le texte s’enroule vraiment autour de l’image c’est-à-dire qu’un `lines_before` à `2` permet de laisser passer deux lignes au-dessus et la longueur du texte fait passer des lignes en dessous de la légende. Un `margin_left` à `20` permet de décoller l’image de la marge gauche tandis qu’un `margin_right` à `20` éloigne un peu le texte horizontalement. Un `margin_bottom` à `8` fait descendre d’une ligne les lignes sous l’image et pour bien positionner verticalement l’image et sa légende, un `vadjust` à `12` fait descendre l’image (ce qui est nécessaire puisque le texte se place toujours sur les lignes de référence — il est donc nécessaire, en fonction de l’image, d’ajuster la position verticale comme on le ferait à la main).
    ![exemples/moins_large_border.jpg](float: :left, width: 100, height: 50, legend: "La légende de l’image", lines_before: 2, vadjust: 12, margin_bottom: 8, margin_left: 20, margin_right: 20)
    (( line ))
    Pour obtenir l’effet ci-dessus, on a utilisé le code :
    {-}`\\!Dans cet exemple d’image avec une légende, le texte [etc.]`
    {-}`\\!\\[exemples/image.jpg](float: :left, width: 100, height: 50, legend: "La légende de l’image", lines_before: 2, vadjust: 12, margin_bottom: 8, margin_left: 20, margin_right: 20)`

    (( new_page ))

    #### Autre cas d’utilisation

    Le paragraphe précédent.
    !Pour une image qui flotte à gauche (`float: :left`), éloignement de la marge gauche avec un `margin_left` à 40. Le texte est éloigné de l’image avec un `margin_right` à 20 au lieu de la valeur par défaut 10.
    ![exemples/moins_large_border.jpg](float: :left, width: 100, margin_left: 40, margin_right: 20)
    (( line ))
    Le paragraphe précédent.
    !Pour une image qui flotte à droite (`float: :right`), éloignement de la marge droite avec un `margin_right` à 40. Le texte est éloigné de l’image avec un `margin_left` à 20 au lieu de la valeur par défaut 10.
    ![exemples/moins_large_border.jpg](float: :right, width: 100, margin_right: 40, margin_left: 20)
    (( line ))
    Le paragraphe précédent.
    !On peut définir la largeur que devra prendre le texte avec la propriété `text_width` qui est mise ici à 200 pour produire un  effet de légende sur le côté. Le `margin_left` est à 40, ainsi que le `margin_right`.
    ![exemples/moins_large_border.jpg](float: :left, width: 100, text_width: 200, margin_left: 40, margin_right: 40)
    (( new_page ))

    #### Adaptations naturelles du texte

    Montrons quelques cas d’adaptation du texte à l’image en fonction de quelques propriétés comme les marges et la largeur du texte.
    !Un largeur de texte normale, un simple `float: :left` avec dimensionnement de l’image (pour avoir moins de lignes)
    ![exemples/moins_large_border.jpg](float: :left, width: 150, height:44)
    (( line ))
    Le paragraphe précédent.
    !On place une ligne au-dessus (`lines_before: 1`) et une largeur de texte plus réduite (`text_width: 200`) mais qui ne sera donc appliquée que lorsque le texte passera à côté de l’image. Lorsqu’il repassera en dessous, il trouvera sa largeur normale. On a ajouté un petit espace sous l’image (`margin_bottom: 8`) pour que le texte en soit pas trop collé à l’image en dessous (pour qu’il passe sur le ligne de référence suivante).
    ![exemples/moins_large_border.jpg](float: :left, width: 150, height:44, text_width: 200, lines_before: 1, margin_bottom: 8)
    (( line ))
    Le paragraphe précédent.
    !La même chose que précédemment, mais en éloignant l’image de la marge avec `margin_left: 30` et en éloignant le texte de l’image avec `margin_right: 45`. Toutes les autres valeurs restent similaires et notamment le `margin_bottom: 8` qui permet de passer cette ligne sur la bonne ligne de référence.
    ![exemples/moins_large_border.jpg](float: :left, width: 150, height:44, text_width: 200, lines_before: 1, margin_bottom: 8, margin_left: 30, margin_right: 45)
    (( line ))
    Le paragraphe précédent.
    !Et enfin, toujours en s’inspirant de l’image ci-dessus, on se sert de la propriété `vadjust: 5` (ajustement vertical) pour équilibrer l’espace vertical entre le texte et l’image, pour qu’il y ait le même espace au-dessus et au-dessous et qu’ainsi l’image soit affichée de façon plus équilibrée.
    ![exemples/moins_large_border.jpg](float: :left, width: 150, height:44, text_width: 200, lines_before: 1, margin_bottom: 8, margin_left: 30, margin_right: 45, vadjust: 5)
    (( line ))

    #### Cas spéciaux

    (( line ))
    (( line ))
    (( line ))
    (( line ))
    Le paragraphe précédent.
    !Un texte qui va être placé plus bas, presque au milieu de l’image, grâce à un `margin_top` négatif.
    ![exemples/moins_large_border.jpg](float: :right, margin_top: -40)
    Pour obtenir l’effet ci-dessus, nous avons eu recours à :
    {-}`(\\( line )\\)`
    {-}`(\\( line )\\)`
    {-}`(\\( line )\\)`
    {-}`(\\( line )\\)`
    {-}`\\!Un texte qui va être placé plus bas, presque au milieu de l’image, grâce à un \\`margin_top\\` négatif.`
    {-}`\\!\\[exemples/moins_large_border.jpg](float: :right, margin_top: -40)`
    (( line ))
    Le paragraphe précédent.
    !**<font size="16"><color rgb="FF0000">Un texte qui va "manger" sur l’image en mettant un \\`margin_right\\` négatif.</color></font>**
    ![exemples/moins_large_border.jpg](float: :left, margin_right: -40)
    L’effet ci-dessus est obtenu à partir du code :
    {-}`\\!\\*\\*\\<font size="16">\\<color rgb="FF0000">Un texte qui va "manger" sur […] négatif.\\</color>\\</font>**`
    {-}`\\!\\[exemples/image.jpg](float: :left, margin_right: -40)`


    #### Cas d’erreurs avec les images flottantes

    Parfois, il peut arriver que l’image et son texte se placent une ligne trop bas, laissant une ligne vide avec le paragraphe précédent. Dans ce cas, pour rectifier le tir, on peut jouer sur le `space_before` de l’image, en le remontant (donc valeur négative) de la valeur de la hauteur de ligne (`line_height`). Pour ce faire, la constante LINE_HEIGHT a été initié. Donc on peut utiliser :
    {-}`\\!\\[mon_image.jpg](space_before: -LINE_HEIGHT)`
    EOT

  new_page_before(:texte)

  # texte(:as_sample)

  sample_recipe <<~YAML, "Définition des valeurs par défaut dans la recette"
    -\\--
    book_format:
      text:
        # Distance avec l’image flottant à gauche
        left_margin_with_floating_image: 10
        # Distance avec l’image flottant à droite
        right_margin_with_floating_image: 10
        # Distance par défaut avec le texte (enroulé) au-dessus
        top_margin_with_floating_image: 0
        # Distance par défaut avec le texte (enroulé) au-dessous
        bottom_margin_with_floating_image: 0
    YAML
end
