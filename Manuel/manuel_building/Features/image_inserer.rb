Prawn4book::Manual::Feature.new do

  titre "Insérer une image"

  description <<~EOT
    Pour insérer une image dans le flux du livre, on utilise le code pseudo-markdown **`\\!\\[chemin/vers/image]`**. Si des données sont à passer, on utiliser **`\\!\\[vers/image](\\<data>)`** où `\\<data>` est une [[table_ruby]].
    Les formats (jpg, tiff, png, svg)
    Rogner une image svg [[image_rogner_svg]].
    {{TODO: Développer, montrer des exemples}}
    {{TODO: les data}}
    EOT

  sample_texte <<~EOT #, "Autre entête"
    Le texte en exemple. Si 'texte' n'est pas défini, sera interprété aussi. Sinon sera mis en illustration et c'est 'texte' qui sera interprété comme texte du livre.    
    EOT

  texte <<~EOT
    Texte à interpréter, si 'sample_texte' ne peut pas l'être.
    EOT

  sample_recipe <<~EOT #, "Autre entête"
    ---
      # ...
    EOT

end
