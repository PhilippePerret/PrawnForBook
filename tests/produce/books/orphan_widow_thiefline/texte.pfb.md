Ce livre est pensé, à la base, pour voir comment on peut traiter la longueur des paragraphes en nombre de lignes pour pouvoir gérer les `veuves`, les `orphelines` et les `lignes de voleur qui trainent`. À partir d’un paragraphe comme celui-ci, il faut pouvoir déterminer le *nombre de lignes* et extraire la dernière ligne pour pouvoir gérer les choses. Les principes sont les suivants. Ce <color rgb="990000">texte contient volontairement des balises car elles jouent dans la réussite du découpage — j’allonge pour produire une ligne de voleur</color>.
* Si un paragraphe entier tient dans la page (pas d’excédent), il faut juste tester sa dernière ligne.
* Si la dernière ligne d’un paragraphe est une ligne de voleur, il faut jouer sur le `character_spacing` pour régler le problème et faire remonter mot (ou en faire descendre un si la réduction est trop importante — ce paragraphe possède aussi une ligne de voleur).
(( move_to_line(-1) ))
* Ce paragraphe à puce devrait se marquer sur la der#{-}nière ligne mais comme il est trop long et qu’il créerait une orpheline, on le passe à la page suivante.
(( move_to_line(21) ))
Ce paragraphe avec des styles se trouve `sur la troisième` ligne avant la fin, et *fait cinq lignes*, ce qui signifie qu’il n’y a pas de veuve `sur l’autre page`. Mais elle est <color rgb="FF0000">corrigée **automatiquement**</color> par le programme pour passer à la page suivante.
(( move_to_line(21) ))
Ce paragraphe avec des styles se trouve aussi sur la 3^e ligne avant la fin et *fait 4 lignes*, ce qui <color rgb="0000FF">signifie qu’il y aura/ait</color> ici une veuve sur l’autre page ***si on ne faisait** rien*.
(( new_page ))
Voleur
Le paragraphe précédent ne contient que le mot “voleur”, donc un ligne qui devrait être prise pour une ligne de voleur, mais on considère que c’est une phrase seule.
