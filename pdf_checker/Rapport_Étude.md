# Checker PDF :: Rapport d’étude

> Ce document essaie de consigner tous les essais effectués sur `PDF::Reader`, `PDF::Inspector::Page` et `PDF::Inspector::Text` pour comprendre comment ils marchent. Grâce au “sniffer”.

Cette étude vise à voir comment tester les documents PDF avec PDF::Inspector mais en rationalisant son utilisation.



## `PDF::Reader`

### `#metadata`

`nil` jusqu’à présent

### `#info`

~~~ruby
:Title		  	# Le titre du document (interne)
:Producer 		# Producteur du fichier
							# p.e. "macOS Version 12.6 (assemblage 21G115) Quartz PDFContex"
:Creator 			# Commande/application qui a créé le fichier
							# p.e. "wkhtmltopdf 0.12.6-dev" ou "Prawn"
:CreationDate	# Date de création
							# p.e. "D:20221106100722Z00'00'"
:ModDate			# Date de dernière modification
~~~

### #page_count

Retourne le **nombre de pages du document**.

### #pages

Retourne la liste `{Array}` des instances `{PDF::Reader::Page}` des pages du document.

TODO : À explorer

### #pdf_version

Retourne la **version PDF du document**. Par exemple “1.3”.

### #objects

~~~ruby
# => Objet d'instance {PDF::Reader::ObjectHash}
# TODO : À explorer
~~~

### #page(...)

Attend un argument. À déterminer

### #then

Énumérateur. De quoi ?

---



## Test des codes trouvés

Dans cette partie, je vais tester les codes trouvés à droite et à gauche pour tenter de bien les comprendre.

Sur la page readme de PDF::Inspector, premier exemple :

~~~ruby
rendered_pdf = your_pdf_document.render
text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)
text_analysis.strings # => ["foo"]
~~~

Essai réalisé avec mon document “Hello world” :

~~~ruby
rendered_pdf = File.open("path/to/hello_world.pdf", 'r')
text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)
text_analysis.strings # => ["Bonjour tout le monde"]
~~~

