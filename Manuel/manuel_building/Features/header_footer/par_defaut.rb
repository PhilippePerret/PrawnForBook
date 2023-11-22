Prawn4book::Manual::Feature.new do

  titre "Description"


  description <<~EOT
    Comme pour les autres éléments, on pourra laisser les **entêtes** et **pieds de page** par défaut, ce qui signifiera n’afficher que les numéro de pages — sur les pages adéquates —, ou au contraire on pourra définir des entêtes et pieds de page complexes et adaptés au contenu pour une navigation optimum.
    (( line ))
    Comme pour les autres éléments de _PFB_, les entêtes et pieds de page par défaut sont conçus pour être directement "professionnels". C’est-à-dire que la numérotation est intelligente, elle ne numérote pas bêtement toutes les pages de la première à la dernière. Seules sont numérotées les pages qui le sont dans un livre imprimé. Sont soigneusement évitées les pages vides, les pages de titre ou les pages spéciales comme [[-pages_speciales/table_des_matieres]] ou [[-pages_speciales/page_infos]].
    (( line ))
    Les pages suivantes vont définir les différents entête et pieds de page que l’on peut définir, en présentant dans la page le code utilisé et le résultat dans les entêtes et/ou les pieds de page.

    ##### Lexique

    Comme pour les autres parties, nous définissons ici le lexique des termes qui seront rigoureusement utilisés dans cette partie.

    * **Entête**. C’est la partie, en haut de page, au-dessus du texte principal de la page, qui contient le plus souvent le titre courant, qui permet de naviguer plus facilement dans les chapitres du livre.
    * **Header**. *Entête*, en anglais.
    * **Pied de page**. C’est la partie, en bas de page, sous le texte principal de la page, qui contient le plus souvent le *numéro de page*.
    * **Footer**. *Pied de page*, anglais.
    * **Portion**. Nous appelons "portion" l’un des 6 tiers de page qui constituent une *entête* ou un *pied de page*. Il y en a 6 parce qu’on travaille ici en double page. On trouve la *portion gauche*, la *portion droite* et la *portion centrale* de la page gauche et les mêmes portions sur la page droite.
    * **Disposition**. Une *disposition* décrit le contenu des pieds et page et entête d’une ou plusieurs pages. Cela revient à définir les 6 portions de l’entête et les 6 portions du pied de page. 
    
    ##### Trois portions de page

    Un *entête* ou un *pied de page* est un espace de page qui contient jusqu’à trois portions, trois "tiers" de page, une portion gauche, une portion droite et une portion centrale. On répartie les éléments dans ces trois portions. Les trois portions peuvent être différentes entre page gauche et page droite.
    Puisqu’on travaille les entêtes et pieds de page en double page, on peut donc définir jusqu’à 6 portions qu’on peut représenter la manière suivante, en considérant que `||` représente la reliure du livre :
    (( {align: :center} ))
    `| gauche | centre | droit || gauche | centre | droit |`


    ##### Définition des entêtes et pieds de page

    Les *entêtes* et *pieds de page*, comme pour le reste, se définissent dans [[-recette/grand_titre]] du livre ou de la collection, dans une section qui s’appelle, on ne s’en étonnera pas : `headers_footers`.
    (( line ))
    On peut définir autant de *dispositions* que l’on veut, même s’il est conseillé, toujours, de rester le plus sobre possible. On peut se contenter, pour un résultat optimum, d’une *disposition* pour le corps du livre, son contenu principal, et une *disposition* pour les annexes si elles existent.
    La propriété principale de la disposition est la valeur de son `header` (son "entête") et son `footer` ("pied de page"). Par défaut, les valeurs sont :
    * `header` : \\"| x    | x | x || x | x | x    |\\"
    * `footer` : \\"| -NUM | x | x || x | x | NUM- |\\"
    On voit clairement la reliure représentée par `||` et de chaque côté les trois portions.
    Les `x` signifient qu’on ne met rien dans ces portions.
    Le `NUM` indique l’endroit où l’on va marquer le numéro de la page. Voir ci-dessous les *éléments* qui peuvent composer une disposition.
    Le tiret (moins) qui précède ou suit *NUM* indique l’alignement dans la portion. Le trait avant (`-NUM`) signifie que le numéro sera aligné à gauche, le trait après (`NUM-`) signifie que le numéro sera aligné à droite. Pour le centrer, on aurait rien mit car l’élément est aligné au centre par défaut.
    (( line ))
    Mais en fait, la vraie disposition est plus simple, car il est inutile de définir toutes les portions si elles sont vides. La vraie disposition par défaut dans _PFB_ est :
    * `header` : \\"| x    || x    |\\"
    * `footer` : \\"| -NUM || NUM- |\\"

    ##### Les éléments

    Les éléments qui peuvent être utilisés dans les entêtes et les pieds de page sont illimités en mode expert ([[expert/header_footer]]). Pour le commun des mortels, ils se limitent — ce qui est déjà largement suffisant — aux titres courants jusqu’au niveau 5 (en majuscules, en minuscules, ou format titre), au numéro de la page ainsi qu’au nombre total de page.
    * **`NUM`** pour le numéro de page,
    * **`TIT1`** pour le titre de niveau 1 courant, en majuscules,
    * **`tit1`** pour le titre de niveau 1 courant, en minuscules,
    * **`Tit1`** pour le titre de niveau 1 courant, en format titre,
    * **`TIT2`** (et **tit2**, **Tit2**) pour le titre de niveau 2 courant,
    * **`TIT3`** (et **tit3**, **Tit3**) pour le titre de niveau 3 courant,
    * **`TIT4`** (et **tit4**, **Tit4**) pour le titre de niveau 4 courant,
    * **`TIT5`** (et **tit5**, **Tit5**) pour le titre de niveau 5 courant,
    * **`TOT`** pour le nombre total de pages,
    * **`\\\#{code}`** pour un code ruby quelconque à évaluer à la volée, par exemple un numéro de version ou des auteurs,


    ##### Ajustement

    Noter bien que l’*ajustement vertical* effectué avec `header_vadjust` et `footer_vadjust` fonctionne différemment. Dans les deux cas, il définit l’éloignement *par rapport au texte principal de la page*. Ainsi, pour `header_vadjust` (l’entête), une valeur positive fera monter les portions alors que pour `footer_vadjust` (le pied de page), une valeur positive les fera descendre.

    ##### Fontes

    Bien qu’on puisse définir les polices très précisément pour chaque élément, il est conseillé de ne pas trop les différencier. La sobriété est toujours bonne conseillère, en matière de mise en page.
    C’est la raison pour laquelle, par défaut, on ne peut définir que la police générale des deux *entête* et *pied de page*, à l’aide de la propriété `font` (qui est une [["fonte-string"|annexe/font_string]]), et/ou les propriétés `header_font` (fonte pour les entêtes) et `footer_font` (fonte pour les pieds de page).
    Vous pourrez trouver dans les exemples suivants l’utilisation de ces propriétés.
    EOT


    sample_recipe <<~EOT
      ---
      # .\\..
      # Définit le début de la définition des entêtes et pieds de
      # page
      headers_footers:

        # Définition des dispositions
        dispositions:

          # Pour supprimer la disposition par défaut, il suffit 
          # de faire :
          default: null

          # Définition d’une disposition
          ma_disposition:
            name: "Nom humain juste pour mémoire"
            # Fonte particulière pour cette disposition en 
            # particulier :
            font: "<font name>/<font style>/<font size>/<font color>"
            pages: <première page>-<dernière page>
            header: | x | x | x || x | x | x |
            header_font: "<fonte>/<style>/<size>/<color>"
            header_vadjust: <ajustement vertical entête>
            header_hadjust: <ajustement horizontal entete>
            footer_vadjust: <ajustement vertical pied>
            footer_vadjust: <ajustement vertical pied>
            footer_font: "<fonte>/<style>/<size>/<color>"
            footer: | x | x | x || x | x | x |

          - name: "Autre disposition"
            font: .\\..
            etc.
      EOT

    # sample_recipe <<~YAML
    # ---
    # headers_footers:
    #   dispositions:
    #     defaut_manuel:
    #       name: "Disposition pages normales"
    #       pages:  1-
    #       header: "| -TIT2 || TIT3- |"
    #       footer: "| -NUM  || NUM-  |"
    #   YAML

    # texte <<~EOT

    # EOT

end
