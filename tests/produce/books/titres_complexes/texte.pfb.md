(( new_page ))
# Tipre niveau 1
## Tipre de niveau 2
### Tipre de niveau 3
Et un premier paragraphe. Ci-dessus, on doit avoir le premier titre sur la deuxième ligne et les deux titres suivants séparés chacune d’une seule ligne. En effet, les valeurs ont été réglées à :
`lines_before: 1` 
`lines_after: 0`
(( new_page ))
## Titrep niveau 2
Ce titre de niveau 2 doit être placé sur la deuxième ligne.
(( new_page ))
### Titrep niveau 3
Ce titre de niveau 3 doit être placé sur la première ligne puisque la taille n’excède pas la hauteur de ligne de #{pdf.line_height}.
(( new_page ))
#### Titrep niveau 4
Ce titre de niveau 4 doit être placé sur la première ligne.
(( recipe(format_titles:{level3:{lines_after:4},level4:{lines_before:4}}) ))
(( new_page ))
À partir d’ici, la recette a été modifiée (à la volée) pour modifier les `lines_after` et `lines_before` afin de proposer une présentation différente. Concrètement :
* Le `lines_after` du niveau de titre 3 a été mis à 4 et le `lines_before` du titre de niveau 4 a été mis à 3.
(( new_page ))
Lorsque le titre 4 suit le titre 3, on ne doit pas ajouter les `lines_after` et les `lines_before`. Il doit y avoir seulement 4 lignes entre les deux titres.
### Titrep de niveau 3
#### Titrip de niveau 4
Il doit y avoir seulement 4 lignes entre les deux titres.
(( recipe(format_titles:{level3:{lines_after:6}, level4:{lines_before:3, lines_after:3}}) ))
(( new_page ))
Ici, on a réglé le nombre de lignes après un titre de niveau 3 à 6 et le nombre de lignes après un titre de niveau 4 à 3. Pourtant, ci-dessous, il n’y aura pas 9 lignes entre les deux titres (l’addition) mais seulement 6 (la plus grande valeur).
### Titrep de niveau 3
#### Titrep de niveau 4
Et trois lignes après le titre de niveau 4, aussi.
(( recipe(format_titles:{level3:{lines_after:3}, level4:{lines_before:6, lines_after:3}}) ))
(( new_page ))
Ici, on a fait l’inverse, c’est-à-dire qu’on a mis 3 lignes après le titre de niveau 3 et 6 lignes *avant* le titre de niveau 4. Donc il faudra ajouter 3 lignes avant le titre de niveau 4 pour obtenir le bon nombre.
### Titre de niveau 3
Un texte à trois lignes du niveau 3.
### Autre de niveau 3
#### Titre de niveau 4
Un texte ensuite, trois lignes plus bas.
(( recipe(format_titles:{level3:{lines_after:6}}) ))
(( new_page ))
Ici est présenté le problème du titre trop bas. Nous avons réglé le titre 3 pour qu’il laisse 6 lignes après lui, mais il n’y en a que 6 dans la page. Comme le calcul est fait sur 8 lignes (les 6 provenant du `lines_after` du titre 3 + 2 lignes pour écrire le texte.
  Le preier titre ci-dessous en encore assez haut, mais le titre sur la page suivante doit passer à la page suivante.
(( move_to_line(-10) ))
### Titre de niveau 3
Le texte qui suit directement le titre de niveau 3 et qui fait deux lignes pour voir.
(( new_page ))
Ci-dessous, il devrait y avoir le titre de niveau 3, mais il a été passé à la page suivante à cause de l’espace manquant (note : pour provoquer l’erreur, nous avons demandé à poser le titre ci-dessous sur la 5^e ligne avant la fin de cette page grâce au code `\((  move_to_line(-5) ))`).
(( move_to_line(-5) ))
### Titre de niveau 3
Le texte qui le suit.
