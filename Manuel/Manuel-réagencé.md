<style type="text/css">
.md-toc-h4 { display: none; }
.md-toc-h5 { display: none; }
.md-toc-h6 { display: none; }
</style>

# Manuel de Praw-4-book

[TOC]

<a name="programme"></a>

## LE PROGRAMME

### Introduction

***Prawn-for-book*** est le programme qui permet, à partir d’un [texte](#texte) formaté et d’une [recette](#recette) de produire un [livre](#livre), c’est-à-dire un fichier PDF prêt à être envoyé à l’imprimeur pour une impression professionnelle.

> Soyons tout de suite francs : après quelques petits réajustement inévitable, surtout si le livre est complexe.

### La commande `pfb`

La commande **`pfb`** (pour « Prawn For Book ») permet d’accomplir toutes les tâches du programme. Mais pour le moment, il faut pour ça *l’installer*.

{TODO}

### Les trois opérations de base à connaitre

Pour lancer la construction du PDF : 

~~~
$ pfb build
~~~

> « build » signifie « construire », en anglais

Pour ouvrir le fichier PDF :

~~~
$ pfb open
# Puis choisir "le livre PDF"
~~~

Pour ouvrir ce manuel :

~~~
$ pfb manuel
~~~



---

<a name="livre"></a>

## LE LIVRE

### Introduction

Ce que nous appelons *livre* ici correspond au *fichier PDF* qui sera produit par [le programme](#programme) et sera envoyé à l'imprimeur, avec la couverture (produite avec d'autres outils) pour produire le livre publié.

### Créer un nouveau livre

La création d’un nouveau livre avec ***Prawn-for-book*** consiste à :

* créer le dossier du livre,
* initier le dossier à l’aide de la commande **`pfb init`**,
* définir le [fichier recette](#recette) initié,
* rédiger le [fichier le texte](#texte) initié,
* jouer la commande **`pfb build`** pour lancer la construction du livre avec le texte fourni en respectant la recette défini.

### Initier un nouveau livre

Ouvrir un Terminal dans le dossier du livre et jouer la commande : 

~~~
$ pfb init
~~~

Suivez ensuite les opérations pour être accompagné(e) (ou non) dans le processus d’élaboration du livre.

### Initier une nouvelle collection

Ouvrir un Terminal dans le dossier de la collection, jouer la commande :

~~~
$ pfb init
~~~

Et choisir de faire une collection.

### Composer le livre

Rédiger le contenu du livre, appelé ici le [TEXTE](#texte), définissez la [RECETTE](#recette) qui devra lui être appliquée.

Si nécessaire, programme des [parseurs](#parsers), des [formateurs](#formaters) et des [helpers](#helpers) qui vous permettront de gagner beaucoup de temps et d’obtenir un rendu une homogénéité à toute épreuve.

### Produire le PDF du livre

Jouer la commande **`pfb build`** pour produire le fichier PDF prêt pour l’impression (avec, notamment, les polices embarquées et les couleurs définies au format imprimerie).

#### Les polices embarquées

Toutes les polices définies dans la recette sont embarquées dans le PDF final.

---

<a name="texte"></a>

## LE TEXTE

Quand on dit « le texte » ici, on pense au « texte du livre à produire » et particulièrement le texte codé qu’il faut produire pour obtenir, en combinaison avec [la recette](#recette) le livre désiré.

### Les paragraphes

#### Les paragraphes « stylés »

<a name="style-in-paragraph"></a>

#### Les styles dans des paragraphes [mode expert]

Alors que ci-dessus nous avons vu comment styliser tout un paragraphe, dans sa globalité (ce qu’on appellerait un « style de paragraphe » dans un traitement de texte classique), ici nous allons voir comment mettre en forme du texte à l’intérieur du paragraphe (ce qu’on appellerait un « style de caractère » dans un traitement de texte).

Le plus simple est d’utiliser la fonctionnalité des index (en coulisse). On définit une méthode (pour éviter les problèmes de collision, l’essayer avant de l’utiliser). Voilà la démarche : 

Choisir un nom de méthode, par exemple `ville`. L’essayer tout de suite avant de l’implémenter, pour éviter les collisions. Dans le [fichier texte](#texte), écrire : 

~~~
Je vis dans une ville qui s'appelle ville(Paris,75010).
~~~

Demander la fabrication du livre avec `$ pfb build`. Si ça produit une erreur, c’est parfait : la méthode n’existe pas. On peut l’implémenter, dans le ou un fichier `helpers.rb` à créer à la racine du dossier du livre.

~~~ruby
module PrawnHelpersMethods
	def ville(params)
		return params
	end
end
~~~

Noter que même s’il y a deux paramètres dans `ville(Paris, 75010)`, ces deux paramètres arrivent en « Array » dans la méthode ci-dessus. Pour séparer, le nom de la ville de son code postal, on utilise toujours la même fonction : 

~~~ruby
module PrawnHelpersMethods
	def ville(params)
		nom, codep = params
		return nom
	end
end
~~~

Maintenant que tout est en place, on peut mettre en forme nos villes. Par exemple en la mettant en police `ArialN` (qu’on aura [chargée dans la recette](#fonts-load)) et en italic.

~~~ruby
module PrawnHelpersMethods
  TEMP_VILLE = '<em><font name"ArialN"> \
											%{ville}</font></em>'
	def ville(params)
		nom, codep = params
		return TEMP_VILLE % {ville: nom}
	end
end
~~~



### Images

### Tables

<a name="sauts"></a>

### Sauts

Dans cette partie est abordé le problème des différents sauts, sauts de page principalement, pour se retrouver sur une page particulière (belle page ou page gauche) etc.

### Fichiers inclus

### Bibliographies

### Entête et pied de page

Les *entêtes* et *pieds de page* ne font pas à proprement parler partie du *texte du livre*. Ils sont traités en détail dans le [RECETTE](#headers-footers) du livre.

### Formaters, parsers et helpers de texte

Sous ces trois noms qui peuvent vous sembler barbares se cachent un puissant moyen de simplifier la rédaction du livre et de lui donner un aspect parfaitement homogène quel que soit son (grand) nombre de page. 

Cela donne également une grande souplesse à l’écriture, en permettant de modifier en profondeur un aspect, un affichage dans tout le livre en même temps et de le reporter même à plus tard.

Imaginons par exemple que vous ayez des noms de villes dans votre livre de voyage et que vous savez déjà que vous donnerez à ces noms de ville un aspect particulier à un moment ou à un autre, en tout cas pour la publication. Vous pouvez alors écrire votre texte de cette manière :

~~~markdown
Ceci est mon texte qui parle de ville(Paris) mais aussi de ville(Naples) ou de ville(Moscou).
~~~

Remarquez ci-dessus la balise `ville(...)`. Elle va permettre deux choses (au moins) : 1) de mettre en forme toutes les villes de la même manière et 2) de consigner toutes les villes citées dans le livre, en mémorisant même leur page et leur paragraphe. Pour la première utilisation, voir [l’exemple de style dans un paragraphe](#style-in-paragraph).

---

<a name="recette"></a>

## LA RECETTE

### Introduction

La *recette* est un fichier  'recipe.yaml' qui se trouve à la racine du dossier du livre ou de la collection. Elle définit [le livre](#livre) dans ses moindres détails et notamment comment devra être affiché [le texte](#texte).

### Produire la recette

### Éléments de la recette

#### Tailles du livre

<a name="fonts-load"></a>

#### Polices chargées

<a name="headers-footers"></a>

#### Pieds et entêtes de page

#### Aspects des paragraphes

#### Pagination



---

## ANNEXE

### Caractères spéciaux

Pour obtenir la liste complète des caractères spéciaux de la police « PictoPhil », jouer la commande `pfb pictophil`.

[RECETTE]:#recette

[RECETTE]: