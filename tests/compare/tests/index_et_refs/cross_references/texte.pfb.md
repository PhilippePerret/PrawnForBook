## Références croisées
Ce livre teste le bon fonctionnement des références internes (dans ce livre) et croisées (dans un autre livre).

### Rappel
Pour faire une référence croisée, il faut :

* que la bibliographie pour les livres (`livre`) soit bien définie,
* que le livre soit défini dans cette bibliographie,
* utiliser une balise de type `->(id_livre:cible)`.

*Note : ci-dessus, la liste doit être conservée malgré le double traitement du livre (il faut repartir du texte initial, pas du texte transformé la première fois.*
Ici une référence interne vers la (( ->(plus_loin) )) plus loin. La référence “avant” se trouve ici.(( <-(page_avant) ))
(( new_page ))
Sur cette page se trouve une référence croisée à la (( ->(cross_book:ref_titre_ref) )).
(( new_page ))
Ici se trouve la cible plus loin(( <-(plus_loin) )).
Ici une référence interne vers la (( ->(page_avant) )) qui se trouve avant.
