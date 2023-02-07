# Todo courant

- Travailler sur les livres de la collection Narration pour améliorer l'application
  * [BUG] Mauvaise numérotation des paragraphes (semble ne pas repartir de 0 au deuxième tour)
  * [BUG] :numero est demandé dans le pied de page, mais c'est "_NUM_" qui est affiché
  * Entête : les titres sont coupés
    => ne pas mettre de :truncate dans la box quand une seule ou deux tiers seulement sont définis
  * Entête : ne pas mettre le titre quand c'est la page du titre (comment est-ce qu'on va déterter ça ? il faudrait que titre soit une instance et qu'on sache si la page sur laquelle on doit afficher le titre est aussi la page du titre)
  * [BUG] Les mots et les films ne semblent pas être trouvés…

* Pouvoir déterminer la première page par les options de commande (-firts=x)
* Documenter précisément toutes les sections du fichier recette pour ne pas avoir à les retrouver dans les fichiers de l'application…

* Refactoriser l'assistant pour les bibliographies
  - Utiliser le livre assets/essais/book_essais/
  * [BUG] Voir pourquoi la liste des films apparait deux fois en bibliographie
  - POURSUIVRE L'IMPLÉMENTATION DE LA DÉFINITION DU FORMAT DES DONNÉES
    * en faire le tour
    * faire l'assistant qui va permettre de créer de nouveaux itemps
      (penser à une api pour pouvoir peupler à partir de données 'externes')
      - faire l'essai avec les films du filmodico

* Pour la collection Narration
  - faire une bibliographie 'film' et une bibliographie 'term'


# Todo

* Mettre en place la gestion de 'helpers.rb' ou 'helper.rb'
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
