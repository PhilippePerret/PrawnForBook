# Todo

* Voir si les commentaires entre `<!-- -->` sont supprimés. En profiter peut-être pour trouver une autre marque plus facile : 
`((# Commentaire ))` et :

```
((#
Un commentaire multilignes.
#))
```
-> Documenter
* Voir comment faire des traits d'union insécable (pour que les diminutifs ne soient pas coupés en fin de ligne =  `&#8209;`) -> Documenter. Se souvenir que les traits d'union conditionnels se marquent `{-}` (vérifier). Insécable pourrait être `[-]`

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


## Refactorisation complète de l'application

L'application est tellement compliquée qu'on n'y voit plus rien et que ça devient infernal de la faire évoluer. Il faut la réorganiser.

Les grands groupes

* **RECETTE**. Tout ce qui appartient à la recette du livre, à commencer par les données explicites et les données par défaut.
* **ERREUR**. Un grand gestionnaire d'erreurs qui permettra de les donner en directe, mais aussi de les mémoriser pour les mettre à la fin. Avec des modes comme 'sans erreur' (le programme va jusqu'au bout quel que soit ce qui se passe) jusqu'à des modes 'fail fast' (le programme échoue à la première erreur)
* **PARSERS**. Un grand groupe des parseurs qui étude dans un tout premier temps tous les paragraphes sans autre but que de les relever. Ils peuvent être de toute nature, voir PARAGRAPHS
* **FORMATERS**. Le grand groupe des formateurs qui s'occupe de formater tous les paragraphes pour les préparer à la gravure, mais aussi les tables, les listes, les images, tous les paragraphes regroupés, donc.
* **PARAGRAPHS**. Un grand groupe qui s'occupe des paragraphes. Ils sont consignés dans l'ordre, mais on trouve ici aussi tout ce qui les formate, les met en forme.
* **GRAVEUR**. Peut être dans **livre**, un module/groupe qui s'occupe de tout ce qui est gravage du livre.
* **LIVRE**. Le grand groupe qui regroupe tout ce qui concerne le livre (mais la recette n'en fait pas partie ?… Si, peut-être, mais ça n'empêche rien)