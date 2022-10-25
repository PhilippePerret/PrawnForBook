# Todo courant

* Rationnaliser l'utilisation des formater.rb, helpers.rb et parser.rb
  - déjà, il y a du formater dans parser.rb
  - ensuite, il faut trouver les moyens de conserver les données
* Traitement des données ajoutées avant un paragraphe
* Mettre en place les mises en forme propres à un livre (sur la base de la collection Narration)
  - mise en forme des mots spéciaux (à définir) (une balise doit renvoyer à une méthode d'helper)

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
