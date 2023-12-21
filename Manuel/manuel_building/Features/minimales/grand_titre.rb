Prawn4book::Manual::Feature.new do
  grand_titre "Définitions minimales"

  description <<~EOT
    Cette section se concentre sur les définitions minimales que vous aurez à faire si les définitions par défaut ne conviennent pas au livre que vous êtes en train d’écrire. Typiquement, il est fort possible que la taille du livre ainsi que les marges ne soient pas définis par défaut comme votre livre le demande.
    C’est ici que vous apprendrez à régler ces valeurs.
    Cette partie suppose que vous avez déjà parcouru cette aide et que vous connaissez, notamment, l’usage des recettes utilisées par _PFB_ (voir [["recette du livre", page __page__|recette/recette_livre]] et [["recette de la collection", page __page__|recette/recette_collection]]). Dans le cas contraire, reportez-vous à ces sections avant de lire celle-ci (qui se trouve avant juste pour pouvoir l’atteindre plus rapidement lorsque l’on connait déjà l’application et que l’on a juste besoin de se rafraichir la mémoire.

    #### Définition des titre et auteur

    La première définition concernant le livre sera certainement son titre et son auteur\\(e) que nous ne pouvons pas définir par défaut. Pour ce faire, nous définissions les propriétés **`title`** ("titre" en anglais) et **`author`** ("auteur" en anglais) dans la section **`book_data`** ("données du livre" en anglais) de la recette du livre `recipe.yaml`.
    (( line ))
    ~~~yaml
    #./recipe.yaml
    book_data:
      title: "Le titre du livre"
      author: "Prénom NOM"
    ~~~
    (( line ))
    Notez que les noms se mettent avec capitales, pour que _PFB_ puisse les reconnaitre.

    #### Taille du livre

    La taille du livre doit être définie dans la recette du livre si elle est unique même dans une collection ou dans la recette de la collection si elle est commune à tous les livres de cette collection (ce qui est généralement le cas).
    On doit simplement définir les propriétés **`width`** ("largeur" en anglais) et **`height`** ("hauteur" en anglais) dans la section **`book_format`** ("format du livre" en anglais)

    #### Marges du livre

    #### Polices du livre


    EOT
end
