# Dossier `tables_test`

## Description

Ce dossier contient tous les tests sur les tables dans **`Prawn-for-book`**.

Chaque dossier est un test qui porte comme nom :

~~~
<indice table>-<nom du test>

# Par exemple 

TBL1-simple_test
~~~

Chaque dossier de test contient (après les test) deux fichiers :

1. le livre attendu (qui porte le nom **`expected.pdf`**
2. le livre produit (qui porte le nom **`actual.pdf`**

## Vérification à faire

Plus tard, lorsqu’il suffira de comparer deux fichiers comme avec une page HTML, on pourra simplement s’assurer que les deux fichiers sont identiques. 

Pour le moment, il faut faire les checks “à la main”, en comparant visuellement chaque fichier.
