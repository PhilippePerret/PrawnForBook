Prawn4book::Manual::Feature.new do

  titre "Introduction"


  description <<~EOT
    _PFB_ possède un système de gestion des bibliographies très puissant. Elle peut en gérer autant que l’on veut, donc une infinité, et les mettre en forme de la façon exacte que l’on veut, avec une connaissance minimum du langage ruby (et encore, comme d’habitude, on peut se contenter des comportements par défaut).
    Une bibliographie se définit dans _PFB_ par une donnée dans la section principale de recette `bibliographies` et une balise qui servira d’identifiant pour la bibliographie et de balise pour repérer le texte. Par exemple les balises `article` et `film` qui serviront d’illustration ci-dessous et seront utilisés dans le texte de cette manière :
    « C’est une référence à l’article article\\(Les chaussures|0001) et une référence au film film\\(Titanic). »

    ##### Données minimales

    Une bibliographie est définie par les données minimales et indispensables suivantes (pour la compréhension, on choisit d’illustrer une bibliographie pour des articles de journaux) :
    * le **tag** (ou **identifiant**) | C’est un mot simple, au singulier (p.e. "article") qui caractérise la bibliographie. C’est ce tag qui permettra de définir, au cours du livre, les éléments bibliographiques.
    * Un **titre** (**`title`**) | Le titre de la bibliographie, qui sera imprimé avant d’afficher la bibliographie.
    * Une **banque de données** qui contient, comme son nom l’indique, toutes les données bibliographiques. Pour la définir, on définit simplement son chemin d’accès **`path`**, qui peut être un dossier (contenant les *cartes* de données) ou un fichier (contenant toutes les données).
    Ce sont les données minimales à définir pour qu’une bibliographie soit utilisable.
    (( line ))
    À partir de là, dans le texte, il suffit de mettre un mot ou un grand de mot entre parenthèses en le précédant de l’identifiant de la bibliographie pour que cet élément soit pris en repère. Par exemple : 

    EOT

  sample_recipe <<~YAML
    ---
    bibliographies:
      # Ici la définition de toutes les bibliographies
       
      # Définition de la première bibliographie
       
      article: # id bibliographie
        title: "Articles de presse"
        path:  "chemin/vers/données/articles"
       
      # Définition de la deuxième bibliographie
       
      film:
        title: "Liste des films"
        path: "chemin/vers/données/films"
    YAML

  sample_texte <<~EOT #, "Autre entête"
    Un texte exemple qui utilise un article\\(premier article) en référence bibliographique. Ce paragraphe contient aussi une référence au film film(The Titanic) qui se déroule dans un bateau.
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
