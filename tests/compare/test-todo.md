# Todo

* Changer tous les "publisher" en "publisher" 
* Utiliser une instance BookPage depuis le départ, pas un hash. Ça sera une instance Prawn4book::BookPage à ne pas confondre avec l'instance Prawn4book::HeadersFooters::BookPage (qui pourra être remplacé par cette instance, by the way)

* Utiliser plutôt le hachage pour comparer deux documents (j'attends la réponse de pointlessone pour savoir quelle meilleure méthode utiliser)

* Passer tous les tests en comparaison du document produit, à part quelques tests unitaires à conserver (utiliser la comparaison par hash)


# Tests à faire

* Index par paragraphe
* références croisées (utiliser le livre "references_internes")
* [Table] Sur la méthode `before_rendering_page`
* les bibliographies
  * mise en forme des bibliographies

## Plus tard

* Tout tester par comparaison, tout…
