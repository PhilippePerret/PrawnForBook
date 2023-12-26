Prawn4book::Manual::Feature.new do

  sous_titre "Page de garde"


  description <<~EOT
    *Page de garde* est un terme qui trouve dans le langage plusieurs acceptions très différentes et il y a souvent confusion pour savoir de quoi l’on parle. Elle peut être :
    * la couverture d’un rapport (de stage, par exemple, ou de thèse),
    * la toute première page du document, qui sera *collée* au verso de la première de couverture (c’est donc la 2^e de couverture),
    * un page (double page, en fait) située juste avant la *page de titre*, donc entre la (double-)page de *faux-titre* et la (double-)page de *titre*.
    Dans _PFB_, elle concerne la troisième acceptions. Si la page de *faux-titre* est gravée, cette page de garde sera une double page avant la double page de titre, qui empêchera de voir la page de titre par transparence (cela fait donc 3 pages ajoutées — consultez l’annexe, [[annexes/pages_dun_livre]], pour bien comprendre).
    Par défaut, cette *page de garde* n’est pas imprimée dans un livre produit par _PFB_. Pour qu’elle le soit, il suffit de le préciser dans la recette du livre ou de la collection en mettant sa valeur à `true` ("vrai" en anglais) :
      (( line ))
      ~~~yaml
      inserted_pages:
        page_de_garde: true
      ~~~

    EOT

end
