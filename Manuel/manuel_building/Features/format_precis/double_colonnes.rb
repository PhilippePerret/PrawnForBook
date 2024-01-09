Prawn4book::Manual::Feature.new do

  titre "Section en multi-colonnes"

  description <<~EOT
    On peut provisoirement passer en double colonnes grâce à la marque :
    (( line ))
    {-}`\\(\\( colonnes\\(2) ))`
    (( line ))
    Pour arrêter d’être en double colonnes, il suffit d’utiliser :
    (( line ))
    {-}`\\(( colonnes\\(1) ))`
    (( line ))
    Vous l’aurez déjà compris, grâce à cette marque, on peut avoir autant de colonnes que l’on désire.

    #### Définition plus précise des colonnes

    On peut définir la goutière (espace entre chaque colonne) grâce à la propriété `gutter` à mettre en deuxième paramètre :
    (( line ))
    {-}`\\(( colonnes\\(2, gutter: 40) ))`
    (( line ))
    On peut définir aussi sur quelle largeur les colonnes devront tenir, par exemple la moitié de la page :
    {-}`\\(( colonnes\\(2, width: PAGE_WIDTH/2) ))^^`
    (( line ))
    ^^ Vous remarquez ci-dessus l’utilisation d’une constante (cf. [[annexe/constantes]]).

    #### Précaution pour les colonnes

    Attention à toujours terminer par `\\(( colonnes\\(1) ))`, surtout si c’est la dernière page, dans le cas contraire les pages multi-colonnes ne seraient pas gravées.
    EOT

  # sample_texte <<~EOT #, "Autre entête"
  #   Le texte en exemple. Si 'texte' n'est pas défini, sera interprété aussi. Sinon sera mis en illustration et c'est 'texte' qui sera interprété comme texte du livre.    
  #   EOT

  texte <<~EOT
    Un premier paragraphe qui commence en simple colonne. Juste sous ce paragraphe, on a inscrit le code (invisible ici) : `\\(( colonnes\\(3) ))` qui permet de passer la suite en triple colonnes.
    (( colonnes(3) ))
    Début du texte. #{"In mollit anim veniam est ut officia sit mollit est dolor consequat cillum. " * 20} Fin du texte.
    (( colonnes(1) ))
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

    #### Ligne en trop dans les multi-colonnes

    Parfois il peut arriver que _PFB_ compte une ligne de trop dans les colonnes, ce qui produit cet alignement pas très heureux :
    (( line ))
    ```
    Premier#{' '*12}Deuxième en regard
    Deuxième#{' '*11}Troisième en regard
    Troisième
    Premier en regard
    ```
    (( line ))
    Pour palier cet écueil, on met la propriété `no_extra_line_height` à true dans la définition des colonnes. On obtient alors :
    (( line ))
    ```
    Premier#{' '*12}Premier en regard
    Deuxième#{' '*11}Deuxième en regard
    Troisième#{' '*10}Troisième en regard
    ```
    EOT

end
