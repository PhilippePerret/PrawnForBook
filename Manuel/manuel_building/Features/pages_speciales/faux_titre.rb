Prawn4book::Manual::Feature.new do

  titre "Page de Faux-titre"


  description <<~EOT
    La page de *faux titre* ("half-title page" en anglais, pour information) est souvent la toute première page imprimée du livre. Elle contient le titre seul, parfois accompagné du sous-titre. Elle est parfois précédée d’une page de garde.
    Dans notre nomemclature, c’est le vis-à-vis 1 (si pas de page de garde) ou 2 (si page de garde).
    Vous pourrez trouver dans l’article [Les Pages d’un livre](https://www.icare-editions.fr/blog/pages-livre) la description de toutes les pages d’un livre.

    #### Activation de la page de faux-titre

    Par défaut, dans la recette, la page de faux-titre est considérée comme absente. Pour l’activer, sans autre précision, il suffit de mettre le `inserted_pages: half_title:` à `true` ("vrai" en anglais) :
    (( line ))
    {-}`inserted_pages:`
    {-}`  faux_titre: true`
    (( line ))
    Avec ce réglage, si `page_de_garde` est à `false` ("faux" en anglais), vous devriez voir que la troisième page de votre document PDF porte le titre de votre livre.
    Ce faux-titre utilise la police par défaut, légèrement augmentée au niveau de la taille, et la place à peu près au tiers de la hauteur de la page.
    Si votre livre possède un sous-titre, il sera affiché en dessous du titre, plus petit. Nous verrons que vous pouvez tout à fait supprimer ce sous-titre pour la page de faux-titre.

    #### Réglage fin de la page de faux-titre

    Comme tous les autres aspects de _PFB_, on peut définir très finement l’apparence de la page de faux-titre. Au lieu du `true` vu ci-dessus — qui applique à la page de faux-titre les valeurs par défaut, qui sont déjà très bonnes —, il suffit de définir les données de cette page. Voyez ci-dessous, avec l’exemple de recette, toutes les propriétés possibles.



    EOT

  sample_recipe <<~YAML, "À mettre dans la recette"
    ---
    inserted_pages:
      # Définition de la page de faux-titre
      # (comme toujours toutes les valeurs non définies prendront
      #  naturellement les valeurs par défaut)
      # Pour appliquer les valeurs par défaut, décommenter 
      # simplement la ligne suivante (en retirant toute la suite)
      # faux_titre: true
      faux_titre:
        # Pour appliquer au titre les valeurs par défaut, retirer
        # simplement la définition suivante.
        title:
          # Police à utiliser, avec sa taille, son style et sa 
          # couleur (toute valeur absente prendra la valeur par
          # défaut)
          font: "<police>/<style>/<taille>/<couleur>"
          # La ligne sur laquelle poser le titre
          # (ajouter -grid en construisant le livre pour voir les
          #  lignes)
          line:  6
          # Écartement entre les lignes du titre s’il tient sur
          # plusieurs lignes
          leading: 0.5
        # Pour ne pas afficher le sous-titre, décommenter 
        # simplement la ligne suivante (et supprimer les 
        # définitions qui la suivent)
        # subtitle: false
        # Pour utiliser les valeurs par défaut pour le sous-
        # titre, retirer simplement les définitions suivantes
        subtitle:
          # Le sous-titre possède les mêmes propriétés que le 
          # titre, voyez ci-dessus comment les définir.
          font: "<police>/<style>/<taille>/<couleur>"
          line: 10
          leading: 0

    YAML

end
