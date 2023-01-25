# Todo courant

* Référence croisée :
  - quand un numéro de paragraphe n'existe pas (livre imprimé non prawn) utiliser le numéro de page
    => faire un test pour ça.
    
* Avant le build du livre, regarder si le texte contient des balises pour des références croisées, voir si toutes les données utiles existent ou générer une erreur tout de suite en expliquant quoi faire.

* Corrections/affinements par rapport au premier livre Narration
  -> cf. le fichier TODO de la collection


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
