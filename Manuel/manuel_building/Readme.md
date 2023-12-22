# Manuel auto-produit

Ce dossier permet de produire le manuel de façon automatique à l’aide de ***Prawn-for-book***.

## Todo

* Poursuivre la démonstration des puces



## Tâches de base

* [Actualisation du manuel](#update-manual)
* [Ajout d'une fonctionnalité](#add-feature)


---

<a name="update-manual"></a>

## Actualisation du manuel

* Ouvrir un Terminal à ce dossier,
* jouer la commande `pfb build`
* jouer la commande `pfb open` et choisir l'item « Ouvrir le livre PDF » (ou similaire).

---

<a name="add-feature"></a>

## Ajout d'une fonctionnalité

Pour ajouter une fonctionnalité


* on lui créer un fichier avec un titre unique parlant dans le dossier `Features`. Pour l’exemple, nous prendrons `nouvelle_fonction.rb`,

* on l’ajoute en la plaçant (son affixe, donc `nouvelle_fonction`) au meilleur endroit dans le manuel dans la liste du fichier `Features/_FEATURE_LIST_.rb`,

* On définit son code dans le fichier `nouvelle_fonction.rb` en utilisant :

  ~~~ruby
  Prawn4book::Manual::Feature.new do
    # ... ici le code ...
  end
  ~~~

* On peut l’ajouter à la liste de toutes les fonctionnalités dans le fichier `Features/liste_exhaustive_features.rb`. En ajoutant le nom du fichier entre deux crochets (`[[path/fichier]]`), on crée automatiquement un lien vers la page concernée.

  > Voir ci-dessous pour la définition de la fonctionnalité.

* et pour terminer, on demande [l’actualisation du manuel](#update-manual).

### Définition de la fonctionnalité

Pour définir la fonctionnalité, on définit principalement :

~~~ruby
Prawn4book::Manual::Feature.new do
  
  titre "Le titre de la fonctionnalité courante"

  # La description précise de la fonctionnalité
  description %Q{
  	Ici, je décris la fonctionnalité de façon très précise, c'est
		le texte qui introduira le reste, juste sous le titre.
		}.gsub(/\n/,' ').strip # ou <<~EOT \n EOT

  # Le texte exemple qui produira l'illustration (sauf si
  # 'texte' est aussi défini.
  # Il doit être défini exactement comme le texte dans le
  # texte du livre.
  # C'est la solution préférable à l'utilisation de 'texte'
  # car il a ici une valeur de test. On est certain que le code
  # produira le résultat attendu.
  sample_texte "..."
  
	# Le texte qui pourrait aussi s'appeler le "code". C'est
  # ce qui doit être écrit dans le fichier texte.pfb.md du
  # livre pour produire le résultat attendu. 
  # Cette propriété doit être utilisé si 'sample_texte' (ci-dessus)
  # ne peut pas être utilisé tel quel pour produire l'illustration
  # (donc, c'est moins bien, car il peut y avoir une différence)
  # Ce texte doit être formaté exactement comme dans le fichier
  # texte du livre.
  texte "...."
  
  # Si on doit passer à la page suivante avant de produire
  # le texte
  new_page_before_texte true

	# Pour montrer ce qu'on doit mettre dans la recette 
  # Mais noter que ce code n'aura aucun incidence sur la recette
  # courante. Pour agir sur la recette courante, il faut utiliser
  # 'recipe' ci-dessous.
  sample_recipe %Q{
		---
		book_format:
			page:
				orientation: paysage
	}.strip

  # Pour modifier provisoirement (le temps de cette fonctionnalité)
  # la recette courante.
  # On utilise une clé simple (:key_simple) ci-dessous lorsque c'est
  # une propriété de "premier niveau" dans la recette, c'est-à-dire une
  # propriété @key_simple.
  # Mais très souvent, on doit prendre ou modifier une valeur dans une
  # table. On utilise alors :key_table comme ci-dessous.
  # Noter qu'à l'heure où sont écrites ces lignes, on ne peut pas 
  # atteindre des valeurs de table qui sont elles-mêmes des valeurs de
  # table (profondeur de 2).
  recipe {
  	key_simple:   value,
    key_table:    {key_simple: value}
  }
  
  # Pour montrer un exemple de code à utiliser dans un module de
  # formatage ou de parsing personnalisé par exemple.
  # Si "code" n'est pas défini, c'est ce code qui sera joué pour
  # produire l'illustration du manuel.
  sample_code "... le code ruby ..."
  
  # Pour jouer du code en coulisse
  # Pour le moment, ce code est joué juste avant le texte s'il existe
  code <<~RUBY
  	# Le code ruby à jouer en coulisses.
  RUBY
  
  # Si on doit définir une nouvelle hauteur de ligne
  line_height 30
  # Si on doit afficher les lignes de référence
  show_grid true
  
end
~~~



---



## Todo

* Revoir le traitement des guillemets, qui pose problème (il a été désactivé). Le problème se pose avec les guillemets droits. En fait, il ne faudrait jamais les toucher lorsqu'il y a autre chose qu'une espace (sécable ou non) des deux côtés à la fois. Donc, dès qu'il y a une espace, on devrait le considérer comme un guillemet typographique, pas comme un guillemets de délimiteur de string dans un bout de programme ou dans des paramètres.



## Réflexions

* 
* 

## Exemple code pour la recette

* Explication : le réglage de `show_grid` et `show_margins` dans la recette permet d’afficher les trucs

  * On ajoute aussi la précision qu’on peut obtenir le même résultat avec les options.

* Code recette : on montre ce qu’il faut écrire dans le fichier recette, c’est-à-dire :

  ~~~
  book_format:
  	text:
  		show_grid: true
  		show_margin: true
  ~~~

* code à jouer pour obtenir ce qu’on veut (là, le code n’est pas donner en exemple

  * Comme ce n’est pas un code exemple et que c’est un code recette, on va obtenir un code qui va être jouer de cette manière :

    ~~~ruby
    with_recipe(show_grid:true, show_margins:true) do
      pdf.update do
        start_new_page
        draw_grid(page_number)
        draw_margins(page_number)
      end
    end
    ~~~

  * Note : l’idéal, ça serait qu’on puisse entrer une recette (tout le code) dans l’application. Cela permettrait d’être sûr que l’exemple donné est valide (toujours dans l’idée que le manuel serve aussi de test.
