Prawn4book::Manual::Feature.new do

  titre "Multi-colonnage"

  TAB_LIST = '     '

  description <<~EOT
    On peut provisoirement passer en double colonnes ou plus grâce à la marque :
    (( line ))
    {-}`\\(\\( colonnes\\(\\<nombre de colonnes>) ))`
    (( line ))
    … où `\\<nombre de colonnes>` est, comme on le devine, à remplacer par le nombre de colonnes que l’ont veut obtenir.
    C’est ce qu’on appelle le *mode multicolonnage*.
    Pour quitter le mode multi colonnes, il suffit de revenir à une seule colonne :
    (( line ))
    {-}`\\(( colonnes\\(1) ))`
    (( line ))
    Grâce à cette marque, on peut avoir autant de colonnes que l’on désire, comme ci-dessous.
    <!-- \\(( colonnes\\(3, {lines_count: 3}) )) -->
    gris::Un paragraphe au-dessus de la section multi-colonnes.
    (( colonnes(3) ))
    (( {align: :left} ))
    Ce texte se trouve en mode multi-colonnes, avec trois colonnes, grâce à la marque `\\(( colonnes\\(3) ))` qui se trouve au-dessus et la marque `\\(( colonnes\\(1) ))` qui se trouve en dessous. Il ne faut pas oublier la dernière marque.
    (( colonnes(1) ))
    gris::Un paragraphe au-dessous de la section multi-colonnes.

    #### Précaution pour les sections multi-colonnes

    Attention à toujours terminer par `\\(( colonnes\\(1) ))`, même lorsque c’est la dernière page. Dans le cas contraire, en cas d’oubli, la section multi-colonnes — et tout son texte — ne sera tout simplement pas gravée dans votre livre.

    #### Définition plus précise des colonnes

    Comme pour tout élément _PFB_, le comportement par défaut est harmonieux et devrait apporter satisfaction à tout utilisateur. Mais comme pour tout élément, on peut néanmoins redéfinir de façon précise de nombreux élément, simplement en ajoutant un deuxième paramètre à la méthode `colonnes` après le nombre de colonnes.
    Ce paramètre est une table ruby, donc entre accolades, avec des paires "`propriété: valeur`". Par exemple :
    (( line ))
    ~~~
    (( colonnes\\(\\<nombre cols>, {\\<prop>: \\<valeur>, \\
         \\<prop>: \\<valeur>, etc.}) ))
    ~~~

    #### Largeur de gouttière entre les colonnes

    On appelle *gouttière* l’espace vertical laissé entre deux colonnes. On peut le redéfinir avec la propriété `gutter` ("gouttière" en anglais).
    (( line ))
    (( {align: :center} ))
     `\\(( colonnes\\(2, {gutter: 40}) ))` 
    <!-- (( new_page )) -->
    (( line ))
    gris::Un paragraphe normal situé au-dessus de la section à double colonnes.
    (( colonnes(2, {gutter: "4cm", add_lines:1}) ))
    Une section en multi-colonnes (2) avec une gouttière de 4 centimètres. Une gouttière aussi large sépare très bien les deux colonnes. On peut utiliser cette fonctionnalité aussi pour placer une image entre les deux colonnes.
    (( colonnes(1) ))
    gris::Un paragraphe normal situé sous la section à double colonnes.
    (( line ))

    
    #### Largeur totale occupée par les colonnes

    On peut définir aussi sur quelle largeur les colonnes devront tenir, par exemple la moitié de la page :
    (( line ))
    (( {align: :center} ))
     `\\(( colonnes\\(2, width: PAGE_WIDTH/2) ))^^` 
    (( line ))
    ^^ Vous remarquez ci-dessus l’utilisation d’une constante (cf. [[annexe/constantes]]).
    (( line ))

    #### Lignes avant et après la section multicolonnes

    Grâce à `lines_before` et `lines_after`, on peut définir le nombre de lignes à laisser entre le texte et la section en multi-colonnes. Il s’agit très précisément du *nombre de lignes vides*. avant (`lines_before` — "lignes avant" en anglais) et après (`lines_after` — "lignes après" en anglais) la section multi-colonnes.
    Par exemple, avec :
    (( line ))
     `\\(( colonnes\\(2, {lines_before: 2, lines_after:3} ))`
    (( line ))
    … on laissera 2 lignes vides entre le paragraphe précédent et le début de la section à 2 colonnes, et 3 lignes vides entre la fin de la section multi-colonnes et le paragraphe suivant.

    #### Distance exacte avant et après la section multi-colonnes

    On peut utiliser de la même manière `space_before` et `space_after`, en leur donnant comme valeur une distance (en points-postscript, en millimètre, etc.) mais les propriétés `lines_before` et `lines_after` ci-dessus doivent être préférées pour conserver un aspect impeccable par rapport à la [[annexe/grille_reference]].

    #### Styles du texte dans les multi-colonnes

    On peut modifier les paragraphes de façon générale à l’intérieur d’une section multi-colonne grâce au deuxième paramètre.
    Les propriétés modifiables sont :
    (( line ))
    * **`align`** | Alignement des paragraphes. Justifiés (`:justify`) par défaut, on peut les aligner à gauche (`:left` ou `LEFT`) ou à droite (`:right` ou `RIGHT`). La section ci-dessous est obtenue avec le code\n#{TAB_LIST}`\\(( colonnes\\(2, {align: RIGHT}) \\))`
    (( line ))
    gris::Un paragraphe normal situé au-dessus de la section à double colonnes.
    (( colonnes(2, {align: RIGHT}) ))
    Ce texte est aligné à droite dans la section double colonne grâce à la propriété `align` mise à `RIGHT`. Rappel : par défaut, le texte est justifié.
    (( colonnes(1) ))
    gris::Un paragraphe normal situé sous la section à double colonnes.
    (( line ))
    * **`font`** | Fonte utilisée pour le texte. C’est une [[annexe/font_string]] classique. La section ci-dessous est engendrée par le code\n#{TAB_LIST}`\\(( colonnes\\(2, {font:\\"Arial/bold/8.5/008800\\"}) \\))`.
    (( line ))
    gris::Un paragraphe normal situé au-dessus de la section à double colonnes.
    (( colonnes(2, {font:"Arial/bold/8.5/008800"}) ))
    Une section en double colonnes avec la police "Arial", le style "bold", une taille de 8.5 et une couleur vert foncé (008800). Par défaut, c’est la police du livre qui est utilisée.
    (( colonnes(1) ))
    gris::Un paragraphe normal situé sous la section à double colonnes.
    (( line ))


    #### Très long texte en multi-colonnes

    Si vous avez un extrêmement long texte en multi-colonnes (par exemple tout votre livre), il est préférable de le diviser en plusieurs sections plutôt que de le faire tenir dans une seule section (ce qui entrainement fatalement des problèmes).
    Par exemple, renouvelez la marque `\\(( colonnes\\(2) ))` à chaque nouveau chapitre (sans oublier de terminer la section précédente par `\\(( colonnes\\(1) ))`.
    

    #### Ajouter ou retrancher des lignes en multi-colonnes

    Malgré tous nos efforts, ou pour des besoins propres, il est possible que les colonnes ne correspondent pas à ce que l’on attend au niveau de leur hauteur.
    Dans ce cas, grâce à la propriété `add_lines`, on peut ajouter ou retrancher un certain nombre de lignes. Par exemple, ci-dessous, on force l’affichage dans une seule colonne à l’aide de `\\(( colonnes\\(2, {add_lines: 3}) \\)`.
    (( line ))
    gris::Un paragraphe normal situé au-dessus de la section à double colonnes.
    (( colonnes(2,{add_lines:2}) ))
    Un texte qui devrait tenir sur les deux colonnes mais qu’on a allongé en hauteur pour avoir 3 lignes de plus. Donc ce texte tient intégralement sur la première colonne comme voulu par le nombre.
    (( colonnes(1) ))
    gris::Un paragraphe normal situé sous la section à double colonnes.
    (( line ))

    #### Nombre fixe de lignes en multi-colonnes

    De la même manière et malgré tous nos efforts, il est possible de fixer de façon précise le nombre de lignes.
    On peut utiliser soit la propriété `lines_count` pour définir le nombre de lignes (c’est la valeur) que doit avoir la section multi-colonnes, soit la propriété `height` pour définir la hauteur avec un unité de mesure (pouces, millimètre, etc.).
    (( line ))
    (( {align: :center} ))
     `(( colonnes\\(3, {lines_count: 10}) ))` 
     `# ..\\.` 
     `(( colonnes\\(3, {height: "4cm"}) ))` 
    (( line ))
    gris::Un paragraphe normal situé au-dessus de la section à double colonnes.
    (( colonnes(2, {lines_count:5, gutter:50}) ))
    Cette section multi-colonnes est obtenue en ajoutant la propriété `lines_count` à 5. On voit que cette colonne contient bien cinq lignes texte et qu’ensuite seulement on passe dans la colonne suivante pour écrire le reste du texte.
    (( colonnes(1) ))
    gris::Un paragraphe normal situé sous la section à double colonnes.
    (( line ))



    #### Styles des paragraphes dans les sections multi-colonnes

    On peut tout à fait utiliser la [[texte_detail/inline_styling]] pour styliser les paragraphes dans une section multi-colonnes.
    (( line ))
    gris::Un paragraphe normal situé au-dessus de la section à double colonnes.
    (( colonnes(2) ))
    Un premier paragraphe normal dans la section multi-colonnes.
    (( {align: RIGHT, color:"FF0000"} ))
    Ce paragraphe rouge avec de l’*italique* et du **gras** est aligné à droite.
    (( {align: CENTER} ))
    Paragraph centré.
    (( {font:"Helvetica/light/9/0000DD", align: LEFT} ))
    Paragraph aligné à gauche en Helvetica light de 9 en bleu.
    (( {indent:"2cm"} ))
    Un paragraphe indenté.
    (( colonnes(1) ))
    gris::Un paragraphe normal situé sous la section à double colonnes.
    (( line ))
    Pour le moment, seules les propriétés `lines_before`, `lines_after`, `margin_left` et `margin_right` ne sont pas prises en compte. Pour les premières, il suffit d’ajouter des lignes vides avec le caractère "espace insécable" ([ALT] [ESPACE]).

    EOT


end
