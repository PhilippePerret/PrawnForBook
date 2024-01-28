Prawn4book::Manual::Feature.new do

  titre "Introduction"


  description <<~EOT
    _PFB_ possède un système de gestion des bibliographies très puissant. Elle peut en gérer autant que l’on veut, donc une infinité, et les mettre en forme de la façon exacte que l’on veut, avec une connaissance minimum du langage ruby (et encore, comme d’habitude, on peut se contenter des comportements par défaut).
    Une bibliographie se définit dans _PFB_ par une donnée dans la recette du livre ou de la collection, dans une section principale `bibliographies` qui consiste en une balise qui servira d’identifiant et de balise pour repérer le texte. 
    Par exemple, dans la recette, on va trouver :
    (( line ))
    ~~~yaml
    ---
    bibliographies:
      article:
        title: "Articles de presse"
        path:  bib/articles
      film:
        title: "Films"
        path:  bib/films
    ~~~
    (( line ))
    Et dans le texte on pourra alors utiliser les balises "article" et "film" pour consigner des références.
    (( line ))
    « C’est une référence à l’article article\\(Les chaussures|0001) et une référence principale au film film\\(Titanic||main). »

    #### Nomenclature pour les bibliographies

    *(comme pour les autres parties, commençons par un lexique qui permet de fixer les termes que nous employons pour parler de bibliographie)*
    (( line ))
    * **Bibliographie** | Ensemble de sources quelconques, de toutes natures, dont il est fait référence au cours du livre, et qu’ils faut rassembler à la fin du livre, avec ses informations, pour que le lecteur puisse s’y référer. Par exemple une liste de livres, de films ou de mots techniques. Désigne aussi l’ensemble de ses *items*.
    * **item** ou **item bibliographique** | C’est un élément en particulier de la bibliographie, un film en particulier s’il s’agit d’une liste de films, un livre en particulier s’il s’agit d’une liste de livres, un mot en particulier si c’est un index de mots.
    * **Marque de référence** | Marque spéciale, dans le texte, qui permet de consigner un *item bibliographique*. Elle se construit à l’aide de l’identifiant de la bibliographie, suivi de parenthèses à l’intérieur desquelles on place l’identifiant de l’*item bibliographique*. Par exemple `livre\\(Les Misérables)` dans la phrase `Avez-vous lu livre\\(Les Misérables), un livre de person\\(Victor Hugo)`.
    * **Données bibliographiques** ou **Banque de données** | Ensemble complet des *fiches* qui comprennent l’intégralité des *items* d’un bibliographie, même ceux non cités, dans laquelle on va puiser les sources pour y faire référence.
    * **Fiche** ou **carte** | Fichier informatatique ou enregistrement (dans une fichier CSV) qui contient toutes les données de l’*item bibliographique* (par exemple toutes les données du film ou du livre).
    * **Liste des sources** | Désigne la liste, à la fin du livre, qui liste l’ensemble des *items* cités (et seulement les items cités) et, dans _PFB_, indique les pages où il y est fait référence.

    #### Données minimales des bibliographies

    Dans la recette, une bibliographie est définie par les données minimales et indispensables suivantes (pour la compréhension, on choisit d’illustrer une bibliographie pour des articles de journaux) :
    * Le **tag** (ou **identifiant**) | C’est un mot simple en minuscule (donc seulement les lettres de "a" à "z", au singulier (p.e. "article") qui sert de *clé* pour la bibliographie. C’est ce tag qui sera utilisé au cours du livre pour construire un *marquer de référence* pour faire référence à un *item bibliographique* en particulier (cf. plus bas).
    * **`title`** ("titre" en anglais) | Le titre de la bibliographie, qui sera imprimé avant d’afficher la bibliographie.
    * **`path`** ("chemin d’accès" en anglais) | qui indique le chemin jusqu’à la *banque des données bibliographiques* qui contient, comme son nom l’indique, toutes les données bibliographiques. C’est au mieux un dossier (contenant les *cartes* ou les *fiches* de données, une par *item*) ou un fichier (contenant toutes les données).
    (( line ))
    Ce sont les données minimales à définir pour qu’une bibliographie soit utilisable. Dans la recette (cf. [[recette/_titre_section_]]), elles sont définies de cette manière :
    (( line ))
    ~~~yaml
    bibliographies:
      \\<tag>:
      # Propriétés indispensables
      title: "\\<titre>"
      path: "\\<path/to/data>"
      # Propriétés optionnelles
      main_key: "\\<clé item>" # si autre que title
      format: \\<format>
      picto: "\\<picto>"
    ~~~

    ##### Données optionnelles

    Pour commencer à personnaliser l’affichage de la bibliographie (ou des *items* dans le texte), on peut utiliser ces propriétés optionnelles :
    * **`main_key`** ("clé principale" en anglais) | Si ce n’est pas la propriété `title` de l’item (à ne pas confondre avec le `title` dont nous venons de parler) qui doit être utilisée pour remplacer la marque de référence, c’est la valeur de cette clé principale qu’il faudra prendre (et qui doit donc impérativement être définie pour chaque item bibliographique)
    * **picto** | Pictogramme à utiliser avant le texte qui remplacera la *marque de référence* dans le texte du livre.
    * **`title_level`** ("niveau de titre" en anglais) | Le niveau de titre pour la section qui liste les sources citées. Par défaut, ce niveau est 1, le plus grand titre.
    * **format** | Format à utiliser pour l’affichage de la *liste des sources*,
    * **key_sort** ("clé de classement" en anglais) | Clé de classement des *items* dans la *liste des sources*

    #### Référence dans le texte

    (( line ))
    À partir de là, dans le texte, il suffit d’utiliser :
    (( line ))
    `\\<id bibliographie>(\\<id item>)`
    (( line ))
    Ce code sera remplacé par le titre (`title`) de la donnée de l’item, dans sa carte (cf. plus bas) et cette référence sera enregistrée pour l’ajouter à la liste des sources bibliographiques à la fin du livre..
    … ou, si l’on veut un autre texte gravé au lieu du titre de l’*item* :
    (( line ))
    `\\<id bibliographie>(\\<texte gravé>|\\<id item>)`
    (( line ))

    #### Importance de la référence

    Souvent, dans un texte, les appels de référence peuvent avoir plus ou moins d’importance. Une section du livre peut par exemple juste mentionner un film et une autre, au contraire, développer autour de ce film de façon conséquence.
    On peut marquer cette importance à l’aide d’un signe ajouté au début de la marque de référence.
    * un "!" indiquera que la référence est importante,
    * un "." indiquera que la référence est mineure, c’est-à-dire qu’on ne fait qu’une mention à l’item, sans développer.
    Par exemple :
    (( line ))
    ~~~
    Ici un long développement sur le film film(!Titanic) qui traite de…
    .\.. Un peu plus loin .\..
    Ici je fais juste mention à film{{(}}.Titanic) pour le citer parmi d’autres…
    ~~~
    (( line ))
    Dans la bibliographie en fin d’ouvrage (ou ailleurs où vous la placerez), les pages des références importantes seront mises en gras tandis que les pages des références mineures seront grisées.
    (( line ))
    *Note : La marque "!" ou "." se met toujours après la parenthèse, même si un texte alternatif est proposé. Ainsi, on trouvera "film\\(!Titanic)" aussi bien que "film\\(!ce film|Titanic)`.*

    #### Données bibliographiques

    Dans l’idéal, les données sont consignées dans un dossier qui contient chaque donnée sous forme de fiche (un fiche par item) au forme YAML (le format des recettes). Ce format permet une édition facile des données. Cependant, vous pouvez aussi utiliser le format `JSON` ou même `TXT` (simple texte).

    ##### Items de la bibliographie

    Au minimum (mais ce serait un peu idiot de n’avoir que ça…), un item de bibliographie doit définir sa propriété `title` qui correspond à son titre. `title` est sa clé principale. Mais puisque _PFB_ est hautement configurable, même cette clé principale peut avoir un autre nom, il suffit de la définir dans la propriété `main_key` des données de la bibliographie, dans la recette.
    Donc un item bibliographique peut ressembler à :
    {-}`# Dans "the titanic.yaml`
    {-}`---`
    {-}`title: "The Titanic"`
    {-}`title_fr: "Titanic"`
    {-}`director: "James CAMERON`
    {-}`year: 1999`

    ##### Liste des sources

    Dans le livre, il suffit de placer le code `\\(( <id bibliographie> \\))` pour insérer la bibliographie à l’endroit voulu. Par défaut, toutes les informations seront affichées, mais il sera possible de tout formater à sa convenance (cf. plus loin).
    Par exemple :
    (( line ))
    (( {align: :center} ))
    {-}`(( biblio\\(film) ))` 
    (( line ))
    … pour afficher la liste des films cités (et seulement ceux cités) et/ou :
    (( line ))
    (( {align: :center} ))
    {-}`(( biblio\\(article) ))` 
    (( line ))
    … pour afficher la liste des articles (seulement ceux cités), avec les pages où ils sont cités.

    ##### Formatage de la *liste des sources*

    Le formatage de l’affichage de la *liste des sources* en fin d’ouvrage se définit, comme nous l’avons vu, par la propriété `format` de la bibligraphie, dans la recette.
    Cette propriété n’est pas obligatoire et en son absense, ne sera affiché à la fin du livre que le titre de l’*item* (propriété `title`) ainsi que la liste des pages (ou autre indication en fonction de la _pagination_ choisie) où cet *item bibliographique* est cité. C’est le cas, dans l’exemple, pour la liste des articles par exemple (cf. ci-dessous).
    EOT

  sample_recipe <<~YAML
    ---
    bibliographies:
      # Ici la définition de toutes les bibliographies
       
      # Définition de la première bibliographie
       
      article: # id bibliographie
        title: "Articles de presse"
        title_level: 2
        path:  "chemin/vers/données/articles"
       
      # Définition de la deuxième bibliographie
       
      film:
        title: "Liste des films"
        path: "chemin/vers/données/films"
       
      # Définition d’une autre bibliographie
       
      autrebib:
        title: "Pour propose autre chose"
        path: "..."
        picto: :fiche
        main_key: "truc" # autre clé que ’title’
    YAML

  sample_texte <<~EOT #, "Autre entête"
    Un texte exemple qui utilise un article\\(premier article) en référence bibliographique. Ce paragraphe contient aussi une référence au film film\\(The Titanic) qui se déroule sur un bateau.
    EOT

  texte(:as_sample)

  # texte <<~EOT
  #   Texte à interpréter, si 'sample_texte' ne peut pas l'être.
  #   EOT

  # recipe <<~EOT #, "Autre entête"
  #   ---
  #     # ...
  #   EOT

  # # init_recipe([:custom_cached_var_key])

end
