Prawn4book::Manual::Feature.new do

  titre "Page des crédits (Colophon)"

  description <<~EOT
    On appelle *page des crédits*  ou *colophon* la page placée à la fin du livre qui donne toutes les informations sur le livre, aussi bien au niveau de l’éditeur ou la maison d’éditions (son nom, son adresse, son email) qu’au niveau de toutes les personnes qui ont contribué à conception du livre, rédacteur ou rédactrice, metteur ou metteuse en page, graphiste, concepteur, directeur ou directrice de collection, en passant par d’autres informations comme le numéro ISBN du livre et sa date de parution ou les remerciements.
    Si vous êtes de niveau *Expert*, vous pouvez bien entendu mettre cette page en forme de façon tout à fait personnalisée dans le détail, en faisant appel aux éléments de la recette (pour rappel, dans les modules ruby, cela s’obtient en faisant appel à la méthode `book.recipe` qui permet d’atteindre toutes les valeurs de la recette, et donc les informations de cette page.
    Mais sans être *expert*, on peut obtenir une mise en page tout à fait correcte et professionnelle ici encore grâce aux comportements par défaut. Sans rien préciser d’autre que les informations minimales requises pour le livre ou la collection, la page des infos sera placée à la fin du livre si `pages_speciales: credits_page:` est à `true` dans la recette.

    ##### Impression de la page de crédits

    La première chose à faire pour s’assurer que la page de crédits sera imprimée est de mettre la valeur `inserted_pages: credits_page:` à `true` (vrai).
    Ensuite, il faut s’assurer que les valeurs minimales soient fournies. Vous pouvez lancer une première fois la construction du livre pour connaitre les informations manquantes.

    ##### Informations requises

    Toutes les informations requises pour la page des informations se trouvent dans les données `book_making` ("fabrication du livre" en anglais) et `credits_page` de la recette du livre et/ou de la collection.
    Toutes les données de `book_making` — le ou les concepteurs du livre, le ou les rédacteurs, le ou les metteurs en page, graphiste, concepteurs de la couverture ou correcteurs — comprennent deux informations :
    * **`patro`** | Pour le patronyme, seul ou une liste. Le patronyme s’écrit toujours avec la même convention : le prénom en minuscule avec capitale au début, le nom tout en capitales. S’il y en a plusieurs, on les met entre crochets (cf. l’exemple ci-dessous).
    * **`mail`** | Le mail du *patro* ci-dessus. S’il y a plusieurs personnes, on indique les mails dans le même ordre, entre crochets (comme ci-dessous).
    (( line ))
    La page des crédits contient aussi les informations sur l’éditeur ou la maison d’édition, qui doivent se trouver dans la section `publisher` de la recette. La seule information requise est le nom de l’éditeur (`publisher: name:`).
    (( line ))
    Vous trouverez ci-dessous, dans l’exemple de recette, toutes les informations utilisables dans la page de crédits.

    EOT

  sample_recipe <<~YAML
    ---
    inserted_pages:
      credits_page: true # pour qu’elle soit imprimée

    book_data:
      isbn: .\\..
      url:  "https://url/du/livre"

    book_making:
      conception:
        patro: "Prenom NOM"
        mail:  "mail@chez.lui"
      writing:
        patro: "Prenom NOM"
        mail:  "mail@chez.lui"
      page_design: # Mise en page
        patro: ["Prénom NOM", "Prénom NOM"]
        mail:  ["premier@chez.lui", "deuxieme@chez.lui"]
      cover:  #  Couverture
        patro: .\\..
        mail: null
      correction:
        patro: .\\..
        mail: .\\..
      acknowledgements: # remerciements
        patro: .\\..

    publisher:
      name: "<nom éditeur ou édition>"
      address: <Rue et numéro\\nLieu dit\\nVille et code postal
      url: "<url du site internet>"
      mail: "<mail@editeur.fr>"
      contact: "<mail contact>"
      siret: "<numéro siret>"

    credits_page:
      disposition: "distribute" # ou "bottom", "top"
      label: 
        font: "fonte/style/taille/couleur"
      value:
        font: "fonte/style/taille/couleur"
      printing:
        name: "à la demande" # p.e. pour KDP
        lieu: null
    YAML

  # sample_texte <<~EOT #, "Autre entête"
  #   Le texte en exemple. Si 'texte' n'est pas défini, sera interprété aussi. Sinon sera mis en illustration et c'est 'texte' qui sera interprété comme texte du livre.    
  #   EOT

  # texte <<~EOT
  #   Texte à interpréter, si 'sample_texte' ne peut pas l'être.
  #   EOT

  # recipe <<~EOT #, "Autre entête"
  #   ---
  #     # ...
  #   EOT

  # # init_recipe([:custom_cached_var_key])

end
