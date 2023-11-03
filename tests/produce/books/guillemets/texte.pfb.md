### Description
Le traitement des guillemets dans ***Prawn-For-Book*** est plutôt complexe puisqu’il permet d’unifier tous les guillemets dans le livre ou *les livres* s’il s’agit d’une collection et de les rendre typographiquement corrects.

### Règles appliquées
Ci-dessous sont présentées les règles appliquées.
* Tous les guillemets droits sont remplacés par des guillemets courbes ou des chevrons en fonction des préférences, sauf dans les codes HTML et les codes évalués.
* En cas de chevrons, on s’assure d’avoir des espaces insécables à l’intérieur.
* En cas de guillemets courbes, on s’assure d’avoir aucune espaces intérieures.

### Textes transformés
#### Avec chevrons

On commence par le traitement par défaut, les guillemets de tout type remplacés par des chevrons :
Paragraphe avec un "texte unique entre guillemets droit".
Paragraphe avec un " texte entre guillemets droits et espaces simples ".
Paragraphe avec un " texte entre guillemets droits et espaces insécables ".
Paragraphe avec un " texte entre guillemets droits et espaces simples et insécables ".
Paragraphe avec un “texte unique avec guillemets courbes”.
Paragraphe avec “ guillemets courbes et espaces simples ” (guillemets courbes et espaces simples).
Paragraphe avec “ guillemets courbes et espace simple à gauche” (guillemets courbes et espace simple à gauche).
Paragraphe avec “guillemets courbes et espace simple à droite ” (guillemets courbes et espace simple à droite).
Paragraphe avec “ guillemets courbes et double espaces insécables ”.
Paragraphe avec “ guillemets courbes et espace insécable gauche et espace simple droite”.
Paragraphe avec « chevrons et insécables» (rien à toucher).
Paragraphe avec «texte entre chevrons sans espaces».
Paragraphe avec « texte entre chevrons et espaces simples ».
Paragraphe avec « texte entre chevrons et espace simple à gauche, rien à droite».
Paragraphe avec «texte entre chevrons et espace simple à droite, rien à gauche».
Paragraphe avec «texte entre chevrons », espace insécable à droite, rien à gauche.
Paragraphe avec « texte entre chevrons», insécable à gauche, rien à droite.
Paragraphe avec “texte entre guillemets courbes” et un autre “texte entre courbes”.
Paragraphe avec “texte entre courbes”, "texte entre droits" et «texte entre chevrons».

#### Avec les guillemets courbes
Ici je joue un code qui permet de changer les préférences.  #{{{book.recipe.define_guillemets(:gc);"J’ai mis les guillemets :  #{book.recipe.guillemets.inspect}."}}}
Paragraphe avec «texte entre chevrons sans espaces» (chevrons sans espaces).
Paragraphe « texte entre chevrons avec espaces insécables » (chevrons et espaces insécables).
Paragraphe avec “texte entre courbe sans espaces” (courbes sans espaces).
Paragraphe avec “ texte entre courbes avec espaces ” (courbes avec espaces simples).
Paragraphe avec “ texte entre courbes avec espaces ” (courbes avec espaces insécables).
Paragraphe avec “ texte entre courbes avec espaces ” (courbes avec espaces insécables et simples).
Paragraphe avec "texte entre droits sans espaces" (droits sans espaces).
Paragraphe avec " texte entre droits et insécables " (droits et espaces insécables).
Paragraphe avec " texte entre droits et espaces simples " (droits et espaces simples).

#### Traitement des guillemets droits
Les guillemets droits doivent subir un traitement particulier puisqu’il ne doivent pas être transformés quand ils appartiennent à du code (ruby ou html). Pour le tester, on utilise du code ruby avec guillemets droits et du code HTML.
Dans ce paragraphe, j’ai un #{"code produit par ruby"} et même un #{"code produit par ruby avec du <color rgb=\"990000\">code HTML pour de la couleur</color>"} et sinon de la <color rgb="000099">couleur bleu</color> et un <font name="Numito" size="9">changement de fonte et de taille</font>.
Paragraphe seul avec <color rgb="000099">couleur bleu</color>.

Comme ça ne fonctionne pas^^, je vais faire progressif.
Dans ce paragraphe, j’ai un #{"code produit par ruby"}…
Dans ce paragraphe, j’ai un #{"code produit par ruby"} et même un #{"code produit par ruby avec du <color rgb=\"990000\">code HTML pour de la couleur</color>"} (**celui-là ne met pas la couleur**)…
Dans ce paragraphe, juste le #{"<color rgb=\"990000\">code HTML pour de la couleur</color>"}…
Dans ce paragraphe, j’ai un #{"code produit par ruby"} et même un #{"<color rgb=\"990000\">code HTML pour de la couleur</color>"}… (**celui-là ne fonctionne pas non plus — pas de couleur — avec deux blocs de code ruby)**
^^ Et c’est normal, cela vient du fait que les lignes sont découpées pour être traitées et qu’on perd donc une information qui passerait de l’une à l’autre. Donc : il faut absolument que j’adopte encore un autre traitement…
