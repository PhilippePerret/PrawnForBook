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
    # - Page à (ne pas) insérer -
    #
    inserted_pages:
      page_de_garde: false
      faux_titre: false
      page_de_titre: false
    #
    # - Table des matières -
    #
    table_of_content:
      title:      "Mon Sommaire"
      no_title:   false
      lines_before: 8
      numeroter:  false
      level_max:  4
      line_height: 24
      vadjust_number: 2
      level1:
        font: "Helvetica/light/20/55A200"
        numeroter: false
      level2:
        dash: {color: "0000FF"}
      level3:
        indent: 6cm
        number_size: 10
        number_indent: 40
        caps: "all-caps"
        dash: {length: 10, space: 2} 
      level4:
        font: "Reenie/normal/15/FF0000"
        number_size: 10
        number_color: "BBB000"
        dash: {length: 1, space: 3} 
        vadjust_line: -5
        vadjust_number: -2
    YAML

  texte <<~EOT
    Table des matières entièrement customisée (personnalisée).
    On remarquera :
    * le titre original de la page (grâce à "`title: \\"Mon Sommaire\\"`"),
    * l’alignement au centre du titre de la page (grâce à "`align: :center`"),
    * l’absence de numérotation de la page,
    * la table des matières proprement dite qui commence à 8 lignes du titre grâce au "`lines_before: 8`",
    * les quatre niveaux de titre, alors qu’il y en a 3 par défaut (grâce à "`level_max:  4`"),
    * l’ajustement vertical des numéros de page de tous les niveaux de titre sauf le 4, pour qu’ils soient bien alignés à la ligne pointillée, grâce au "`vadjust_number: 2`" général,
    * la taille, police et couleur du titre de niveau 1 grâce à la définition de "`font:`",
    * l’absence de numéro de page des titres de niveau 1 grâce à "`numeroter: false`",
    * la couleur spéciale pour la ligne de pointillé du titre de niveau 2 grâce à "`dash: {color: \\"0000FF\\"}`"
    * l’indentation forte du titre de niveau 3,
    * le niveau 3 passé en capitales avec "all-caps",
    * l’identation (négative) du numéro de page des titres de niveau 3 mise à 40 points-postscript grâce à "`number_indent: 40`",
    * les styles simples (italique, gras…) qu’on peut appliquer aux titres,
    * l’aspect des pointillés grâce à la propriété `:dash` pour les titres de niveau 3 et 4,
    * un niveau inférieur (comme le titre de niveau 4) peut tout à fait être moins en retrait qu’un titre supérieur (les titres de niveau 3),
    * la couleur propre du numéro de page du titre de niveau 4 grâce à son "`number_color: "BBB000"`",
    * l’alignement propre du numéro de page du titre de niveau 4 grâce à son "`vadjust_number: -2`" propre,
    * la ligne pointillée du titre de niveau 4 remontée grâce au "`vadjust_line: -5`".

    Notes :
    * En ajoutant "`numeroter: true`", on obtiendrait la numérotation de la page,
    * En ajoutant "`belle_page: false`", la table des matières s’inscrirait sur la page précédente.

    (( new_page ))
    ![page-3](width:"100%")
    (( new_page ))
    EOT
end
