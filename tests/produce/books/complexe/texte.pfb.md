# Complexité testée

## Présentation
Ce livre doit permettre de tester énormément de choses dans le détail. Grâce à l’affichage (par la recette) de la grille de référence(( <-(grille_reference) )), on peut voir dans le livre produit le résultat (cette phrase possède une référence “grille_reference”). Il va y avoir beaucoup de changements de fontes et de tailles (elles sont toutes définies dans le fichier recette). La page de reference_ulterieure est (( ->(reference_ulterieure) ))

## Premiers tests
(( {font:"Helvetica", style: :italic, size: 21} ))
Ce texte est écrit dans la police “Helvetica” en taille 21 et style italique (c’est une ligne de pfbcode qui le détermine juste au-dessus). Elle doit juste s’adapter aux lignes de références qui sont placées dans cette partie (par défaut) avec une hauteur de ligne de 24 points.

(( {font:"Times-Roman", size: 8} ))
On poursuit avec un texte en police “Times-Roman” en taille 12 et style romain. De la même manière, ce texte est assez long pour pouvoir se placer sur plusieurs lignes, afin de voir si le traitement par ligne fonctionne correctement et que le texte se place bien et naturellement sur les lignes de référence tracées.

Un paragraphe dans la police normale, mais avec des *textes en italiques*, des **textes en gras** et __des textes soulignés__. Il possède aussi un 1^er exposant et une 1^re ré-utilisation d’exposant ainsi qu’une note sur première^^ qui doit être placée en dessous du paragraphe, dans un style un peu différent et une autre note sur deuxième^^.
^^ C’est le commentaire de la note sur “première” qui a été placée plus haut, qu’on doit correctement formater en fonction des choix dans le livre de recette.
^^ Et le commentaire sur la note “deuxième” qui doit être bien numérotée en deuxième justement.
Un paragraphe juste en dessous de la note pour voir s’il serait bien placé sous le trait et non pas dessus ce qui serait inélégant.

# Paragraphes avec formatage personnalisé
simplenote::Un premier paragraphe de style “simplenote” qui se caractérise par une puce “pictophil” (lettre “n”) placée au bon endroit en décalant le texte qui sera toujours bien placé.
simplenote::Une autre simple note pour voir si les caractères qui ne s’affichent pas vont s’afficher cette fois avec une ligne inférieure (en fait le problème vient de `.otf`).
notedocu::Une note pour de la documentation.

# Tests restant à faire

* Traitement du formatage pseudo-markdown
* Traitement des veuves
* Traitement des orphelines
* Traitement des lignes de voleur
* La modification du THIEF_LINE_WIDTH à la volée, pour pouvoir modifier localement la longueur d’une ligne de voleur. On doit pouvoir aussi le faire dans la recette (autre test ?)
* Penser à ajouter la définition de l’aspect des notes dans la recette (manuel). Ajouter les valeurs par défaut dans RECIPE DEFAULT.
* Ajouter la page d’infos, avec toutes les infos (l’idée est qu’il y ait plus d’infos que de lignes, pour voir comment on va s’y prendre => doubler les lignes et mettre les caractères plus petits pour s’adapter.
* Utiliser les § (caplock §) pour désigner le numéro du paragraphe dans la numérotation hybride.

# Bogues à corriger / implémenter

* Le tiret des items de list doivent avoir la fonte du texte (voir le premier qui prend la fonte du titre)
* Plus grave, les tirets d’item de liste ne doivent être mis que lorsque l’on sait où va se retrouver le paragraphe. S’il doit passer à la ligne, le tiret doit lui aussi passer à la ligne
* La largeur de l’item de liste doit être amputée du décalage left (pour le moment, il est normalement réglé (avec `margin-left`, mais le programme n’en tient aucun compte)

# Choses à implémenter
* Gestion des références (avant et arrière). Pour le moment, les références ultérieures ont été remplacées par un “ticket de poissonnerie”, il faut maintenant faire le second tour, en ne corrigeant plus les textes et en recherchant juste les tickets de poissonnerie pour les remplacer par
* Marques de références : il faut faire quelque chose de moins impératif, qui permette de faire aussi bien “(page 56)” que “p. 56”. Donc, ici par exemple, ne renvoyer que 56.

# Réflexions

## Second tour
Pour le second tour, on n’a absolument pas besoin de repartir du texte. On va plutôt repartir de tous les paragraphes, et modifier les références puisque normalement c’est la seule chose qui nécessite ce second tour (on a un troisième tour avec les définitions du scénodico, mais c’est un tout autre problème qui sera résolu).
Ici se trouve la référence à reference_ulterieure(( <-(reference_ulterieure) )). La première allusion à “grille de référence” se trouve (( ->(grille_reference) )).
C’est en fait les corrections faites par `AnyParagraph.__parse` qui sont conservées.
