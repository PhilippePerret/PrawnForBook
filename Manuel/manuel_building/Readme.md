# Manuel automatique


## Todo

* régler le problème de la définition d'une nouvelle fonte sur une ligne, qui doit affecter le paragraphe suivant, mais ce paragraphe suivant n'est pas trouvé, dans la construction automatique.
  * penser à documenter la fonctionnalité une fois qu'elle marchera
* Revoir le traitement des guillemets, qui pose problème (il a été désactivé). Le problème se pose avec les guillemets droits. En fait, il ne faudrait jamais les toucher lorsqu'il y a autre chose qu'une espace (sécable ou non) des deux côtés à la fois. Donc, dès qu'il y a une espace, on devrait le considérer comme un guillemet typographique, pas comme un guillemets de délimiteur de string dans un bout de programme ou dans des paramètres.



<a name="update-manual"></a>

## Actualisation du manuel

Le manuel de *Prawn-for-book* se construit — donc s’actualise — comme n’importe autre livre. Donc il suffit d’ouvrir un terminal à son dossier et de jouer la commande `pfb build`.

<a name="add-feature"></a>

## Ajouter une fonctionnalité

Une nouvelle fonctionnalité est un fichier à ajouter au dossier `manuel_building/Features` et une ligne à ajouter dans le fichier `manuel_building/prawn4book.rb` avec le nom (affixe) du fichier placé dans la liste des fonctionnalités. Il suffit ensuite [d’actualiser le manuel](#update-manual).



## Réflexions

Je voudrais réfléchir au moyen de produire un manuel comme *Prawn*.

En gros : une fonctionnalité est décrite, par exemple pour mettre en forme avec le pseudo-Markdown :

* un texte [String] explique la fonctionnalité
* un code peut être de la recette
* un code montre comme le produire
* le code est évalué pour produire la page de manuel ou l'extrait.



## Moyen

Faire une DSL et un fichier par fonctionnalité.

~~~ruby
Prawn4book::Feature.new do 
  
end
~~~



## Exemple code pour la recette

* Explication : le réglage de `show_grid` et `show_margins` dans la recette permet d’afficher les trucs

  * On ajoute aussi la précision qu’on peut obtenir le même résultat avec les options.

* Code recette : on montre ce qu’il faut écrire dans le fichier recette, c’est-à-dire :

  ~~~
  book_format:
  	text:
  		show_grid: true
  		show_margin: true
  ~~~

* code à jouer pour obtenir ce qu’on veut (là, le code n’est pas donner en exemple

  * Comme ce n’est pas un code exemple et que c’est un code recette, on va obtenir un code qui va être jouer de cette manière :

    ~~~ruby
    with_recipe(show_grid:true, show_margins:true) do
      pdf.update do
        start_new_page
        draw_grid(page_number)
        draw_margins(page_number)
      end
    end
    ~~~

  * Note : l’idéal, ça serait qu’on puisse entrer une recette (tout le code) dans l’application. Cela permettrait d’être sûr que l’exemple donné est valide (toujours dans l’idée que le manuel serve aussi de test.
