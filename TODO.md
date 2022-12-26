# Todo courant

Il faudrait des modules indépendants pour gérer 1) avec l'assistant et 2) avec l'initiateur de livre les choses principales que sont :
- la page de titre
- la table des matières
- la page des informations de fin
- peut-être les pieds et entête de page
- la page d'index
- les pages de références (plusieurs références possibles)
Ce module doit permettre aussi de définir les valeurs par défaut des éléments. En gros, l'idée serait de trouver tous les éléments au même endroit :
  - dans un dossier du nom de l'élément (p.e. "Page_de_titre"), on trouverait
  - le module 'build' de construction
  - le module 'data' de gestion des données et notamment de définition des valeurs par défaut
  - le module 'assistant' d'aide à la définition (qui doit pouvoir fonctionner de façon autonome et avec l'initiateur de livre/collection)

* Le test 'init_book_test.rb' s'attache à tester la création assistée d'un nouveau livre.
  Il faut poursuivre cette exploration, notamment pour :
  - tenir compte du texte qui, ici, est fourni, mais n'est pas construit dans le livre final,
  - être capable de produire un livre directement qui ressemble à quelque chose,
  - pouvoir définir encore d'autres données importantes et notamment :
    - la police/taille par défaut (mise pour le moment à la première fonte définie)
    - le texte exemple construit, plus ou moins long, à partir de 3 templates de type lorem ipsum (qui seront caractérisé par leur nombre de pages )


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
