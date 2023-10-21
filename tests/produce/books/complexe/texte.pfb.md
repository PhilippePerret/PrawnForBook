# Complexité testée
Ce livre doit permettre de tester énormément de choses dans le détail. Grâce à l’affichage (par la recette) de la grille de référence, on peut voir dans le livre produit le résultat. Il va y avoir beaucoup de changements de fontes et de tailles (elles sont toutes définies dans le fichier recette).

(( {font:"Helvetica", style: :italic, size: 23} ))
Ce texte est écrit dans la police “Helvetica” en taille 23 et style italique (c’est une ligne de pfbcode qui le détermine juste au-dessus). Elle doit juste s’adapter aux lignes de références qui sont placées dans cette partie (par défaut) avec une hauteur de ligne de 24 points.

(( {font:"Times-Roman", size: 12} ))
On poursuit avec un texte en police “Times-Roman” en taille 12 et style romain. De la même manière, ce texte est assez long pour pouvoir se placer sur plusieurs lignes, afin de voir si le traitement par ligne fonctionne correctement et que le texte se place bien et naturellement sur les lignes de référence tracées.

Un paragraphe dans la police normale, mais avec des *textes en italiques*, des **textes en gras** et __des textes soulignés__. Il possède aussi un 1^er exposant et une 1^re ré-utilisation d’exposant ainsi qu’une note^1 qui doit être placée en dessous du paragraphe, dans un style un peu différent.
^1 C’est le commentaire de la note qui a été placée plus haut, qu’on doit correctement formater en fonction des choix dans le livre de recette {{Cette définition doit être ajoutée}}

# Tests restant à faire

* Traitement du formatage pseudo-markdown
* Traitement des veuves
* Traitement des orphelines
* Traitement des lignes de voleur
* La modification du THIEF_LINE_WIDTH à la volée, pour pouvoir modifier localement la longueur d’une ligne de voleur. On doit pouvoir aussi le faire dans la recette (autre test ?)
* Penser à ajouter la définition de l’aspect des notes dans la recette (manuel). Ajouter les valeurs par défaut dans RECIPE DEFAULT.
