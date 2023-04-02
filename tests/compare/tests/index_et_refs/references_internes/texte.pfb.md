## Test des références internes
Ce livre permet de tester les références internes d'un livres (*note : une référence internet est le contraire d'une référence croisée*).
Ce livre permet aussi de tester les références croisées avec le livre “references_croisees”.
(( new_page ))
Ce paragraphe utilise une référence sur un simple mot(( <-(simple_mot) )).
(( new_page ))
### Un premier titre
Dans ce paragraphe, nous faisons référence au terme “référence ultérieure” qui n'est définie qu'à la (( ->(ref_ulterieure) ))
### Un titre référencé(( <-(titre_ref) ))
Ce titre, référencé, se trouve à la page trois. On y fait référence à la (( ->(ref_titre_ref) )).
(( new_page ))
Le simple mot se trouve à la (( ->(simple_mot) )) et ne se rencontre qu'une fois sur cette page mais on y fait appel aussi plus loin.
(( new_page ))
La simple mot ((( ->(simple_mot) ))) est une référence interne valide. On trouve aussi une référence au titre référencé ((( ->(titre_ref) ))).(( <-(ref_titre_ref) ))
(( new_page ))
Ici se trouve la “référence ultérieure”(( <-(ref_ulterieure) )). Pour traiter ce type de référence, il faut construire le livre deux fois. La première fois permet de localiser toutes les références (celle-ci par exemple) et la seconde permet de toutes les utiliser, même quand l'appel se trouve avant la définition.

(( new_page ))
C'est la fin du livre.
