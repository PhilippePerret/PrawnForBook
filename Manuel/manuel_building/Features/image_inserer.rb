Prawn4book::Manual::Feature.new do

  titre "Insérer une image"


  new_page_before(:feature)
  new_page_before(:texte)

  description <<~EOT
    Pour insérer une image dans le flux du livre, on utilise le code pseudo-markdown **`\\!\\[chemin/vers/image]`**. Si des données sont à passer, on utiliser **`\\!\\[vers/image](\\<data>)`** où `\\<data>` est une [[table_ruby]].
    Noter que ce code doit obligatoirement se trouver sur une ligne seule.

    ##### Chemin d’accès à l’image

    Le chemin d’accès à l’image peut se donner…
    * relativement au dossier du livre,
    * relativement au dossier 'images' du livre (s’il existe),
    * relativement au dossier de la collection s’il y a collection,
    * relativement au dossier 'images' de la collection s’il y a collection.
    Les formats (jpg, tiff, png, svg)

    ##### Positionnement de l’image

    Par défaut, l’image est placée au centre. Pour la mettre à droite ou à gauche, utiliser respectivement `align: right`, `align: :left` comme dans les exemples ci-dessous.

    Pour un placement optimum, on peut ajuster la position de l’image verticalement à l’aide de `vadjust` ("ajustement vertical"). L’ajustement horizontal, bien entendu, peut se faire avec `right` et `left`. Bien sûr, il est raisonnable de ne faire ces aajustements qu’à la dernière minute, lorsque le livre est presque finalisé.

    ##### Taille de l’image

    La taille de l’image peut être définie avec `width:` (largeur), `height:` (hauteur) et/ou `scale:` (échelle). Notez que la largeur sera toujours ramenée à la largeur du livre si elle est supérieure, et la hauteur sera toujours ramenée à sa hauteur.

    ##### Légende de l’image

    Une légende peut être définie en donnant la donnée `legend: \\"La légende de l’image\\"`. Par défaut, cette légende sera inscrite avec la même police que la police courante, avec une taille de une unité inférieure et en italique.

    {{TODO: Modification, par la recette, de a) la taille, b) le style, c) la police, d) la largeur de la légende}}

    ##### Image SVG

    Les images SVG sont incontestablement les meilleures images pour l’impression dans le sens où elles conservent leurs qualités quelle que soit la taille adoptée. On peut le voir sur les exemples ci-dessous. Elles sont donc à privilégier.

    ##### Rogner une image SVG

    Rogner une image svg [[image_rogner_svg]].

    {{TODO: les data}}

    ##### Exemples

    Les exemples ci-dessous sont tous construits à partir du code exact donné en exemple. Vous pouvez donc lui faire pleinement confiance.
    EOT

  ex1 = "\\!\\[images/exemples/plus_large.jpg]"
  
  ex2 = "\\!\\[exemples/plus_large.jpg](legend:\\\"Image plus grande réduite en largeur\\\")"

  ex3 = "\\!\\[exemples/plus_haute.png]"

  ex4 = "\\!\\[exemples/plus_haute.png](legend:\\\"Image plus haute réduite et\\<br>placée sur la page suivante\\\")"

  ex5 = "\\!\\[exemples/plus_haute.png](height:\\\"30%\\\", legend:\\\"Trop haute avec height à 30%\\\")"

  ex6 = "\\!\\[exemples/plus_haute.png](height:\\\"30%\\\", width:\\\"100%\\\", legend:\\\"Trop haute avec height à 30% et width à 100%\\\")"

  ex7 = "\\!\\[exemples/moins_large.jpg](legend:\\\"Image centrée\\\")"

  ex8 = "\\!\\[exemples/moins_large.jpg](left: \\\"2cm\\\")"

  ex9 = "\\!\\[exemples/moins_large.jpg](left: \\\"2cm\\\", vadjust: 15, legend:\\\"Image à gauche décalée\\<br>vers\\<br>la droite\\\")"

  ex10 = "\\!\\[exemples/moins_large.jpg](align: :right, legend:\\\"Alignée à droite\\\")"

  ex11 = "\\!\\[exemples/moins_large.jpg](right: 2.cm, legend:\\\"À 2 cm de la droite\\\")"

  ex12 = "\\!\\[exemples/moins_large_et_bas.jpg](width:\\\"100%\\\", legend:\\\"Image agrandie à 100 % avec une grande légende qui doit tenir sur plusieurs lignes car une légende, par défaut, couvre la moitié de la page, mais on peut changer ce comportement.\\\")"

  ex13 = "\\!\\[exemples/moins_large.jpg](scale: 2.5, legend:\\\"Image avec scale de 2.5\\\")"

  ex14 = "\\!\\[exemples/image.svg]"

  ex15 = "\\!\\[exemples/image.svg](width: \\\"100%\\\", height: 600)"

  ex16_height = 1000
  ex16 = "\\!\\[exemples/image.svg](width: 200, height: #{ex16_height})"

  ex17 = "\\!\\[exemples/image.svg](width:\\\"90%\\\", legend:\\\"Image SVG avec légende\\\")"

  texte <<~EOT, "Aspect des images en fonction du code"
    **EXEMPLE 1 •** Une image trop large sera réduite à la taille du livre<br>Code : `#{ex1}`
    #{deslash ex1}

    (( line ))

    (( {align: :left} ))
    **EXEMPLE 2 •** La même image, mais avec une légende, insérée (notez qu’ici on n’a pas indiqué `images` dans le chemin d’accès, puisque ce dossier est implicite).<br>Code : `#{ex2}`
    #{deslash ex2}

    (( new_page ))

    **EXEMPLE 3 •** Une image PNG trop haute, *sans légende*, qui sera réduite à la taille d’une page du livre et mise sur la page suivante<br>Code : `#{ex3}`
    #{deslash ex3}


    **EXEMPLE 4 •** Une image PNG trop haute, *avec légende*, qui sera réduite à la taille d’une page du livre et mise sur la page suivante<br>Code : `#{ex4}`
    #{deslash ex4}
    
    (( new_page ))
    
    (( {align: :left} ))
    **EXEMPLE 5 •** Une image PNG trop haute, dont on réduit explicitement la hauteur.<br>Code : `#{ex5}`
    #{deslash ex5}

    (( {align: :left} ))
    **EXEMPLE 6 •** Une image PNG trop haute, dont on réduit explicitement la hauteur mais qui doit faire la largeur de la page.<br>Code : `#{ex6}`
    #{deslash ex6}

    **EXEMPLE 7 •** Une image plus petite que la largeur sera laissée telle quelle<br>Code : `#{ex7}`
    #{deslash ex7}

    (( line ))
    
    **EXEMPLE 8 •** Image plus petite en largeur, alignée à gauche et décalée vers la droite, sans légende.<br>Code : `#{ex8}`
    #{deslash ex8}

    (( line ))
    
    (( {align: :left} ))
    **EXEMPLE 9 •** Image plus petite en largeur, alignée à gauche et décalée vers la droite. Noter comment la légende a été découpée pour passer à la ligne. Noter également l’ajustement vertical qui a été utilisé pour bien placer l’image (qui aurait été trop collée au code ci-dessous)<br>Code : `#{ex9}`
    #{deslash ex9}

    (( line ))

    (( {align: :left} ))
    **EXEMPLE 10 •** Image plus petite en largeur alignée à droite<br>Code : `#{ex10}`
    #{deslash ex10}

    (( line ))

    **EXEMPLE 11 •** Image plus petite en largeur alignée à droite et décalée vers la gauche.<br>Code : `#{ex11}`
    #{deslash ex11}

    (( line ))

    (( {align: :left} ))
    **EXEMPLE 12 •** Image plus petite que la largeur, agrandie avec "`width: \\"100%\\"`" pour tenir dans la largeur (déconseillé car cela "abîme" l’image)<br>Code : `#{ex12}`
    #{deslash ex12}

    (( line ))

    (( {align: :left} ))
    **EXEMPLE 13 •** Image plus grande grâce à "`scale: 2.5`"<br>Code : `#{ex13}`
    #{deslash ex13}

    **EXEMPLE 14 •** Image SVG affichée sans aucune indication<br>Code : `#{ex14}`
    #{deslash ex14}

    **EXEMPLE 15 •** Image SVG grossie. Code : `#{ex15}`
    #{deslash ex15}

    **EXEMPLE 16 •** On ne peut pas (à ma connaissance) modifier disproportionnellement une image SVG dans Prawn même avec des valeurs explicites. Ci-dessous, la hauteur, bien que mise à #{ex16_height}, reste proportionnée à la largeur.<br>Code : `#{ex16}`
    #{deslash ex16}

    (( {align: :left} ))
    **EXEMPLE 17 •** Image SVG avec légende. Code : `#{ex17}`
    #{deslash ex17}

    Fin des exemples d’images.
    EOT


end
