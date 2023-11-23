Prawn4book::Manual::Feature.new do

  titre "Recette du livre"

  description <<~EOT
    La *recette du livre* du livre est un fichier de nom `recipe.yaml` qui se trouve à la racine du dossier du livre. Son nom vient de "recipe" qui signifie *recette* en anglais et de `.yaml`, extension des fichiers au format simple `YAML` (cf. page [[annexe/format_yaml]]).
    Vous pouvez voir ci-dessous un extrait du fichier recette de ce manuel (qui a bien sûr été produit par _PFB_).
    EOT


  sample_recipe <<~EOT, "Extrait de fichier recette"
    ---
    #<book_data>
    book_data:
      title:    "Manuel de Prawn-for-book"
      author:   "Philippe PERRET"
      version:  1.3
      isbn:     null
      # .\\..
    #</book_data>

    #<book_format>
    book_format:
      book:
        width: '210cm'
        height: '297cm'
        orientation: portrait
        format: :pdf
    # .\\..
  EOT

end
