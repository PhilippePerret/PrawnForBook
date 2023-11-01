Prawn4book::Manual::Feature.new do

  titre "Pagination"


  description <<~EOT
    Par défaut, la *pagination* du livre est automatique et *intelligente*. C'est-à-dire qu'elle ne numérote que les pages qui doivent l'être :
    * ne numérote pas les pages vierges (blanches),
    * ne numérote pas les pages ne contenant qu'un titre,
    * ne numérote pas certaines pages communes comme la table des matières, la pages des informations de fin de livre ou la page de faux titre.

    Comme pour tous les comportements par défaut de ***Prawn-For-Book***, il est possible de les modifier en jouant sur les paramètres de la recette.
    EOT

end
