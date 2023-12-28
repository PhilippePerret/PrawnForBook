# Todo

## Maintenant

Reprise de tous les éléments un par un en construisant le manuel de façon automatisé avec l’application elle-même.

Voir `ghi`

* Pour les non experts, avec le style de formatage "citation::<texte>", il faudrait pouvoir faire quelque chose comme :

  ~~~ruby
    return <<~PFB.strip
      (( {size: 24, left: '20mm', lines_after: 2, space_before:10} ))
      #{str}
      PFB
  ~~~

  … qui ressemblerait à l’écriture normale. Bien sûr, il faudrait pouvoir tout utiliser dans le pfb-code, c’est-à-dire même des `lines_before` et `lines_after` par exemple.

  Note : ci-dessus, le *space_before*, qui ne se justifie pas en terme de texte, est utilisé par exemple si c’est une image qu’il faut placer.

## Réflexion

### Réflexion sur les multi-colonnes

Il faudrait là aussi faire un traitement à part de Prawn pour pouvoir ajouter des fonctionnalités :
* le reflow_margin à true par défaut (quand on passe à la page suivante, on repart automatiquement en haut de page)
* le calcul automatique de la hauteur des multi-colonnes en fonction du contenu, pour prendre toujours le moins de place possible, au lieu d’aller toujours au bout de la page comme le fait Prawn de base

Pour ce faire, on crée une nouvelle instance `Prawn::MultiColumns`

Principe adopté : 
1. On calcule la hauteur obtenue avec le nombre de colonnes voulues, et la gouttière, dans l’absolu, en fonction du texte donné.
2. On regarde la place restante en bas de la page et l’on crée les premières colonnes (peut-être qu’elles suffiront si la place suffit)
3. S’il y a un excédent, on passe à l’autre page et l’on poursuit la même chose, jusqu’à ce que tout le texte soit traité.
