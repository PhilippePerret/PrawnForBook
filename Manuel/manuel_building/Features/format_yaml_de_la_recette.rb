Prawn4book::Manual::Feature.new do

  titre "Le format YAML de la recette"

  description <<~EOT
    Comme nous l'avons dit, pour définir très précisément le livre "à la virgule près" nous utilisons une *recette* contenu dans un fichier **`recipe.yaml`** ("recipe" signifie "recette" en anglais) ou dans un fichier **`collection_recipe.yaml`** si le livre appartient à une collection qui partage la même charte graphique.

    Vous pourrez trouver des informations sur le format `YAML` en tapant ce mot dans un moteur de recherche. C'est de toute façon un format très simple, *imbriqué*, qui sépare une donnée (par exemple la hauteur de ligne) de sa valeur par deux points : `line_height: 15`.

    Ci-dessus, la hauteur de la ligne ("line height" en anglais) sera de 15 points.

    Les données sont *imbriquées*, comme nous l'avons dit, pour s'y retrouver plus facilement, entendu que la recette peut contenir des dizaines et des dizaines de choses (nous vous avons prévenu : on peut utiliser ***Prawn-For-Book*** de façon très simple, en utilisant ses données par défaut, mais on peut l'utiliser aussi de façon très précise pour régler n'importe quel aspect du livre)

    Par exemple, tout ce qui relève des informations sur le livre est *rangé* dans un ensemble appelé `book_data` ("données sur le livre" en anglais). Tout ce qui relève du format du livre (pages, texte) est *rangé* dans un ensemble appelé `book_format` ("format du livre" en anglais), comme on peut le voir dans l'exemple de recette donnée ci-dessous :
    EOT

  sample_recipe <<~EOT
    ---
    book_data:
      title: "Le Titre du livre"
      author: "Auteur DU LIVRE"

    book_format:
      book:
        width: 127mm
        height: 203.2mm
        orientation: portrait
      page:
        numerotation: hybrid
        skip_page_creation: true

    fonts:
      Garamond:
        normal: "mesFontes/Garamond.ttf"
        italic: "mesFontes/Garamond-italic.ttf"
        bold: "mesFontes/Garamond-bold.ttf"
        bold_italic: "mesFontes/Garamond-bolditalic.ttf"

    EOT

end
