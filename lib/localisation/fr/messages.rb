module Prawn4book

MESSAGES = {

  # --- Table des matières --- #

  toc: {

    title: 'Table des matières',

  }, #/:toc

  # --- Recette --- #

  recipe: {

    fonts_can_be_added: 'Ces fontes peuvent être ajoutées aux fontes déjà présentes.',

  }, #/ :recipe

  # --- Bibliographie --- #

  biblio: {

    no_occurrence: "Aucune occurrence pour la bibliographie « %s ».",
    
    intro_assistant: "Nous allons programmer les bibliographies du livre courant",
    has_already_biblio: "Ce livre définit déjà les bibliographies %s.",
    bibs_created_with_success: "Les bibliographies ont été créées avec succès.",
    consigned: "Bibliographie consignée.",

  }, #/ :biblio


  # --- Assistants --- #

  assistant: {

    require_book_folder: "Cet assistant doit être appelé depuis le dossier d'un livre.",

  }, #/assistant


}

MESSAGES[:biblio].merge!(explaination_after_create: <<-TEXT)

Il vous reste quelques petites choses à faire :

Le module FormaterBibliographiesModule du fichier formater.rb doit
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
