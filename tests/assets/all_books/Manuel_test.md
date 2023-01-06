# Universel PDF tests

Ce dossier permet de tester tous les PDFs produits par **Prawn-For-Book** (mais en fait, on pourrait imaginer s'en servir pour n'importe quel document PDF, ça serait juste la base — le fichier `test.rb` — qui diffèrerait).

## Principe de fonctionnement

* on met dans un dossier le livre (sa recette — ou pas — et son texte),
* on met dans un fichier de ce dossier les attentes concernant le contenu de ce livre
* on construit le livre avec `pfb build`
* on regarde si le résultat correspond aux attentes.

### Collection ou livre

Le dossier d'un simple livre se met dans le dossier `books`. Le dossier d'un livre de collection se met dans le dossier de la collection placé dans le dossier `collections`

~~~

assets/all_books/
  |
  |-- lib/ (pour le fonctionnement des tests)
  |
  |-- books/ (dossier des livres à tester)
  |     |
  |     |-- mytestedbook/
  |           |- recipe.yaml
  |           |- texte.pfb.md
  |           |- expectations
  |
  |-- collections/ (dossier des collections à tester)
        |
        |-- mycollection/
              |
              |-  recipe_collection.yaml
              |
              |-- first_book_of_my_collection/
              |       |- recipe.yaml
              |       |- texte.pfb.md
              |       |- expectations
              |
              |-- second_book_of_my_collection/

~~~


## Assertions

Méthodes utilisables pour tester le livre, à utiliser dans les fichiers `expectations` de chaque dossier livre testé.

* Le fichier `expectations` est constitué de lignes,
* chaque ligne définit une assertion complète,
* une assertion est constituée de *termes* séparés par `:::`,
* chaque terme est *évalué* par ruby (cf. plus bas),
* le premier terme est toujours l'attente, la nature de l'expectation.

Exemple : 

~~~
should_contains ::: "Ce texte"
# => Le PDF doit contenir le texte "Ce texte"
~~~

#### Concernant les *termes* des assertions

Il faut comprendre qu'elles sont évaluées par le programme. Donc, un string, par exemple, doit toujours être placé entre guillemets :

~~~
"un string"
~~~

… tandis qu'un symbole doit toujours être précédé de `:` : 

~~~
:un_symbole
~~~


<a name="assert-have-text"></a>

### `:should_have_text`

~~~
:should_have_text ::: "<le texte exact à trouver>"

On doit trouver le texte fourni en premier argument de façon exact dans un "bloc" de texte du document PDF. Attention, c'est à la virgule prêt, une espace insécable ne sera pas confondue avec une espace normale.

Pour rechercher un texte plus simplement, utiliser plutôt [`:should_contains`](#should-contains)

<a name="should-contain"></a>

~~~
:should_contain ::: "<le texte à trouver>"
~~~

On doit trouver le texte fourni en premier argument quelque part.
