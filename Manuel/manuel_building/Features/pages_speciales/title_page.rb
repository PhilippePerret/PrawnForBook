Prawn4book::Manual::Feature.new do

  titre "Page de titre"


  description <<~EOT
    La *page de titre* présente un grand nombre d’informations au lecteur et notamment le titre, l’auteur et l’éditeur du livre.
    Ses données sont définies dans la section `inserted_pages` de la recette du livre ou de la collection (cf. [[recette/grand_titre]]) grâce à la propriété `page_de_titre` (ou `title_page`).
    Dans sa version la plus simple, utilisant les valeurs par défaut, on aura juste à indiquer :
      `inserted_pages:`
      `  page_de_titre: true`
    … pour que la page de titre soit affichée en début de livre.
    (mettre `false` — "faux" — au lieu de `true` — "vrai" — pour que la page de titre ne soit pas affichée)
    (( line ))
    Mais comme tout autre élément de _PFB_, on peut définir la page de titre de façon plus précise. Trouvez ci-dessous les propriétés définissables et retrouvez-les dans l’exemple de recette plus bas.
    Vous pourrez aussi trouver, tout en bas de cette section, la recette utilisée pour produire la page de titre un peu trop bariolée (pour cette illustration) de ce manuel, dans les premières pages.

    ##### Propriétés de la page de titre

    Ci-dessous, les sous-propriétés `font` sont des "font-string" (cf. [[annexe/font_string]]) et les propriétés `line` sont les lignes de référence sur lesquelles doivent être imprimés les éléments. Pour les voir sur les pages, vous pouvez demander la construction du livre avec l’option `-grid` qui les fera apparaitre sur les pages.
    (( line ))
    Noter qu’une propriété ne sera imprimée que si elle est définie dans cette section `inserted_pages: page_de_titre:`.
    (( line ))
    * **`title`** | Définition de l’aspect du *titre du livre* sur la page de titre. Définit les propriétés `font` et `line` (ligne sur laquelle imprimer le titre).
    * **`subtitle`** | Définition de l’aspect du *sous-titre du livre* s’il en possède un. Définit les propriétés `font` et `line`.
    * **`author`** | Définit l’aspect de l’affichage de l’*auteur* (ou des auteurs) par les propriétés `font` et `line` (ligne sur laquelle imprimer l’auteur)
    * **`collection`** | Définit l’aspect du titre de la collection à l’aide des propriété `font` et `line`.
    * **`publishier`** | Définit l’aspect de la maison d’édition ou de l’éditeur ("publisher" = éditeur). En plus des propriétés `font` et `line`, on trouve la propriété `logo` qui doit définir la taille en hauteur (`height`) et la ligne (`line`) du logo^^.

    ^^ Ce logo doit être défini dans la section `publisher` de la recette (cf. [[recette/publisher]]).

    EOT

  sample_recipe <<~YAML, "Propriétés du fichier recette"
    ---
    inserted_pages:
      page_de_titre:
        title:
          font: "fonte/style/taille/couleur"
          line: 4
        subtitle:
          # idem
        author:
          # idem
        collection:
          # idem
        publisher:
          # idem
          logo:
            height: <hauteur>
            line:  <ligne>
        copyright: "<mention du copyright>"

    YAML

  sample_real_recipe(:inserted_pages)

end
