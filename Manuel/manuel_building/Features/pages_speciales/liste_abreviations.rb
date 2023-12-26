Prawn4book::Manual::Feature.new do

  titre "Liste des abréviations"


  description <<~EOT
    La *liste des abréviations*, qui donne la liste de toutes les abréviations utilisées dans le livre et leur signification, s’affichera dans le livre en utilisant une des marques suivantes :
    * `\\(( list_of_abbreviations ))`,
    * `\\(( loa ))`,
    * `\\(( liste_des_abreviations ))`,
    * `\\(( lda ))`.
    Cela produit — par défaut — une table comme celle ci-dessous.
    Si cette table se place traditionnellement après la table des matières ou la table des illustrations si elle existe, le fait qu’on l’insère dans un livre _PFB_ par une marque signifie qu’on peut l’introduire à l’endroit que l’on veut, à la fin du livre par exemple.

    #### Définition des abréviations

    EOT

  sample_texte <<~EOT
  \\(( lda ))
  EOT

  texte(:as_sample)

end
