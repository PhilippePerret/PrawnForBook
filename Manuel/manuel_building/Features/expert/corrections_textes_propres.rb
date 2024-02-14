Prawn4book::Manual::Feature.new do

  titre "Corrections propres du texte"


  description <<~EOT
    On peut imposer des corrections supplémentaire et propres au texte en utilisant trois méthodes particulières des instances de paragraphes quelconques : **`#parse`**, **`#pre_parse`** et **`#post_parse`**.
    Ces trois méthodes permettent d’intervenir à chaque moment du traitement complet du paragraphe, quel qu’il soit.
    Elles ne contiennent que le mot *parse*, mais elles peuvent également intervenir sur le formatage du texte, dans une certaine mesure (elles ne peuvent pas modifier le type du paragraphe par exemple).

    #### Définition des méthodes de parsing personnalisées

    Elles se définissent soit pour la classe générale `Prawn4book::PdfBook::AnyParagraph` soit seulement pour un type de paragraphe particulier, souvent le type texte (`NTextParagraph`), le type titre (`NTitre`) ou le type image (`NImage`). Pour les autres types de paragraphes, voir [[expert/types_de_paragraphes]].
    Elles peuvent se définir dans n’importe lequel des fichiers `parser.rb`, `formater.rb` ou `prawn4book` (car elles peuvent relever des trois).
    Attention, elles se définissent comme *méthodes de classe* pas comme méthode d’instance.
    Exemple :
    (( line ))
    ~~~ruby
    module Prawn4book
      class PdfBook::NTextParagraph
      class << self
        # Le traitement se fera à la fin
        def post_parse(str, context)
          # Ici on traite le texte
          str = str.gsub(REG_SEARCH, REMPLACEMENT)
          # Toujours retourner le string modifié
          return str
        end
      end #/<< self
      end #/class PdfBook::NTextParagraph
    end #/module Prawn4book
    ~~~

    #### Moment du traitement du parsing propre

    Pour choisir la méthode utilisées, voyez où chacune intervient dans le traitement du texte fourni (à titre de rappel, le texte fourni se limite toujours au texte d’un seul paragraphe, sauf si la méthode système `#__parse` est appelée de force avec un texte personnalisé).
    (( line ))
    ~~~
    SYNOPSIS MÉTHODE DE CLASSE __parse
    ----------------------------------
     
      Vérification de la validité des paramètres
     
    #pre_parse
     
      Récupération des class-tags (styles de paragraphes)
      Traitement des codes ruby
      Ajout de la position du curseur si nécessaire
      Traitement des formatages markdown in-line (italiques, etc.)
      Traitement des marques et cibles bibliographiques
      Traitement des mots indexés
      Traitement des abréviations
      Traitement des mots pour les index personnalisés
      Traitement des marques et cibles de références croisées
     
    #parse
     
      Correction typographiques
      Traitement des autres signes (tirets conditionnels, etc.)
      Application des class-tags (style de paragraphe)
      Traitement des notes
      Traitements ultimes des caractères
       
    #post_parse
     
      Renvoi du texte modifié.

    ~~~
    (( line ))


    EOT



end
