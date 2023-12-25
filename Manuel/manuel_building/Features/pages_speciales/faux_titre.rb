Prawn4book::Manual::Feature.new do

  titre "La page de Faux-titre"


  description <<~EOT
    
    La page de *faux titre* ("half-title page" en anglais, pour information) est souvent la toute première page imprimée du livre. Elle contient le titre seul, parfois accompagné du sous-titre. Elle est parfois précédée d’une page de garde.
    Dans notre nomemclature, c’est le vis-à-vis 1 (si pas de page de garde) ou 2 (si page de garde).
    Cette page ne contient ni pagination (numéro de page) ni entête.

    Page contenant juste le titre et l’auteur, avant la *page de titre* proprement dit. Par défaut, elle n’est pas placée dans un livre produit par _PFB_. 
    Pour la graver dans le livre, mettre la propriété `faux_titre` (ou `half_title_page`) de la section `inserted_pages` de la recette à `true` ou à une table définissant précisément l’aspect. Ici, encore, comme d’habitude, vous avez le choix entre l’aspect par défaut (impeccable comme ça) avec `true` :
    (( line ))
    ~~~yaml
    inserted_pages:
      faux_titre: true
    ~~~
    (( line ))
    Ce *faux-titre* par défaut utilise la police par défaut, légèrement augmentée au niveau de la taille, et la place à peu près au tiers de la hauteur de la page.
    Si votre livre possède un sous-titre, il sera affiché en dessous du titre, plus petit. Nous verrons que vous pouvez tout à fait supprimer ce sous-titre pour la page de faux-titre.

    #### Réglage de la page de faux-titre

    Vous pouvez effectuer un réglage plus fin de cette page :
    (( line ))
    ~~~yaml
    inserted_pages:
      faux_titre:
        title
          font:   "police/style/taille/couleur"
          line:   12 # ligne sur laquelle poser le titre
          leading: 0 # interlignage (si tient sur plusieurs lignes)
        # Pour ne pas afficher le sous-titre, décommentez simplement
        # la ligne suivante
        # subtitle: false
        # Dans le cas contraire, vous pouvez régler les propriétés
        # de la page de sous-titre
        subtitle:
          font: ...
          line: ...
          leading: ...
        author:
          font:  "police/style/taille/couleur"
          line:   16 # ligne sur laquelle poser l’auteur
          leading: 0 # interlignage (si plusieurs auteurs, qui 
                     # tiennent sur plusieurs lignes)
    ~~~
    (( line ))

    Notez que partout où les lignes ne sont pas définies, _PFB_ gardera les valeurs par défaut, ce qui permet d’ajuster facilement un seul élément.
    Ajouter -grid en construisant le livre pour voir les lignes
    Toute les valeurs des fontes-strings non définies sont remplacées par les valeurs par défaut

    EOT

end
