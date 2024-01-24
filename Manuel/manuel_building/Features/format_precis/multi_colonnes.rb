Prawn4book::Manual::Feature.new do

  titre "Section en multi-colonnes"

  TAB_LIST = '     '

  description <<~EOT
    On peut provisoirement passer en double colonnes ou plus grâce à la marque :
    (( line ))
    {-}`\\(\\( colonnes\\(<nombre de colonnes>) ))`
    (( line ))
    C’est ce qu’on appelle le *mode multi-colonnes*.
    Pour quitter le mode multi colonnes, il suffit de revenir à une seule colonne :
    (( line ))
    {-}`\\(( colonnes\\(1) ))`
    (( line ))
    Vous l’aurez déjà compris, grâce à cette marque, on peut avoir autant de colonnes que l’on désire, comme ci-dessous.
    <!-- \\(( colonnes\\(3, {lines_count: 3}) )) -->
    Un paragraphe au-dessus de la section multi-colonnes.
    (( colonnes(3) ))
    (( {align: :left} ))
    Ce texte se trouve en mode multi-colonnes, avec trois colonnes, grâce à la marque `\\(( colonnes\\(3) ))` qui se trouve au-dessus et la marque `\\(( colonnes\\(1) ))` qui se trouve en dessous. On peut forcer le nombre de lignes.
    (( colonnes(1) ))
    Un paragraphe au-dessous de la section multi-colonnes.

    #### Définition plus précise des colonnes

    Comme pour tout élément _PFB_, le comportement par défaut est harmonieux et devrait apporter satisfaction à tout utilisateur. Mais comme pour tout élément, on peut néanmoins redéfinir de façon précise de nombreux élément, simplement en ajoutant un deuxième paramètre à la méthode `colonnes` après le nombre de colonnes.
    Ce paramètre est une table ruby, donc entre accolades, avec des paires "`propriété: valeur`". Par exemple :
    (( line ))
    ~~~
    (( colonnes\\(<nombre cols>, {\\<prop>: \\<valeur>, \\
         \\<prop>: \\<valeur>, etc.}) ))
    ~~~

    #### Largeur de gouttière entre les colonnes

    On appelle *gouttière* l’espace vertical laissé entre deux colonnes. On peut le redéfinir avec la propriété `gutter` ("gouttière" en anglais).
    (( line ))
    (( {align: :center} ))
     `\\(( colonnes\\(2, gutter: 40) ))` 
    
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

    #### Styles du texte dans les multi-colonnes

    On peut modifier les paragraphes de façon générale à l’intérieur d’une section multi-colonne grâce au deuxième paramètre.
    Les propriétés modifiables sont :
    (( line ))
    * **`align`** | Alignement des paragraphes. Justifiés (`:justify`) par défaut, on peut les aligner à gauche (`:left` ou `LEFT`) ou à droite (`:right` ou `RIGHT`). La section ci-dessous est obtenue avec le code\n#{TAB_LIST}`\\(( colonnes\\(2, {align: RIGHT}) \\))`
    (( line ))
    (( colonnes(2, {align: RIGHT}) ))
    Ce texte est aligné à droite dans la section double colonne grâce à la propriété `align` mise à `RIGHT`. Rappel : par défaut, le texte est justifié.
    (( colonnes(1) ))
    Un paragraphe normal situé sous la sectoin à double colonnes.
    (( line ))
    * **`font`** | Fonte utilisée pour le texte. C’est une [[annexe/font_string]] classique. La section ci-dessous est engendrée par le code\n#{TAB_LIST}`\\(( colonnes\\(2, {font:\\"Arial/bold/8.5/008800\\"}) \\))`.
    (( line ))
    (( colonnes(2, {font:"Arial/bold/8.5/008800"}) ))
    Une section en double colonnes avec la police "Arial", le style "bold", une taille de 8.5 et une couleur vert foncé (008800). Par défaut, c’est la police du livre qui est utilisée.
    (( colonnes(1) ))
    Un paragraphe normal situé sous la sectoin à double colonnes.
    (( line ))


    #### Très long texte en multi-colonnes

    Si vous avez un extrêmement long texte en multi-colonnes (par exemple tout votre livre), il est préférable de le diviser en plusieurs sections plutôt que de le faire tenir dans une seule section (ce qui entrainement fatalement des problèmes).
    Par exemple, renouvelez la marque `\\(( colonnes\\(2) ))` à chaque nouveau chapitre (sans oublier de terminer la section précédente par `\\(( colonnes\\(1) ))`.
    
    #### Espace avant et après la section multi-colonnes

    On peut utiliser de la même manière `space_before` et `space_after`, en leur donnant comme valeur une distance (en points-postscript, en millimètre, etc.).
    Mais les propriétés `lines_before` et `lines_after` doivent être préférées, sauf dans le cas où vous connaissez les distances précisément, en pouce, millimètre ou autre, à avoir entre le texte et la section multi-colonnes.

    #### Nombre fixe de lignes en multi-colonnes

    Malgré tous nos efforts, ou pour des besoins propres, il est possible que les colonnes ne correspondent pas à ce que l’on attend au niveau de leur hauteur.
    On peut utiliser soit la propriété `lines_count` pour définir le nombre de lignes (c’est la valeur) que doit avoir la section multi-colonnes, soit la propriété `height` pour définir la hauteur avec un unité de mesure (pouces, millimètre, etc.).
    (( line ))
    (( {align: :center} ))
     `(( colonnes\\(3, {lines_count: 10}) ))` 
     `# ..\\.` 
     `(( colonnes\\(3, {height: "4cm"}) ))` 

    #### Précaution pour les sections multi-colonnes

    Attention à toujours terminer par `\\(( colonnes\\(1) ))`, même lorsque c’est la dernière page. Dans le cas contraire, en cas d’oubli, la section multi-colonnes — et tout son texte — ne sera tout simplement pas gravée.
    EOT


  texte <<~EOT
    (( new_page ))
    Un premier paragraphe en haut de page qui commence en mode normal (sans colonne). Juste sous ce paragraphe, on a inscrit le code (invisible ici) : `\\(( colonnes\\(3) ))` qui permet de passer la suite en triple colonnes.
    (( colonnes(3, {lines_count: 5}) ))
    Début du texte. #{"In mollit anim veniam est ut officia sit mollit est dolor consequat cillum. " * 4} (il faudra remettre 20 fois) Fin du texte.
    (( colonnes(1) ))
    EOT

  extra_texte = <<~EOT
    (( new_page ))
    On revient ensuite à un texte sur une colonne avec la marque `\\(( colonnes\\(1) ))`. Et c’est la fin de l’usage des colonnes multiples, on revient sur une page normale.
    La double colonne suivante est obtenue quant à elle grâce au code : `\\(( colonnes\\(2, width:PAGE_WIDTH/1.5, gutter:50) ))` qui est placé juste sous cette ligne.
    (( colonnes(2, width:PAGE_WIDTH/1.5, gutter:50) ))
    Début du texte. #{"In mollit anim veniam est ut officia sit mollit est dolor consequat cillum. " * 10}. Fin du texte.
    (( colonnes(1) ))
    On revient à nouveau à un texte sur une colonne avec la marque `\\(( colonnes\\(1) ))`.
    Par défaut, _PFB_ laisse une ligne vide au-dessus et une ligne vide au-dessous d’un texte en multi-colonnes. On peut contrecarrer ce comportement à l’aide des propriétés `lines_before` et `lines_after`. À `false` ou 0, aucune ligne ne sera ajoutée.
    On peut même mettre `line_after` à `-1` lorsqu’il arrive, parfois, qu’une ligne supplémentaire soit ajoutée par erreur (les calculs de Prawn sont parfois impénétrables). Avant les doubles colonnes suivantes, nous avons écrit le code : `\\(( columns\\(2, lines_before:0, space_after: -LINE_HEIGHT) \\))` (nous avons volontairement utilisé la traduction anglaise "columns").
    (( columns(2, gutter:50, lines_before:0, space_after: -LINE_HEIGHT) ))
    Début du texte en double colonnes. Un texte en double colonnes qui ne devrait pas présenter de ligne vide de séparation ni au-dessus avec le texte avant ni au-dessous avec le texte après. Tous ces textes devraient être collés. Fin du texte en double colonnes.
    (( columns(1) ))
    Paragraphe sous le texte en double colonnes collées. Ci-dessus, nous avons dû jouer sur `space_after`, avec une valeur négative, pour arriver à nos fins car `lines_after` restait inefficace. Au-dessus, on peut aussi jouer avec `space_before` si on veut définir l’espace avant. Notez que le texte est quand même remis sur des lignes de référence à chaque fois.

    EOT

end
