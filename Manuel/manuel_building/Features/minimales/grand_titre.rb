Prawn4book::Manual::Feature.new do
  grand_titre "Définitions minimales"

  description <<~EOT
    Cette section se concentre sur les définitions minimales que vous aurez à faire si les définitions par défaut ne conviennent pas au livre que vous êtes en train d’écrire. Typiquement, il est fort possible que la taille du livre ainsi que les marges ne soient pas définis par défaut comme votre livre le demande.
    C’est ici que vous apprendrez à régler ces valeurs.
    Cette partie suppose que vous avez déjà parcouru cette aide et que vous connaissez, notamment, l’usage des recettes utilisées par _PFB_ (voir [["recette du livre", page __page__|recette/recette_livre]] et [["recette de la collection", page __page__|recette/recette_collection]]). Dans le cas contraire, reportez-vous à ces sections avant de lire celle-ci (qui se trouve avant juste pour pouvoir l’atteindre plus rapidement lorsque l’on connait déjà l’application et que l’on a juste besoin de se rafraichir la mémoire.

    #### Définition des titre et auteur

    La première définition concernant le livre sera certainement son titre et son auteur\\(e) que nous ne pouvons pas définir par défaut. Pour ce faire, nous définissions les propriétés **`title`** ("titre" en anglais) et **`author`** ("auteur" en anglais) dans la section **`book_data`** ("données du livre" en anglais) de la recette du livre `recipe.yaml`.
    (( line ))
    ~~~yaml
    #./recipe.yaml
    book_data:
      title: "Le titre du livre"
      author: "Prénom NOM, Autre AUTEUR"
    ~~~
    (( line ))
    Notez que les noms se mettent avec capitales, pour que _PFB_ puisse les reconnaitre. On les sépare également par des virgules (signe qui, normalement, ne se trouve dans aucun patronyme).

    #### Taille du livre

    La taille du livre doit être définie dans la recette du livre si elle est unique même dans une collection ou dans la recette de la collection si elle est commune à tous les livres de cette collection (ce qui est généralement le cas).
    On doit simplement définir les propriétés **`width`** ("largeur" en anglais) et **`height`** ("hauteur" en anglais) dans la section **`book_format`** ("format du livre" en anglais) :
    (( line ))
    ~~~yaml
    #./recipe.yaml ou ../recipe_collection.yaml
    book_format:
      width: "<quantité><unité>"   # p.e. "210mm"
      height: "<quantité><unité>"  # p.e. "29.7cm"
    ~~~

    #### Marges du livre

    Les marges du livre relèvent aussi du format du livre (`book_format`) et plus précisément du format des pages. On les indique dans la partie **`margins`** ("marges" en anglais) de cette partie.
    (( line ))
    ~~~yaml
    #./recipe.yaml ou ../recipe_collection.yaml
    book_format:
      page:
        margins:
          top: "<quant><unité>"       # marge en haut
          bottom: "<quant><unité>"    # marge en bas
          ext: "<quant><unité>"       # marge extérieure
          int: "<quant><unité>"       # marge intérieure
    ~~~
    (( line ))
    À titre de rappel, dans un livre, on ne définit pas les marges gauche et droite, entendu qu’elles sont différentes suivant qu’on se trouve sur une page gauche ou une page droite. On définit à la place les marges intérieures (`int`) et les marges extérieures (`ext`).
    Vous pouvez trouver tout ce qui concerne les marges dans la section [[format_precis/definition_marges]].

    #### Polices embarquées dans le livre

    Il y a fort à penser que la police par défaut de _PFB_, pour les textes et les titres, ne vous conviennent pas tout à fait. Il convient de la définir.
    Cette définition se fait en deux étapes : d’abord, il faut **informer** _PFB_ **des polices que vous voulez utiliser**, si elles ne font pas partie des polices par défaut, et ensuite indiquer **quelle police sera utilisée** pour tel ou tel élément du texte (texte général, titre de niveau 1, de niveau 2, etc.).
    Pour la définition des polices, nous vous renvoyons à la section [[recette/definition_fontes]] qui est parfaitement détaillée.
    Brièvement, voilà ce qu’il faut définir quand on veut changer un minimum de choses :
    (( line ))
    ~~~yaml
    #./recipe.yaml ou ../recipe_collection.yaml
    fonts:
      # Définition d’une fonte à embarquer
      <nom utilisé pour la fonte>:
        <style un>: "path/to/fichier/ttf"
        <style deux>: "path/to/autrefichier/ttf"
        etc.
    ~~~
    (( line ))
    Par exemple :
    (( line ))
    ~~~yaml
    #./recipe.yaml ou ../recipe_collection.yaml
    fonts:
      TexteDefaut:
        normal: "fontes/MaFonte/regular.ttf"
        italic: "fontes/MaFonte/italic.ttf"
        bold: "fontes/MaFonte/gras.ttf"
        bold_italic: "fontes/MaFonte/gras-italic.ttf"
    ~~~
    (( line ))
    Noter, ci-dessus, les chemins relatifs. Cela signifie que les fontes seront recherchées dans un dossier `fontes` dans le dossier du livre (ou le dossier de la collection si c’est une collection).
    Le nom défini (ci-dessus "TexteDefaut") sera le nom repris soit dans la définition des éléments (cf. ci-dessous) soit dans le texte, lorsqu’on voudra appliquer une fonte à du texte.

    #### Police appliquée au texte normal

    Le premier élément à définir, au niveau de la police à utiliser est bien évidemment le texte par défaut. Ça relève du texte (`text`) dans le format du livre (`book_format`). On définit simplement :
    (( line ))
    ~~~yaml
    book_format:
      text:
        font: "TexteDefaut/normal/11/222222"
    ~~~
    (( line ))
    C’est une définition qu’on appelle "fonte string" (prononcer "strine’gue"). Voir [[annexe/font_string]]. Noter qu’on utilise la police embarquée plus haut.

    #### Fontes appliquées aux titres

    On peut définir de la même manière les polices/styles/taille/couleur des niveaux de titre dont on a besoin. On le fait toujours dans `book_format`, puisque ça relève du format du livre, dans la section `titles` ("titres" en anglais).
    (( line ))
    ~~~yaml
    book_format:
      titles:
        # Fonte générale qui servira pour tous les titres
        font: "Numito/regular//555555"
        title1:
          font: "/regular/20"
        title2:
          font: "//16"
        title3:
          font: "/italic/14"
        etc.
    ~~~
    (( line ))
    Noter que les "fontes-string" n’ont jamais besoin de définir les quatre données fonte, style, taille et couleur. Une donnée non définie prendra toujours la valeur par défaut. Pour les titres, ci-dessus, par exemple, la police sera toujours *Numito*, police définie de façon générale pour les titres. De même que la couleur sera toujours `555555`, donc un noir un peu clair.


    #### Hauteur de ligne

    La *hauteur de ligne* (`line_height` en anglais) est une valeur très importante puisqu’elle va déterminer le positionnement de toutes les lignes de texte, entendu que, comme cela est expliqué dans la section [[comportement/align_on_reference_lines]].
    Elle relève du format du livre donc se trouve dans `book_format`, et relève précisément du texte (`text`). On la définit donc ainsi :
    (( line ))
    ~~~yaml
    book_format:
      text:
        line_height: <valeur en point-postscript>
    ~~~
    Cette valeur dépendra bien entendu de la taille de fonte utilisée par défaut dans le livre (cf. plus haut).
    EOT
end
