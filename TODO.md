# Todo courant

* J'en suis à essayer de faire passer la nouvelle construction d'un
  livre à partir des nouvelles propriétés d'une recette.
  Quand j'y arriverai, il sera temps de tester un livre avec 
  PDF::Checker
  Pour le moment, le PDF est produit, mais c'est juste une horreur
  - le texte n'est pas affiché
  - la page d'infos est complètement tronquée

* Il faut repenser encore le fonctionnement des headers/footers
  Une disposition doit contenir ce qu'il contient :
    - un nom
    - un début et fin de page
    - un header
    - un footer
  C'est au-niveau des headers/footers que ça doit changer : on 
  doit, pour chacun d'eux, définir le contenu des au moins 6 parties :
    - droite de page gauche, droite de page droite
    - centre de page gauche, centre de page droite
    - gauche de page gauche, gauche de page droite
  * Il faut pouvoir mettre : un titre ou un numéro de page
  * On doit pouvoir définir au centre pour les deux (donc ne définir
    qu'un seul centre ou définir un centre différent pour chaque page)
  * Il faut définir un header par défaut (sans rien) et un footer
    par défaut (avec numéro de page sur gauche de gauche et droite de
    droite)
  => Ré-écrire le mode d'emploi (peut-être, dans le mode d'emploi, conseiller d'utiliser l'assistant et voir ensuite les données inscrites pour s'en inspirer)

* Se servir de `Prawn::Fonts::AFM::BUILT_INS` pour définir les polices par défaut accessible dans Prawn.


* Corrections/affinements par rapport au premier livre Narration
  -> cf. le fichier TODO de la collection

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
