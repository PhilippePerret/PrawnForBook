Prawn4book::Manual::Feature.new do

  titre "Afficher grille de référence et marges"

  description <<~EOT
    Pour régler finement l’aspect général du livre, et notamment les marges et les *lignes de référence*, on peut demander à _PFB_ de révéler ces marges et ces *lignes de référence* par des traits de couleur. 
    On peut le faire soit en utilisant les *options* en ligne de commande :
    (( line ))
    {-}`> pfb build -margins -grid`
    (( line ))
    … soit, si on veut les voir affichés pendant un long moment, en définissant les valeurs de `show_margins` et `show_grid` dans le fichier recette (du livre ou de la collection) :
    (( line ))
    ~~~yaml
    # ./recipe.yaml ou ../recipe_collection.yaml
    book_format:
      page:
        show_margins: true # mettre à false quand fini
        show_grid:    true # idem
    ~~~
    (( line ))
    Quel que soit le moyen utilisé, il faut penser à retirer ces lignes avant de graver le document final à envoyer à l’imprimerie. Dans le cas contraire, ces lignes apparaitraient dans le livre !
    EOT

end
