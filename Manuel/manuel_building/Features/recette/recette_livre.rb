Prawn4book::Manual::Feature.new do

  subtitle "Recette du livre"

  description <<~EOT
    La *recette du livre* du livre est un fichier de nom `recipe.yaml` qui se trouve à la racine du dossier du livre. Son nom vient de "recipe" qui signifie *recette* en anglais et de `.yaml`, extension des fichiers au format simple `YAML` (cf. page [[annexe/format_yaml]]).
    EOT


  sample_recipe <<~EOT #, "Autre entête"
    ---
    #<book_data>
    # .\\..
    #</book_data>

    #<book_format>
    # .\\..
    #</book_format>
  EOT

end
