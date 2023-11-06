Prawn4book::Manual::Feature.new do

  # bigtitle "Mode Expert"

  titre "Recette modifiée à la volée"


  description <<~EOT
    On utilise `(( recipe(<hash>) ))` sur une ligne pour modifier la recette à la volée.
    Les clés de <hash> doivent être des variables mises en cache (donner le path du fichier recipe_data.rb)
    C’est un deep_merge qui est utilisé, donc il n’y a pas besoin de tout remettre dans le hash, mais seulement ce qui a été modifié
    EOT

  sample_texte <<~EOT
    EOT

  texte <<~EOT
    EOT

end
