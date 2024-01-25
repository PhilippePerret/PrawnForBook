Prawn4book::Manual::Feature.new do

  titre "La Grille de référence"


  description <<~EOT
    #### Définition

    La *grille de référence* est une grille de ligne horizontale abstraite sur laquelle vont venir se poser toutes les lignes de votre texte, pour donner un aspect professionnel irréprochable à votre livre.
    Dans un traitement de texte classique, elle n’existe pas forcément. Dans _PFB_, destiné à l’impression professionnelle, elle est imposée.

    #### Utilité de la grille de référence

    La *grille de référence* permet d’aligner parfaitement les lignes entre la page gauche (*fausse page*) et la page droite (*belle page*). Sans cette grille, les lignes seraient décalées et l’aspect ne serait pas harmonieux.
    En posant toutes les lignes du texte sur les lignes de la *grille de référence*, on évite enfin de voir par transparence les lignes des pages précédentes dans les interlignes de la page courante, ce qui *noircit* la page.

    #### Afficher la grille de référence

    Pour afficher la grille, ajouter simplement l’option `-grid` à votre ligne de commande pour fabriquer le livre, ou ajouter `show_grid: true` dans la section `page` de la section `book_format` dans la recette de votre livre ou de votre collection.
    (( line ))
    ~~~yaml
    # Dans ./recipe.yaml ou ../recipe_collection.yaml
    ---
    book_format:
      page:
        show_grid: true
    ~~~
    EOT

end
