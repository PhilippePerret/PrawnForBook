# Dossier `lib/pages`

Ce dossier contient tout ce qui est nécessaire pour gérer une page spéciale en particulier, à commencer par la page de titre du livre ou la table des matières.

Chaque dossier contient au moins 3 modules :

- 'build' pour la construction de la page (utilisé par le constructeur du livre),
- 'define' pour la définition de la page (utilisé par l'assistant et par l'intiateur de livre),
- 'data' pour la gestion des données (dans le fichier recette) et notamment les valeurs par défaut.

## Convention

Par convention, le nom de la classe (pe `PageDeTitre`) doit être choisi avec attention car il correspond à plusieurs choses capitales :

- nombre du tag de repérage dans le fichier recette (`# <page_de_titre>` et `# </page_de_titre>`),
- nom de la donnée dans la recette : `:page_de_titre`

Cela permet, en choisissant bien son nom de classe, de tout définir en même temps.
