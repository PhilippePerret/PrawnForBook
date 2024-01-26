Prawn4book::Manual::Feature.new do
  sous_titre "Table des matières entièrement customisée"
  real_texte <<~EOT
    (( toc ))
    # Un titre de niveau 1
    ## Un titre de niveau 2
    ## Autre titre de niveau 2
    ### Titre de niveau 3
    ### Titre *stylisé* de niveau 3
    #### Un seul titre de niveau 4
    ### Titre **gras** de niveau 3
    # Deuxième titre de niveau 1
    ## Titre 2.1 de niveau 2
    # Troisième titre de niveau 1
    ## Titre 3.1 de niveau 2
    ## Titre 3.2 de niveau 2
    ## Titre 3.3 de niveau 2
    EOT

  real_recipe <<~YAML
    ---
    book_format:
      book:
        width: 210mm
        height: 297mm
      titles:
        level1:
          new_page: false
          belle_page: false
          alone: false
          align: :center
    #
    # - Table des matières -
    #
    table_of_content:
      title:      "Mon Sommaire"
      no_title:   false
      numeroter:  false
      level_max:  4
      line_height: 24
      level1:
        font: "Helvetica/light/20/55A200"
        numero_size: 12
      # level2:
      #   numero_size: 15
      level2:
        dash: {color: "0000FF"}
      level3:
        indent: 6cm
        numero_size: 10
        caps: "all-caps"
        dash: {length: 10, space: 2} 
      level4:
        font: "Reenie/normal/15/FF0000"
        numero_size: 10
        dash: {length: 1, space: 3} 
    YAML

  texte <<~EOT
    Table des matières entièrement customisée (personnalisée).
    On remarquera :
    * le titre original de la page (grâce à "`title: \\"Mon Sommaire\\"`"),
    * l’alignement au centre du titre de la page (grâce à "`align: :center`"),
    * l’absence de numérotation de la page,
    * les quatre niveaux de titre, alors qu’il y en a 3 par défaut (grâce à "`level_max:  4`"),
    * la taille, police et couleur du titre de niveau 1,
    * la couleur spéciale pour la ligne de pointillé du titre de niveau 2 grâce à "`dash: {color: \\"0000FF\\"}`"
    * l’indentation forte du titre de niveau 3,
    * le niveau 3 passé en capitales avec "all-caps",
    * les styles simples (italique, gras…) qu’on peut appliquer aux titres,
    * l’aspect des pointillés grâce à la propriété `:dash` pour les titres de niveau 3 et 4,
    * un niveau inférieur (comme le titre de niveau 4) peut tout à fait être moins en retrait qu’un titre supérieur (les titres de niveau 3).

    Notes :
    * En mettant `numeroter` à `true`, on peut obtenir la numérotation de la page.

    AJOUTER :
    * position horizontale du numéro de page
    * jouer sur vadjust pour le numéro de page
    * jouer sur vadjust pour la ligne pointillée

    (( new_page ))
    ![page-4](width:"100%")
    (( new_page ))
    EOT
end
