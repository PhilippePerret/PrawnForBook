# Tests par comparaison



[TOC]

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

<a name="creation-test"></a>

## Création d'un nouveau test

Pour créer un nouveau test, il suffit de créer le dossier du livre dans une collection existante ou de créer le dossier d'une collection puis le dossier du livre.

Dans ce dossier (du livre), il faut mettre :

* le fichier `texte.pfb.md` qui contiendra le texte du livre,
* le fichier `data-test.yaml` qui contiendra les [données du test](#data-test),
* optionnellement le fichier `recipe.yaml` si des recettes sont à ajuster, mais ce fichier n'est pas nécessaire puisque le livre se trouve dans une collection.

### Tester le test…

Pour voir ce que le test va donner, ou régler certaines choses, se souvenir qu’un dossier de test est un livre comme les autres. On peut donc ouvrir un Terminal à son dossier et lancer la commande `pfb build` pour construire le livre.



<a name="data-test"></a>

## Données du test

Les données du test sont définies dans le fichier `data-test.yaml` dans le dossier du livre (ou/et le dossier de la collection).

Ces données contiennent :

~~~yaml
---
name: Le nom du test pour affichage
resume: |
  La description du test qui apparaitra dans le suivi, lorsque le 
  test sera joué.
~~~

<a name="run-test"></a>

## Lancement du test

Une fois [le test créé](#creation-test), on peut :

* indiquer au runner que c'est ce test qui doit être joué (grâce à INCLUDES et EXCLUDES),
* ouvrir un Terminal au dossier de l’application PrawnForBook,
* lancer le runner grâce à : 

~~~
  > rake test TEST=tests/compare/runner
~~~
