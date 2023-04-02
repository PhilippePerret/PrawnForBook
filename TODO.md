# Todo courant

* pour l'apostrophe : apostrophe courbe
* [snippet] quand on tape "(({[tab]" => "(( {} ))" (documenter)


* Documenter précisément toutes les sections du fichier recette pour ne pas avoir à les retrouver dans les fichiers de l'application…

* Refactoriser l'assistant pour les bibliographies
  - Utiliser le livre assets/essais/book_essais/
  * [BUG] Voir pourquoi la liste des films apparait deux fois en bibliographie

# Todo

* Mettre en place la gestion de 'formaters.rb' ou 'formater.rb'
  Ça doit être "isolé" dans une classe particulière (PdfHelper)
  Pour le traitement du code, quand on parse le paragraphe, on regarde :
    — si c'est un nom unique (ne contenant qu'un nom de fonction et à la rigueur des parathèses avec quelque chose de quelconque)
    - si ce nom est une méthode à laquelle le helper répond.
    - SI OUI, on l'évalue dans le contexte du helper
      SI NON, on joue le code "sur place"
* S'en servir dans le fichier test pour :
  - afficher les hauteurs des lignes de référence
  - afficher la hauteur de chaque ligne et la ligne de référence correspondante (pdf.line_reference)


* Pouvoir créer/enregistrer une collection
* PROPRIÉTÉS PROPRES AUX PARAGRAPHES
  - kerning (?) espacement entre les lettres
  - margin différente avec le paragraphe au-dessus (en restant — ou pas — sur la ligne de base de la grille)
