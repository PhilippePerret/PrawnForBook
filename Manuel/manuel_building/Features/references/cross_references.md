#### Lexique
Pour bien comprendre de quoi nous parlons, nous nommons les choses de façon stricte :
* la **cible** (ou **cible de la référence**), c’est l’endroit du livre auquel nous faisons référence (il se marque par `\\<-(id_ref)`), 
* l’**appel** (ou **appel de la référence)**, c’est la marque qui permet, dans le code-texte du livre, de faire référence à un autre endroit du livre (il ressemble à `\\->(id_ref)`,
* la **marque** (ou **marque de la référence**), c’est le texte précis qui remplacera l’*appel* et qui sera donc lu dans le livre imprimé,
* l’**endroit** (ou **endroit de la référence**), c’est précisément la page, le paragraphe ou la page et le paragraphe où se trouve la *cible*.

#### Définition
Les *références croisées* permettent de faire référence, dans un livre, à une autre partie du livre ou même, avec _PFB_, à une partie d’un autre livre. Typiquement, c’est le "cf. page 12" qu’on trouve dans un ouvrage.
Les *références croisées* fonctionne à partir d’une *cible*, la partie du livre à rejoindre, et d’un *lien* vers cette cible.

#### Format de la marque

Dans _PFB_, la *marque de la référence* peut s’imprimer de différentes manière. Par défaut, elle pourra avoir trois aspects qui dépendront du type de numérotation défini, à savoir :

* le numéro de page (par exemple `page 12`,
* le numéro de paragraphe (par exemple `§ 123`),
* le format *hybride* avec numéro de page et de paragraphe (par exemple `p 12 § 123`).

Il est cependant possible de définir de façon précise et différente la *marque* en utilisant un *appel* de la forme :

\\->(id_ref|"<le texte de la marque>")

Par exemple :

C'est un texte avec une \\->(mon_chapitre|référence croisée) qui sera titrée.

Produira :

C'est un texte avec une référence croisée (page 12) qui sera titrée.

Dans cette formule, l’*endroit* sera toujours spécifié entre parenthèse après le texte donné. On peut cependant aller plus loin encore et définir très précisément l’aspect d’une référence particulière :

(utiliser la marque "_ref_" pour indiquer où doit se marquer "page 12" ou "p. 123 § 12")
\\->(id_ref|(_ref_) <le texte>)

Par exemple :

C'est un texte avec une \\->(mon_chapitre|(_ref_) référence croisée) qui sera personnalisée.

Produira :

C'est un texte avec une (page 12) référence croisée qui sera personnalisée.

Mais on peut aussi le définir de façon très précise avec `_page_` et `_paragraph_`


