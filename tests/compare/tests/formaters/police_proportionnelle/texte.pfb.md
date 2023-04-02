## Traitement des polices proportionnelles
Ce test s'assure que les polices proportionnelles s'appliquent bien partout, qu'elles soient "naturelles" ou pas.
Elles doivent l'être pour un mot formaté dans le formatage de paragraphe propre au livre (#__paragraph_parser de parser.rb).
Elles doivent l'être pour un traitement qui appelle #parser_formater dans parser.rb directement (une table ?)
### Changement de taille
(( {font_size: 20} ))
Ce texte est en taille 20 et mot(ce mot) doit l'être aussi.
(( {font_size: 8} ))
Ce texte est en taille 8 et mot(ce mot) doit l'être aussi.
(( {font_size: nil} ))
Ce texte est en taille normale et mot(ce mot) doit l'être aussi.

### Kerning (espacement caractères)
Le kerning/espacement de lettres s'applique bien à un mot formaté, sans avoir à faire quoi que ce soit.
Les deux paragraphes ci-dessous ont un character-spacing de 5, mais le premier a kerning à true et l'autre à false.
(( {font_size: 8, character_spacing: 5, kerning: true} ))
Un texte avec un spacing de 5 qui s'applique aussi à mot(ce mot) sans fl avoir rien à faire.
(( {font_size: 8, character_spacing: 5, kerning: false} ))
Un texte avec un spacing de 5 qui s'applique aussi à mot(ce mot) sans fl avoir rien à faire.

### Styles
Les styles italiques, gras et soulignés doivent s'appliquer normalement.
*Un texte en italique avec mot(ce mot).*
**Un texte en gras avec mot(ce mot).**
__Un texte souligné avec mot(ce mot) également.__

### Dans une table
Le comportement est le même à l'intérieur d'une table.
| mot(Ce mot) est dans une table | A2 |
| B1 | **On trouve aussi mot(le mot) ici en gras** |

### Dans une liste
Le comportement est le même dans une liste.
* Ceci est mot(le mot) dans un autre style.
* *Un deuxième item en italique avec mot(ce mot) pour voir.*
Fin du texte.

### Dans une citation
> Ceci est une citation en taille normale avec mot(le mot) utilisé.
(( {font_size: 18} ))
> Ceci est une citation en taille 18 avec mot(le mot) utilisé.
