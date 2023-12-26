Prawn4book::Manual::Feature.new do

  titre "Table des illustrations"


  description <<~EOT
    La *table des illustrations* présente la table des matières de toutes les images, graphiques et autres illustrations utilisés dans le livre, avec le numéro de page où on les trouve.
    Pour afficher cette table, qu’on placera en général juste après la [[pages_speciales/table_des_matieres]] en début de livre, on utilise un des marques suivantes :
    * `\\(( table_des_illustrations ))`,
    * `\\(( tdi ))`,
    * `\\(( list_of_illustrations ))`,
    * `\\(( loi ))`.
    Cela produit — par défaut — une table comme celle ci-dessous.
    Si cette table se place traditionnellement après la table des matières, le fait qu’on l’insère dans un livre _PFB_ par une marque signifie qu’on peut l’introduire à l’endroit qu’on veut, à la fin du livre par exemple.
    EOT

  sample_texte <<~EOT
  \\(( tdi ))
  EOT

  texte(:as_sample)

end
