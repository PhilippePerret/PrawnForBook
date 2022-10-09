# Prawn4book<br />Manuel



[TOC]

**Prawn4book** est une application en ligne de commande permettant de transformer un texte en PDF prêt pour l’impression, grâce au (lovely) gem `Prawn`.

Tous les exemples de ce manuel présupposent qu’un alias de la commande a été créé, grâce à :

~~~bash
> ln -s /Users/me/Programmes/Prawn4book/prawn4book.rb /usr/local/bin/prawn-for-book
~~~

> Noter ci-dessus que la commande sera `prawn-for-book` (qui est plus simple à taper)

---

## Pages du livre

### Les marges

Les marges sont définies de façon très strictes et concernent vraiment la partie de la page ***où ne sera rien écrit***, ni pied de page ni entête. On peut représenter les choses ainsi :

~~~
				
					v------ marge gauche (ou intérieure)
					___________________________
				|		|			
Mtop 	 -|   |
				|	__|________________________
Header -|   |	 Titre du livre
				|	__|_________________________
            |
            | 23  Le 23e paragraphe
            | 24  Un autre paragraphe
            | ...
            |
          __|___________________________
Footer  -|  | p. 42
				 |__|___________________________
				 |
Mg Bot  -|
				 |________________________________________________
				 
~~~

Ce qui signifie que le haut et le bas du texte sont calculés en fonction des marges et des header et footer.

---

## Les paragraphes

---

<a name="types-paragraphes"></a>

### Les différents types de paragraphe

~~~
Simple paragraphe

		Définit dans le texte par un texte ne répondant pas aux critères 
		suivants. Un paragraphe peut commencer par autant de balises que
		nécessaire pour spécifier les choses. Par exemple :
		citation:bold:center: Une citation qui doit être centrée.
		
image

		Définit dans le texte par 'IMAGE[<data>]'
		Comme pour les simples paragraphes elle peut être précédée par des 
		étiquettes de définition.
		
titre
		Définit dans le texte par '#[#[#]] Titre'
		
~~~

### Formatage personnalisé des paragraphes (`module_formatage.rb`)

Le principe est le suivant : 

~~~
SI un paragraphe commence par une balise (un mot suivi sans espace par ':')
		par exemple : "custag: Le texte du paragraphe."

ALORS ce paragraphe sera mis en forme à l'aide d'une méthode de nom :

		formate_<nom balise>
		
		par exemple : def formate_custag(string)

QUI SERA DÉFINIE dans le fichier 'module_formatage.rb' définissant le module 'PdfBookFormatageModule'
~~~

~~~ruby
module PdfBookFormatageModule
	def	formate_custag(string)
		# ...
		return string_formated
	end
end
~~~

---

## Recette du livre

### Création de la recette du livre

On peut créer de façon assistée la recette d'un livre en ouvrant un Terminal dans le dossier où doit être initié le livre — ou le dossier où se trouve déjà le texte, appelé `texte.txt` ou `texte.md` — et en  jouant la commande : **`> prawn-for-book init`**.

Cette commande permet de créer un fichier `recipe.yaml` contenant la recette du livre.

### Définition des fonts

~~~yaml

:fonts:
	<nom utilisé>
		:<style>: "/path/to/font.tff"
		:<style>: "/path/to/font.tff"

# etc.
~~~

Par exemple :

~~~yaml
# ...
dossier_fonts: &dosfonts "/Users/philippeperret/Library/Fonts"
:fonts:
  Garamond:
    :normal: "*dosfonts/ITC - ITC Garamond Std Light Condensed.ttf"
    :italic: "/Users/philippeperret/Library/Fonts/ITC - ITC Garamond Std Light Condensed Italic.ttf"
  Bangla:
    :normal: "/System/Library/Fonts/Supplemental/Bangla MN.ttc"
    :bold:   "/System/Library/Fonts/Supplemental/Bangla MN.ttc"
  Avenir:
    :normal: "/System/Library/Fonts/Avenir Next Condensed.ttc"
  Arial:
    :normal: "/Users/philippeperret/Library/Fonts/Arial Narrow.ttf"

~~~



---

<a name="header-footer"></a>

## Entête et pied de page

On peut définir les entêtes et les pieds de page dans le fichier recette du livre ou de la collection grâce aux données `:header` et `:footer`.

~~~yaml
:default: &styleheader 
	:font: NomDeLaFont
	:size: 13.5
:header:
	- :name:  	"Nom de ce premier rang" # juste pour information
		:from_page: 12 # numéro de la première page qui affichera cet header
		:to_page:   15	# Numéro de la dernière page qui affichera cet header
		:disposition:   '%titre1- | | -%titre2'
		:style: *styleheader
	- :name:    'Nom de ce second rang' # juste pour information
		:from_page: 	16
		:to_page:    	86
		:format:    ' | -%titre3- | '
		:style: *styleheader
  - :name:  'Pour la fin toute différente'
  	:from_page: 120
  	:to_page:   128
  	:disposition:    'C’est | la | fin'
  	:style: 
  		:font: Geneva
  		:size: 24
  		:border_top: 1px #CCCCCC
:footer:
	- :name:    "Introduction"
		:from_page: 1
		:to_page:   5
		:disposition:    ' | -%num- | '
		:style:
			:size: 9
			:font: Arial
~~~

### Disposition

Le pied de page et l’entête sont divisés en trois parties de taille variable en fonction du contenu. Dans le format (`:disposition`), ces trois parties sont définies par des `|`. 

L’**alignement** s’indique par des tirets avant, après ou de chaque côté du contenu. Quand le tiret est à droite (`mot-`), le mot est aligné à gauche, quand le tiret est à gauche (`-mot`) le contenu est aligné à droite, quand les tirets encadrent le contenu (`-mot- `) — ou quand il n’y en a pas — le contenu est centré.

### Variables

Les variables utilisables dans les entêtes et pieds de page sont toujours des mots simples commençant par `%`. 

Pour les **niveaux de titre**, on utilise **`%titre<NIVEAU>`** par exemple `%titre4` pour les titres de niveau 4.

Pour les **numérotations**, on utilise **`%num`**. Noter que le contenu dépendra de la donnée `:num_page_style` de la recette du livre ou de la collection qui définit avec quoi il faut numéroter.
