Un texte au-dessus de la section en 2 colonnes avec des items.
(( colonnes(2) ))
Un premier item
Un deuxième item
Un troisième item
(( colonnes(1) ))
Un texte sous la partie en deux colonnes avec des items les uns sur les autres.

(( new_page ))

Un texte qui vient au-dessus de la section en trois colonnes.
(( colonnes(3) ))
(( {align: :left} ))
Un texte très très long pour qu’il tienne sur plusieurs colonnes. Pour voir comment le texte se répartira. Normalement, il ne devrait pas être justifié, mais aligné à gauche.
(( colonnes(1) ))
Un texte sous la partie en trois colonnes justifiée à gauche.

(( new_page ))

Un texte au-dessus de la section à deux colonnes.
(( colonnes(2) ))
(( {align: :center} ))
Ici, on devrait avoir un texte aligné au centre dans les deux colonnes qui ont été affectées à cette section.
(( colonnes(1) ))
Un texte sous la partie en deux colonnes justifiée au centre.

(( new_page ))
Un texte au-dessus de la section à deux colonnes avec changement d’alignement

(( colonnes(2) ))
Un premier paragraphe avec l’alignement par défaut, c’est-à-dire un texte justifié.
(( {align: :right }))
Le paragraphe suivant (celui-ci) est aligné à droite et il est de moyenne longueur.
(( {align: :left} ))
On passe ensuite, ici, à un paragraphe aligné à gauche de la même longueur à peu près.
(( {align: :center, size: 20, color: "FF0000"} ))
Ce paragraphe est plus différent, avec une taille de police et une couleur différente. Il est également plus long.
(( colonnes(1) ))
Ce paragraphe se trouve en dessous de la section à plusieurs colonnes. Il sert à s’assurer qu’il n’y a pas d’espace entre la section multi-colonne et le texte qui suit.

(( new_page ))
Ce paragraphe se trouve au-dessus d’une section à 3 colonnes qui est espacé de 2 lignes de cette section.
(( colonnes(3, {lines_before: 2, lines_after:4 }) ))
Une ligne
Une autre ligne
Une troisième ligne
(( colonnes(1) ))
Ce texte se trouve sous la section à 3 colonnes et à quatre lignes.