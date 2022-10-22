# Todo courant

* Quand il n'y a pas de paragraphes, essayer de mettre le numéro de page en entête/pied de page (mais il faudrait pouvoir l'activer ou le désactiver)
* Mettre en place les mises en forme propres à un livre (sur la base de la collection Narration)

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


* [RECETTE] Définir:
  - default_font -> documenter
  - default_font_size -> documenter
  - default_leading -
  -> documenter next_ref_line

* Essais à faire :
  - remplir de couleur (pour bien voir où est le bloc)
  - "passer à la ligne" et prendre la nouvelle hauteur (cursor), en changeant la taille de la fonte, pour voir le rapport
* Pour le placement des éléments (et notamment les titres) au lieu de fonctionner en points, fonctionner en nombre de lignes de référence.
  Par défaut, on part du principe que les lignes, comme dans un bon livre, sont posées sur une grille de référence. Cette grille est dépendante de la propriété `:interline` (interlignage — voir où je dois la définir, peut-être `pdf_config`, le deuxième argument de `Prawn::Document::generate`). Elle est peut-être aussi dépendante de la taille de la font de base (qu'il faut pouvoir définir)
  À faire :
    - voir comment définir l'interlignage
    - voir comment calculer et surtout fixer la grille de référence (mais normalement, c'est en déplaçant le curseur de la hauteur voulu qu'on y parvient)
    - voir comment faire pour que, dans un même texte qui passe à la ligne, les lignes s'appuient sur la grille de référence
  Ensuite :
    - lorsqu'on définit qu'un titre (:level1 par exemple) se trouve à `3` de ce qui précède, ça signifie qu'il faut laisser passer 3 lignes de référence avant d'écrire se titre. Ce qui peut se résumer à `move_cursor_to 3 * interligne`. Mais les titres ne sont pas toujours sur les lignes de la grille de référence. On peut aussi utiliser des demi-lignes. Par exemple 2.5 pour mettre le titre à 2.5 * interligne de la ligne précédente.

* [recette] Redéfinir les tailles des titres du livres (moins gros)

* Dans le dossier du livre on peut trouver :
  - (`formater.rb`)un *formater* — qui va mettre en forme les balises se trouvant dans le texte
    * noter quand même qu'on doit proposer le même principe pour tout type de document : un code `balise:` amorçant un paragraphe détermine un type de paragraphe qui renverra au formater (`formate_balise(paragraphe)`) 

* Poursuivre les essais sur la table des matières
  En profiter pour bien comprendre le fonctionnement des :
  - text
  - text_box
  - span
  - bounding_box

* [NARRATION]
  * Faire la liste de tous les films avec les endroits où on en parle
    - de façon plus générale, voir comment on peut programmer ce genre de chose dans P4B

* Bien calculer les marges/header/footer (cf. le manuel pour voir comment ils sont définis)

* Pouvoir créer/enregistrer une collection
* Command qui permet d'ouvrir le fichier de recette du livre
* Prendre les données enregistrées pour en tenir compte lors de la génération du book PDF.
* Entête et Pied de page
   => une class propre, qui génèrera des données YAML qu'on pourra enregistrer dans le fichier recette
* Il faudra faire des propriétés propres à chaque style de paragraphe, par exemple des "note" pourraient être de différents styles qu'on doit pouvoir spécifier. 
  => documenter
* Ajuster les positions des titres
  -> pouvoir les définir dans le fichier recette du livre (ou de la collection)
* Régler les numéros de pages ou de paragraphes en bas de page
* pouvoir gérer les orphelines et les veuves
  - Voir les propriétés de Prawn que je n'ai pas encore découverte ou exploitées.
* PROPRIÉTÉS PROPRES AUX PARAGRAPHES
  - kerning (?) espacement entre les lettres
  - passage à la page suivante
  - margin différente avec le paragraphe au-dessus (en restant — ou pas — sur la ligne de base de la grille)

* récupérer les mots à indexer
  - comment en faire une généralité ? Faut-il pouvoir indiquer le style des mots qu'il faut conserver. Par exemple, ici, ce seront les mots repérés par 'mot:...' ou 'mot(...)' ou 'MOT[...]'.

* produire une table des matières

* mettre en forme les mots spéciaux (titre de film, mot technique, etc)
  => Définition dans la recette du livre
  => Documenter

* un titre ne doit jamais se retrouver seul en bas de la page précédente

* réfléchir au fonctionnement de l'index : est-ce que je balise les termes à indexer dans le texte ou je fonctionne plutôt avec une expression régulière définissant les différentes formules qui correspondent à un mot, et le programme trouve lui-même les mots en analysant les paragraphes (et les titres) ?
-> possibilité de rechercher toutes les itérations d'un mot indexé (ou pas) et de lister les paragraphes où on le trouve.
-> possibilité de sortir le texte (en HTML) avec le numéro des paragraphes, même lorsqu'il n'est pas utilisé dans les pages comme ça (pour pouvoir faire des recherches faciles)

* possibilité de sortir le livre seulement jusqu'à une certaine page

* pouvoir définir l'aspect de la table des matières
  -> Une classe NTdm
  -> Dont on peut enregistrer les données soit dans le livre recette du livre ou de la collection

* [NARRATION] prévoir une filmographie (liste de tous les films utilisés dans le livre)

* Pouvoir choisir une fonte dans les 3 endroits où on les trouve
  - si ce n'est pas une fonte ttf, dire quoi faire


# à vérifier pour être sûr d'utiliser Prawn
  (pour le moment, tout se passe bien, le livre semble avoir pu être imprimé…)

* est-ce aligner sur la grille ?
* est-ce que les polices sont vraiment empaquetées ?
  -> test sur KDP
* est-ce que les images sont au bon mode (:cmkj je sais pas quoi)
  -> test sur KDP
* est-ce qu'on peut mettre du style (italic, gras)
  -> oui, tester sur KDP
* est-ce qu'on peut changer de caractère au cours du texte ?
  -> oui, tester sur KDP

