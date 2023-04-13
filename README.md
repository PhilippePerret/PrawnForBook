# Prawn-for-book

Comme son nom l'indique, cette application permet de produire des livres prêts-à-l'impression (PDF) à l'aide de [Prawn](https://github.com/justchilinp/prawnpdf).

Elle peut fonctionner de façon rudimentaire, à partir d'un simple fichier pseudo-markdown ou de façon très complexe et complète, avec des références croisées, des bibliographies de toutes sortes, des mises en forme complexes grâce à une recette et des parseurs/formateurs, une collection de livres partageant les mêmes éléments, à commencer par la charte graphique.

Et elle produit toujours un fichier `PDF` qu'on peut envoyer directement à l'imprimeur (hors couverture) pour tirage du livre.

## Synopsis

* télécharger le dossier de l'application,
* [créer un alias](#make-alias) pour pouvoir la lancer plus facilement avec `pfb`,
* jouer la commande `pfb init` pour initier un nouveau livre à l'endroit voulu,
* ouvrez un terminal dans le dossier du livre (appelé `<dossier livre>` ci-dessous),
* élaborer le fichier du livre dans **`<dossier livre>/texte.pfb.md`**,
* affiner la recette directement dans **`<dossier livre>/recipe.yaml`** ou en vous aidant des assistants (`pfb assistant`)
* utiliser le manuel pour tout connaitre (**`pfb manuel`**),
* fabriquer le livre à l'aide de la commande **`pfb build`**.

---

<a name="make-alias"></a>

### Créer un alias de lancement

~~~bash

ln -s /Users/vous/Prawn4book/prawn4book.rb /usr/local/bin/pfb

~~~
