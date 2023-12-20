Prawn4book::Manual::Feature.new do

  titre "Page en multi-colonnes"

  description <<~EOT
    On peut provisoirement passer en double colonnes grâce à la marque :
    (( line ))
    {-}`\\(\\( colonnes\\(2) ))`
    (( line ))
    Pour arrêter d’être en double colonnes, il suffit d’utiliser :
    (( line ))
    {-}`\\(( colonnes\\(1) ))`
    (( line ))
    Vous l’aurez déjà compris, grâce à cette marque, on peut avoir autant de colonnes que l’on désire.

    #### Définition plus précise des colonnes

    On peut définir la goutière (espace entre chaque colonne) grâce à la propriété `gutter` à mettre en deuxième paramètre :
    (( line ))
    {-}`\\(( colonnes\\(2, gutter: 40) ))`
    (( line ))
    On peut définir aussi sur quelle largeur les colonnes devront tenir, par exemple la moitié de la page :
    {-}`\\(( colonnes\\(2, width: PAGE_WIDTH/2) ))^^`
    (( line ))
    ^^ Vous remarquez ci-dessus l’utilisation d’une constante (cf. [[annexe/constantes]]).

    #### Précaution pour les colonnes

    Attention à toujours terminer par `\\(( colonnes\\(1) ))`, surtout si c’est la dernière page, dans le cas contraire les pages multi-colonnes ne seraient pas gravées.
    EOT

  # sample_texte <<~EOT #, "Autre entête"
  #   Le texte en exemple. Si 'texte' n'est pas défini, sera interprété aussi. Sinon sera mis en illustration et c'est 'texte' qui sera interprété comme texte du livre.    
  #   EOT

  texte <<~EOT
    Un premier paragraphe qui commence en simple colonne. Juste sous ce paragraphe, on a inscrit le code (invisible ici) : `\\(( colonnes\\(3) ))` qui permet de passer la suite en triple colonnes.
    (( colonnes(3) ))
    Début du texte. #{"In mollit anim veniam est ut officia sit mollit est dolor consequat cillum. " * 20} Fin du texte.
    (( colonnes(1) ))
    On revient ensuite à un texte sur une colonne avec la marque `\\(( colonnes\\(1) ))`. Et c’est la fin de l’usage des colonnes multiples, on revient sur une page normale.
    La double colonne suivante est obtenue quant à elle grâce au code : `\\(( colonnes\\(2, width:PAGE_WIDTH/1.5, gutter:50) ))` qui est placé juste sous cette ligne.
    (( colonnes(2, width:PAGE_WIDTH/1.5, gutter:50) ))
    Début du texte. #{"In mollit anim veniam est ut officia sit mollit est dolor consequat cillum. " * 10}. Fin du texte.
    (( colonnes(1) ))
    On revient à nouveau à un texte sur une colonne avec la marque `\\(( colonnes\\(1) ))`.
    EOT

end
