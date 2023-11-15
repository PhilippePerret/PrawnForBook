Prawn4book::Manual::Feature.new do

  titre "Les deux fichiers de base"


  description <<~EOT
    Un livre _PFB_ peut se définir, au minimum, par deux fichiers fonctionnant de paire :
    * un fichier définissant le *texte du livre*, donc le **contenu**,
    * un fichier définissant l’*aspect du livre*, appelé "recette".

    #### Le fichier contenu

    Le fichier du texte porte impérativement le nom `texte.pfb.md` et contient l’ensemble du contenu du livre. Il peut aussi faire appel à des *helpers* qui produiront du contenu dynamique.
    Par exemple, si c’est un dictionnaire, on peut imaginer que le livre travaille en parallèle avec une base de données contenant la définition des mots. 
    Les bibliographies sont aussi des exemples de contenus qui peuvent être gérés automatiquement, pour un confort plus grand, une agilité incroyable et une cohérence à toute épreuve.
    Le fichier porte l’extension `pfb.md` qui est composée de `pfb` pour "Prawn For Book" et de `md`, extension naturelle du *markdown* qui est le langage qui a inspiré l’établissemen du contenu. Comme nous le verrons, c’est cependant un *pseudo-markdown* qui est utilisé.

    #### Le fichier recette

    Il porte impérativement le nom `recipe.yaml` quand il concerne un livre et `recipe_collection.yaml` quand il concerne une collection (nous reviendrons en temps voulu sur cette distincion).
    Comme l’indique son extension, ce fichier est au format `YAML`, un format très simple permettant de définir des données (cf. ci-dessous).
    EOT



end
