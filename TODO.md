# Todo courant

* Le dernier numéro de paragraphe n'est pas le bon pour la page 9 (devrait être 6)

* Ajouter la définition de 
  :parag_num_dist_from_text qui définit la distance entre le paragraphe et son numéro (en ps-point) (5 par défaut)
  et 
  :parag_numero_vadjust qui définit l'ajustement vertical du numéro (1 par défaut)
  => book_format[:text][:parag_numero_vadjust]
  => book_format[:text][:parag_num_dist_from_text]
  (note : déjà implémenté pour être traité)

* header footer
  - Ajouter les nouveaux paramètres :
    - format de numérotation (liste fermée, dont 'first-last', 'first/last', 'first à last', '<page>', 'Page <page>')
    - options (numéro de page quand pas de paragraphe, pas de numéro sur page vide, ne numéroter avec les paragraphes que s'il y en a)
  -

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
