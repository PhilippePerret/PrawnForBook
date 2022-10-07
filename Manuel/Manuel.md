# Prawn4book<br />Manuel

**Prawn4book** est une application en ligne de commande permettant de transformer un texte en PDF prêt pour l’impression, grâce au (lovely) gem `Prawn`.

Tous les exemples de ce manuel présupposent qu’un alias de la commande a été créé, grâce à :

~~~bash
> ln -s /Users/me/Programmes/Prawn4book/prawn4book.rb /usr/local/bin/prawn-for-book
~~~

> Noter ci-dessus que la commande sera `prawn-for-book` (qui est plus simple à taper)



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

## Recette du livre

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

