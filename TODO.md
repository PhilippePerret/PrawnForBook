# Todo

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

Réflexion sur les indentations de paragraphe.

Principe : puisqu’il ne faut qu’une longueur, on va toujours calculer l’indentation avec la même police et la même taille. Il pourra y avoir des erreurs ponctuelles mais pour le moment, je ne vois pas laquelle. Cette indentation est calculée avant même la construction, dès la définition dans la recette, ou bien lorsqu’elle est changée par du pfb-code.
