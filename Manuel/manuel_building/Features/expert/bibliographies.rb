Prawn4book::Manual::Feature.new do

  titre "Bibliographies en mode expert"


  description <<~EOT
    TODO: Décrire comment faire une méthode de formatage propre dans `Prawn4book::Bibliography` (méthode d’instance) pour l’utiliser dans la liste des sources, pour une propriété particulières. Si, par exemple, la donnée `format` de la bibliographie (dans la recette), définit :
     `%{title|mon_transformeur}` 
    … alors il faut définir la méthode :
     `Prawn4book::Bibliography#mon_tranformeur` 
    … qui reçoit en argument la valeur de :title de l’item.

    TODO: Montrer qu’on peut par exemple définir une font et/ou une couleur propre comme pour la bibliographie `costume`
    EOT

end
