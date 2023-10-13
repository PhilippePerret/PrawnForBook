# Test "produce"

Les tests "produce" fonctionnent en comparant un document PDF produit avec le document attendu.

## Aide rapide

Pour lancer tous les tests "produce" :

~~~
rake test_p
~~~

Pour filtrer les tests "produce" :

~~~
rake test_p TEST=/bout_de_nom/
~~~

> Tous les dossiers et tous les fichiers qui contiendront "bout_de_nom" dans leur nom seront joués.

## Description

J'appelle "Tests produce" les tests qui fonctionnent en comparant un document PDF produit avec le document attendu (pas le hash).

## Création d'un nouveau test "produce"

* faire le dossier du livre (comme si c'était un vrai) dans le dossier `tests/produce/books`,
* dans ce dossier, créer le fichier `texte.pfb.md` et y écrire le texte/code à tester,
* dans ce dossier, créer le fichier recette `recipe.yaml` et y mettre les informations minimales, à savoir :

  ~~~yaml
  ---
  #<book_data>
  book_data:
    title: "titre du livre"
    auteur: "Auteur DU LIVRE"
  #</book_data>
  ~~~

* créer un test `Minitest::Test` normal, qui contiendra :

  ~~~ruby
    def test_description_du_document
      assert_silent { produce_book("books/to/my/new/book", **{keep:true}) }
    end
  ~~~

  > On peut mettre ce code dans un fichier test déjà initié, par exemple `produce/exemple_test.rb`.

* lancer le test une première fois

  La première fois, si tout le reste est OK, il va générer une erreur indiquant qu'il ne connait pas le hash du fichier à comparer. Et il va donner celui du document produit.

  Vérifier que le document produit correspond aux attentes, puis :

* coller le code fourni (`test: hash_ruby: etc.`) au bout du fichier recette du livre.
* relancer le test, cette fois il doit passer avec succès.
* on peut supprimer le `keep:true` pour que le livre produit ne soit pas conservé quand le test est un succès.

> Note : par défaut, le livre est détruit. Il faut ajouter l'option `keep: true` pour le conserver : `produce_book('path/to/book', **{keep:true})`

