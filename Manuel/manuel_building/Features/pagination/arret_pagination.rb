Prawn4book::Manual::Feature.new do

  titre "Suspension de la pagination"

  description <<~EOT
    Il est nécessaire parfois de suspendre la pagination sur quelques pages. Nous l’avons vu par exemple pour la *page de dédicace* (->(page_dedicace)).
    Pour ce faire, il suffit d’utiliser, seul sur une ligne, les marques `\\(( stop_pagination ))` pour interrompre la pagination et la marque `\\(( restart_pagination ))` pour la reprendre ("restart" signifie "redémarrer" en anglais).
    EOT

  texte <<~EOT
    Ci-dessous nous allons utiliser la marque `\\(( stop_pagination ))` sur une ligne pour interrompre la pagination puis la marque `\\(( new_page ))` sur une autre ligne pour passer sur la page suivante^^.
    ^^ Noter que c’est au moment de la création de la page que _PFB_ doit savoir qu’il ne doit pas numéroter la page. Si la marque `\\(( new_page ))` était placée *avant* la marque `\\(( stop_pagination ))`, alors la nouvelle page créée par la première marque serait numérotée. De la même manière, la marque `\\(( restart_pagination ))` doit être placée *avant* la marque `\\(( new_page ))` pour que la nouvelle page créée soit numérotée.
    (( stop_pagination ))
    (( new_page ))
    (( move_to_line(18) ))
    (( {size: 20, align: :center, color: 'FF0000'} ))
    Cette page ne doit pas être numérotée.
    (( restart_pagination ))
    (( new_page ))
    EOT
    # NOTE : Attention : on ne peut pas vraiment faire une vraie
    # simulation, du fait que ce n’est pas vraiment le texte en flux
    # normal. Donc si on met plusieurs pages, par exemple, on se
    # retrouve avec d’autres pages encore après qui n’ont pas de
    # pagination non plus. Alors qu’en mode réel, tout fonctionne
    # bien.

end
