# Todo courant

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

---

<a name="correction-textes"></a>

### Réflexion sur la correction des textes

Commençons par essayer d’établir toutes les corrections qu’on peut rencontrer dans les textes

* les codes pseudo-markdown “en ligne” : italique, gras, souligné, code
* les codes pseudo-markdown qui nécessitent une mise en forme particulière :
  * liste étoiles
  * table (traits droits)
  * citations (quote)
* le traitement des références (internes et croisées) qui est un parseur d’un côté (pour relever les cibles et détecter les appels) et un formater (pour formater les appels — les cibles, elles, sont invisibles),
* les termes bibliographiques (livres, index, people, etc. dépend de chaque livre et chaque collection),
* les formatages spéciaux de paragraphes, par balises de début de paragraphe (`tag::Texte du paragraphe`)
* les évaluations de code ruby à l’intérieur du texte (`#{<...code...>}`),
* les formatages spéciaux à l’intérieur d’un paragraphe, qui peuvent être définis par n’importe quoi. Pour le moment, ils sont traités par le “parseur/formateur” qui reçoit le texte. C’est un `gsub` qui transforme les textes et peut même les mettre de côté si nécessaire.

L’idée directrice générale serait de traiter les choses le plus tard possible, afin d’avoir toujours le maximum d’indication sur l’état courant. On pourrait se dire aussi que les choses qui font varier le texte sont toujours définies *avant* ce texte, donc qu’on peut toujours le parser dès qu’on le rencontre.

Typiquement, les choses où il faut tenir compte du contexte concerne seulement (à vérifier) la taille courant du texte. Cette taille a une influence directe sur 

Pour une table, cette taille du texte peut dépendre : 

* de la définition de cette taille dans la cellule (c’est déjà pris en compte)
* de la définition de cette taille pour la table (pas pris en compte)
* peut-être aussi d’une définition avant la définition de la table (même s’il me semble que ça n’est pas possible.

Moralité : il serait tout à fait possible de créer une méthode de classe, indépendante des classes de texte, qui pré-traite les textes (exception faite des listes, des tables, et voir quoi, qui en revanche enverraient quand même leur texte)

Cette méthode doit :

* dépendre du contexte (donc connaitre les définitions de police et de taille courante)
* intégrer tous les modules de formatage propres au livre ou à la collection (peut-être faire une classe unique plutôt que de multiplier les modules)

**Les modules**

En fait, il faudrait simplement :

* un module pour **mettre en forme les bibliographies** (ne pas le mélanger avec le parseur/formateur qui, lui, doit juste s’occuper du texte au long du livre)
* un module pour **mettre en forme les tables propres**, puisque c’est un gros morceau des livres
* un module qui parse et qui formate les textes
