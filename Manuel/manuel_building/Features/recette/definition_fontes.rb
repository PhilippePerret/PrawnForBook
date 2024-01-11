Prawn4book::Manual::Feature.new do

  titre "Définition des fontes (embarquées)"

  description <<~EOT
    Bien que l’application propose, clé en main, des fontes à utiliser pour imprimer son livre, on peut définir n’importe quelle fonte dont on possèderait la licence commerciale pour être utilisée pour tout élément du livre (texte, titres, etc.). Mais afin que l’imprimeur puisse s’en servir, il faut *embarquer* ces fontes dans le document PDF à destination de cet imprimeur.

    #### Conseil concernant l’emplacement des fontes

    Pour éviter tout problème — notamment quand on déplace le dossier du livre ou qu’on le transmet à quelqu’un —, il est plus prudent de faire un dossier `fontes` dans votre dossier de collection ou de livre et d’y dupliquer les polices que vous voulez utiliser — c’est-à-dire les fichiers `.ttf` et `.otf`.
    Si vous avez à transmettre le dossier à un collaborateur ou autre, celui-ci ou celle-ci pourra imprimer correctement le livre, avec les fontes désirées, même s’il ne les possède pas sur son ordinateur.

    #### Styles obligatoires pour les fontes

    Pour pouvoir utiliser la mise en forme de base du texte, c’est-à-dire les italiques, les gras, les soulignés, vous devez impérativement définir ces styles de police.^^
    Il faut comprendre qu’en impression professionnelle, il n’y a pas de *magie* au niveau des polices, si vous utilisez de l’italique par exemple, _PFB_ utilise la forme *italic* de votre police, si vous utiliser de l’italique et du gras, _PFB_ utilise la forme *italic_bold* de votre police. Ces *formes* doivent toutes être définies.

    #### Définition des fontes dans la section *:fonts*

    Vous définissez les fontes (polices) dans une section `fonts` ("fontes" en anglais) de votre recette. C’est une table YAML dont les clés seront les noms de vos polices, ceux que vous utiliserez pour définir les [[annexe/font_string]] de chaque élément de votre texte, à commencer par la fonte par défaut.
    Imaginons que vous ayez mis le fichier `New-Time-regular.ttf` de la police "New-Times" dans un dossier `fontes` de votre dossier de collection (ou de livre). Pour y faire référence dans les fontes-strings que vous voulez utiliser, vous voulez l’appeler simplement `NTime` (pour avoir un font-string qui ressemble à `NTime/regular/12/333333`), alors, dans la recette, il vous suffit de mettre :
    (( line ))
    ~~~yaml
    # Dans recipe_collection.yaml
    ---
    fonts:
      NTime:
        regular: "fontes/New-Time-regular.ttf"
    ~~~
    (( line ))
    Comme vous allez utiliser aussi de l’italique, du gras, et de l’italique avec du gras, et que vous possédez (dans le dossier polices de votre ordinateur ou le dossier de la police dont vous venez d’acheter la licence) les fichiers relatifs qui sont `New-Time-Italic.ttf`, `New-Time-Bold.ttf` et `New-Time-ItalicBold.ttf`, alors vous pouvez compléter la recette avec :
    (( line ))
    ~~~yaml
    ---
    fonts:
      NTime:
        regular: "fontes/New-Time-regular.ttf"
        italic: "fontes/New-Time-Italic.ttf"
        bold: "fontes/New-Time-Bold.ttf"
        italic_bold: "fontes/New-Time-ItalicBold.ttf"
    ~~~
    (( line ))

    #### Fonte par défaut

    Noter que la fonte ci-dessus étant la toute première fonte définie dans la table `fonts`, c’est elle qui sera considérée comme la fonte par défaut et sera utilisée lorsque des polices ne seront pas définies pour des éléments du livre.
    EOT

end
