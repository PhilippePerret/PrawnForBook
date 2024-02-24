module Prawn4book

MESSAGES = {

  cancel: 'Abandon…',
  define_default_values_for: "Définition des valeurs par défaut pour %s…",

  # --- Fabrication --- #

  building: {

    success: <<~EOT,
      👍 Book PDF produit avec succès !
      #{'(in %{path})'.gris}
      #{'%{nombre_paragraphes} paragraphes sur %{nombre_pages} pages traités en %{duree_traitement} s'.bleu}
      EOT
    success_bat: <<~EOT,
      👍🥂 La vertion BAT du livre a été produite avec succès !
      #{'(in %{path})'.gris}
      #{'%{nombre_paragraphes} paragraphes sur %{nombre_pages} pages traités en %{duree_traitement} s'.bleu}
      EOT
    success_but_unfinished: <<~EOT,
      🍺 Le Book PDF a bien été produit mais des erreurs fatales
        indiquent qu’il ne peut pas être imprimé tel quel.
      #{'(in %{path})'.gris}
      #{'%{nombre_paragraphes} paragraphes sur %{nombre_pages} pages traités en %{duree_traitement} s'.bleu}
      EOT

    verify_book_conformity: <<~EOT.strip,
    Vérification de la conformité du livre et de la recette.
    EOT
  },

  # --- Table des matières --- #

  toc: {

    title: 'Table des matières',

  }, #/:toc

  # --- Recette --- #

  recipe: {

    title_data_to_define: 'DONNÉES DE LA RECETTE DU OU DES LIVRES',
    fonts_can_be_added: 'Ces fontes peuvent être ajoutées aux fontes déjà présentes.',

  }, #/ :recipe

  # --- Bibliographie --- #

  biblio: {


    no_occurrence: "Il n'existe aucune occurrence pour la bibliographie « %s ».\nC'est peut-être normal.",
    
    intro_assistant: "
    Nous allons programmer les bibliographies du livre courant

    Une bibliographie est constituée d'une liste d'entrées qui peuvent
    se trouver soit dans des fichiers soit dans un unique fichier 
    YAML.

    Elle est caractérisée par :
      - un identifiant unique (appelé 'tag') plutôt au singulier.
        C'est par exemple 'film', qui sera utilisé pour :
          * ajouter des items en cours de texte, avec le code 
          '(( film(<identifiant du film>) ))'
          * inscrire la bibliographie à l'endroit voulu avec le code
            '(( biblio(film) ))'.
          * définir le nom du fichier de données : 'films.yaml' ou
            du dossier contenant les fiches de données : 'films' dans
            le dossier 'biblios' du livre ou de la collection.

    Les données d'une bibliographie sont les suivantes

    :tag    L'identifiant singulier de la bibliographie
    :title  Le titre de la bibliographie tel qu'il apparaitra dans
            le livre (à la fin ou à l'endroit voulu).
    :title_level  Le niveau de titre utilisé, de 1 à 7.
    :new_page   Pour savoir s'il faut forcer la bibliographie à passer
                à la page suivante. Note : n'a pas besoin d'être défi-
                nie si le niveau de titre définit déjà ce passage.
    :data       Si les données ne se trouvent pas à leur endroit natu-
                rel par convention, on peut définir l'emplacement à
                l'aide de cette donnée optionnelle.

    ",
    has_already_biblio: "Ce livre définit déjà les bibliographies %s.",
    bibs_created_with_success: "Les bibliographies ont été créées avec succès.",
    consigned: "Bibliographie consignée.",
    data_format_saved: "Format des données de la bibliographie '%s' enregistrées avec succès.",

  }, #/ :biblio


  # --- Assistants --- #

  assistant: {

    require_book_folder: "Cet assistant doit être appelé depuis le dossier d'un livre.",

    confirmation_init: <<~EOT.bleu,
      À présent, vous pouvez :

      1) rejoindre le dossier du livre avec 'cd "%{folder}"'

      2) jouer ces commandes :
      
      #{'pfb open -e'.jaune}
          #{'pour'.bleu_} ouvrir le dossier dans l'éditeur et modifier la
          recette, les méthodes ou le texte

      #{'pfb build -open'.jaune}
          #{'pour'.bleu_} produire la première version du livre en PDF 
          prêt à l'impression (et l'ouvrir pour le lire).
          (vous pouvez même commencer directement par là pour
          vous faire une idée...)

      #{'pfb assistant'.jaune}
          #{'pour'.bleu_} entrer toutes les données de façon assistée.
      
      #{'pfb install'.jaune}
          #{'pour'.bleu_} définir les snippets utilisables à la rédaction 
          du livre.

      #{''.bleu_}Vous pouvez également définir des SNIPPETS dans le dossier du
      même nom.
      EOT

  }, #/assistant


}

MESSAGES[:biblio].merge!(explaination_after_create: <<-TEXT)

Il vous reste quelques petites choses à faire :

Le module BibliographyFormaterModule du fichier formater.rb doit
définir la ou les méthodes :
%s
… qui vont permettre de formater les éléments dans la bibliographie.

Pour ajouter un élément bibliographique, adopter par exemple pour la
première bibliographie la syntaxe :
  %s(<id element>)

Pour inscrire la bibliographie dans le livre, placer à l'endroit du
livre voulu le code (et seulement le code) :
  (( %s ))
TEXT

end #/module Prawn4book
