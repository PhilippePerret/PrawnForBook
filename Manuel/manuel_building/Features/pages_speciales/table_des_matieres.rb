Prawn4book::Manual::Feature.new do

  titre "La Table des matières"

  description <<~EOT
    On imprime la table des matières à l’endroit voulu à l’aide de la marque :
    **`\(( tdm \))`** pour "T"able "D"es "M"atières
    ou :
    **`\(( toc \))`** pour "T"able "Of" "C"ontent, la table des matières en anglais.

    ##### Table des matières en début d’ouvrage

    Si on inscrit la table des matières en début d’ouvrage, il faut calculer le nombre de pages qu’elle va occuper.

    ##### Table des matières en fin d’ouvrage

    Si on inscrit la table des matières à la fin de l’ouvrage, il n’y a aucune précaution à prendre.
    C’est d’ailleurs ce que l’on fait pour ce manuel, dont on trouve deux tables des matières, une en début d’ouvrage et l’autre en fin d’ouvrage.
    EOT

  # sample_texte <<~EOT #, "Autre entête"
  #   Le texte en exemple. Si 'texte' n'est pas défini, sera interprété aussi. Sinon sera mis en illustration et c'est 'texte' qui sera interprété comme texte du livre.    
  #   EOT

  sample_texte <<~EOT
    \\(( toc ))
    EOT


  # recipe <<~EOT #, "Autre entête"
  #   ---
  #     # ...
  #   EOT

  # # init_recipe([:custom_cached_var_key])

end
