Prawn4book::Manual::Feature.new do

  titre "Page en double-colonnes"

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
    {-}`\\(( colonnes\\(2, 40) ))`

    #### Précaution pour les colonnes

    Attention à toujours terminer par `\\(( colonnes\\(1) ))`, surtout si c’est la dernière page, dans le cas contraire les pages multi-colonnes se seraient pas gravées.
    EOT

  # sample_texte <<~EOT #, "Autre entête"
  #   Le texte en exemple. Si 'texte' n'est pas défini, sera interprété aussi. Sinon sera mis en illustration et c'est 'texte' qui sera interprété comme texte du livre.    
  #   EOT

  texte <<~EOT
    (( colonnes(3) ))
    Juste avant cette ligne on trouve la marque `\\(( colonnes\\(3) ))` qui permet de faire passer ce texte en trois colonnes.
    #{"In mollit anim veniam est ut officia sit mollit est est dolor consequat cillum. " * 20}
    (( colonnes(1) ))
    On revient ensuite à un texte sur une colonne avec la marque `\\(( colonnes\\(1) ))`. Et c’est la fin de l’usage des colonnes multiples, on revient sur une page normale.
    EOT

end
