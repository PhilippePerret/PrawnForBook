# Tests par comparaison

Ce dossier est voué à devenir le seul dossier pour les tests.

Tous les tests doivent fonctionner de la même manière, sur la base de la méthode `FileUtils#identical?(expected_book, actual_book)`.

## Fonctionnement général

* On crée un dossier de collection (pour ne pas avoir à définir le livre chaque fois, pour des tests de même ordre)
* on place dans ce dossier la définition d'un test, qui est constitué de :
  - le fichier `texte.pfb.md` qui contient le code à évaluer
  - le fichier `expected.pdf` qui est le LIVRE TEL QU'IL DOIT ÊTRE
  - un fichier `data-test.yaml` qui contient les données pour le test, à commencer par :

    ~~~yaml
    ---
    name: Le nom du test (pour affichage)
    description: |
      La description du test (pour affichage), ce qu'il fait exactement
    ~~~

  * on lance ensuite méthode `rake test TEST=compare/run_tests.rb` pour lancer tous les tests.
