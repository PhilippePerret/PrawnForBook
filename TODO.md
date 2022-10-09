# Todo

* Placement des numéros de paragraphes en footer
  - au cours de la construction du document, il faut relever le premier et le dernier paragraphe de chaque page. Pour ce faire, on tient à jour une propriété pdfbook.pages qui va comprendre en clé l'indice de la page et en valeur les données de la page
  À chaque changement de page :
    - on enregistre dans la nouvelle page le numéro suivant
    - on enregistre dans la page précédente le numéro courant
  Note : voir si le numéro de paragraphe est "exposé", ce qui n'est
  pas sûr du tout (le mettre dans pdfbook, au cas où)

* Voir comment traiter la première page (pour le moment, elle ne se traite pas comme les autres)

* Les unités doivent être ajoutées, avec l'assistant d'init.

* Bien calculer les marges/header/footer (cf. le manuel pour voir comment ils sont définis)

* Pouvoir créer/enregistrer une collection
* Command qui permet d'ouvrir le fichier de recette du livre
* Prendre les données enregistrées pour en tenir compte lors de la génération du book PDF.
* Entête et Pied de page
   => une class propre, qui génèrera des données YAML qu'on pourra enregistrer dans le fichier recette
* Il faudra faire des propriétés propres à chaque style de paragraphe, par exemple des "note" pourraient être de différents styles qu'on doit pouvoir spécifier. 
  => documenter
* Ajuster les positions des titres
  -> pouvoir les définir dans le fichier recette du livre (ou de la collection)
* Régler les numéros de pages ou de paragraphes en bas de page
* pouvoir gérer les orphelines et les veuves
  - Voir les propriétés de Prawn que je n'ai pas encore découverte ou exploitées.
* PROPRIÉTÉS PROPRES AUX PARAGRAPHES
  - kerning (?) espacement entre les lettres
  - passage à la page suivante
  - margin différente avec le paragraphe au-dessus (en restant — ou pas — sur la ligne de base de la grille)

* récupérer les mots à indexer
  - comment en faire une généralité ? Faut-il pouvoir indiquer le style des mots qu'il faut conserver. Par exemple, ici, ce seront les mots repérés par 'mot:...' ou 'mot(...)' ou 'MOT[...]'.

* produire une table des matières

* mettre en forme les mots spéciaux (titre de film, mot technique, etc)
  => Définition dans la recette du livre
  => Documenter

* un titre ne doit jamais se retrouver seul en bas de la page précédente

* réfléchir au fonctionnement de l'index : est-ce que je balise les termes à indexer dans le texte ou je fonctionne plutôt avec une expression régulière définissant les différentes formules qui correspondent à un mot, et le programme trouve lui-même les mots en analysant les paragraphes (et les titres) ?
-> possibilité de rechercher toutes les itérations d'un mot indexé (ou pas) et de lister les paragraphes où on le trouve.
-> possibilité de sortir le texte (en HTML) avec le numéro des paragraphes, même lorsqu'il n'est pas utilisé dans les pages comme ça (pour pouvoir faire des recherches faciles)

* possibilité de sortir le livre seulement jusqu'à une certaine page

* pouvoir définir l'aspect de la table des matières
  -> Une classe NTdm
  -> Dont on peut enregistrer les données soit dans le livre recette du livre ou de la collection

* [NARRATION] prévoir une filmographie (liste de tous les films utilisés dans le livre)

* Pouvoir choisir une fonte dans les 3 endroits où on les trouve
  - si ce n'est pas une fonte ttf, dire quoi faire


# à vérifier pour être sûr d'utiliser Prawn
  (pour le moment, tout se passe bien, le livre semble avoir pu être imprimé…)

* est-ce aligner sur la grille ?
* est-ce que les polices sont vraiment empaquetées ?
  -> test sur KDP
* est-ce que les images sont au bon mode (:cmkj je sais pas quoi)
  -> test sur KDP
* est-ce qu'on peut mettre du style (italic, gras)
  -> oui, tester sur KDP
* est-ce qu'on peut changer de caractère au cours du texte ?
  -> oui, tester sur KDP

