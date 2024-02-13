Prawn4book::Manual::Feature.new do

  titre "TITRE"

  subtitle "SOUS-TITRE"

  description <<~EOT
    La description
    EOT

  sample_texte <<~EOT #, "Autre entête"
    Le texte en exemple. Si 'texte' n'est pas défini, sera interprété aussi. Sinon sera mis en illustration et c'est 'texte' qui sera interprété comme texte du livre.    
    EOT

  texte <<~EOT
    Texte à interpréter, si 'sample_texte' ne peut pas l'être.
    EOT

end
