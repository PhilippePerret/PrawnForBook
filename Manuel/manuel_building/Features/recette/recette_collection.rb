Prawn4book::Manual::Feature.new do

  # new_page_before(:feature)

  titre "Recette de la collection"

  description <<~EOT
    La *recette de la collection* est un fichier de nom `recipe_collection.yaml` qui se trouve à la racine du dossier d’une collection de livres. Son nom vient de "recipe" qui signifie *recette* en anglais et de `.yaml`, extension des fichiers au format simple `YAML` (cf. page [[annexe/format_yaml]]).
    Vous pouvez trouver ci-dessous les données propres à une collection. 
    EOT

  recipe <<~YAML #, "Autre entête"
    ---
    # (données de la collection)
    collection:
      name: "Nom de la collection"
      short_name: "Nom raccourci (pour les messages)"
    #/collection
    # .\\..
    YAML

end
