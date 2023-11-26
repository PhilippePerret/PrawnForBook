Prawn4book::Manual::Feature.new do

  titre "Éditeur / Maison d’édition"

  description <<~EOT
    L’éditeur du livre ("publisher" en anglais) ou la maison d’édition se définissent dans la propriété `publisher` de la recette du livre ou de la collection.
    On peut définir toutes les données utiles
    EOT

  sample_recipe <<~EOT #, "Autre entête"
    ---
    publisher:
      name: "<Éditeur / Maison d’édition>"
      adresse: "<Numéro rue\\nCode Ville>"
      contact: "<contact@chez.lui>"
      url: "https://<url/site>"
      logo_path: "chemin/vers/logo"
    EOT

  # init_recipe([:custom_cached_var_key])

end
