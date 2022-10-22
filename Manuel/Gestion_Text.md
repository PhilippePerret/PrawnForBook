# Prawn — Positionnement et dimensions des textes





| <span style="display:inline-block;width:5cm;">text</span>    | <span style="display:inline-block;min-width:5cm;">text_box</span> | <span style="display:inline-block;width:5cm;">bounding_text</span> | <span style="display:inline-block;width:5cm;">span</span> | <span style="display:inline-block;width:5cm;">draw_text</span> |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | --------------------------------------------------------- | ------------------------------------------------------------ |
| Suit le flux courant. Le curseur se place en dessous du dernier texte. Crée de nouvelles pages si nécessaire. | Se positionne où l’on veut. Respecte le flux du texte. Crée de nouvelles pages si nécessaire. | Se positionne où l’on veut, mais ne passe pas à la page suivante | Positionnement de type colonnes, dans le flux             | Ne respecte pas le flux. Si le texte dépasse, il dépasse. Bon pour positionnement précis de textes courts |
| **Syntaxe**                                                  |                                                              |                                                              |                                                           |                                                              |
| `text texte, options`                                        | `text_box texte, options`                                    | `bounding_text`                                              | `span(width, options)`                                    | `draw_text texte, options`                                   |
| **Options**                                                  | -------------                                                | -------------                                                | -------------                                             |                                                              |
| **`inline_format`** Si true, formate les balises à l’intérieur du texte |                                                              |                                                              | `:position` => :center, :left, :right ou valeur x         | **`:at`** : point [y, x]                                     |
| **`:align`** Alignement (:left, :right, :center)             | **`:width`** et **`:height`** : largeur et hauteur du bloc   | **`:width`** et **`:height`** : largeur et hauteur du bloc   |                                                           |                                                              |
| **`leading`** : montant additionnel entre les lignes         |                                                              |                                                              |                                                           |                                                              |
| **`kerning`** : si true, traite les ligatures                |                                                              |                                                              |                                                           |                                                              |
| **`size`** : taille du texte (de la fonte) en nombre de points |                                                              |                                                              |                                                           |                                                              |
| **`color`** : couleur (hexa sans “#”) du texte               |                                                              |                                                              |                                                           |                                                              |
| **`final_gap`** : si true, l’espace entre chaque ligne est inclus en dessous de la dernière ligne (?) |                                                              |                                                              |                                                           |                                                              |
| **`character_spacing`** : espacement entre les lettres       |                                                              |                                                              |                                                           |                                                              |
| **`style`** : style de la fonte, en fonction de sa définition (`:normal`, `:italic`, etc.) |                                                              |                                                              |                                                           |                                                              |
| **`:valign`** : alignement vertical                          | **:align** : alignement horizontal                           |                                                              |                                                           | PAS D’ALIGNEMENT                                             |
| **`indent_paragraphs`** : montant de l’indentation           |                                                              |                                                              |                                                           |                                                              |
| **`:mode`** : si `:stroke` le texte est mis en gras (forcé en tout cas) |                                                              |                                                              |                                                           |                                                              |
| **`direction`**                                              |                                                              |                                                              |                                                           |                                                              |
| **Définition du texte**                                      |                                                              |                                                              |                                                           |                                                              |
|                                                              |                                                              |                                                              | Définit le texte dans son bloc (avec `text`)              |                                                              |
|                                                              |                                                              |                                                              |                                                           |                                                              |
|                                                              |                                                              |                                                              |                                                           |                                                              |
| **Placement**                                                |                                                              |                                                              |                                                           |                                                              |
| --- (dans le flux pour la hauteur)                           |                                                              |                                                              | move_cursor_to y                                          |                                                              |
| Après l’écriture du texte, le `cursor` se place sous le texte, au bord de la marge gauche. |                                                              |                                                              |                                                           |                                                              |



## Notes

Penser à utiliser **`bounds.<prop>`** pour position et dimensionner les choses. Par exemple **`width: bounds.width`** pour mettre la largeur à la dimension de la page, ou encore **`at: [bounds.right - 200, cursor], width: 200`** pour positionner à droite, contre la marge droite, une boite de 200 unités.



## Mouvement du curseur

Cf. `pad`, `pad_top`, `pad_bottom` et `float` à la page 7 du manuel.

### `move_down`, `move_up`

Quand on utilise ces méthodes, elles ajoutent ou retranchent leur valeur à la position courante.

Par exemple, avec :

~~~ruby
font 'Garamond', 11
# la hauteur de ligne sera de 13.2

text "Un texte en haut" # par exemple 462
# Ici, on se trouve à 462 - 13.2 = 448.8
move_down(10)
# On descend de 10 unités, on se retrouve donc à :
# 448.8 - 10 = 438.8
text "Texte à 438.8"
~~~

