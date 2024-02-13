Prawn4book::Manual::Feature.new do

  titre "Suspendre et reprendre la gravure"


  description <<~EOT
    Quand le livre est long et qu’il nécessite beaucoup de "travail", ça peut prendre plus d’une dizaine de secondes pour le graver (i.e. faire le pdf).
    Quand on veut juste caler une image à un endroit, ça peut devenir long d’attendre chaque fois la gravure complète.
    Les commandes "`(( stop ))`" et "`(( start ))`" rentrent alors en jeu pour se concentrer juste sur un passage. :
    (( line ))
    ~~~
    Ce paragraphe sera traité normalement.

    (( stop ))

    Tout ce qu’il y a après ce "stop" ne sera pas traité, pas gravé, donc ce paragraphe ne sera plus mis dans le livre.
    Ce paragraphe non plus ne sera pas dans le livre.

    (( start ))

    Ce paragraphe, en revanche, sera gravé et la gravure repartira d’ici.
    ~~~
    (( line ))
    On peut bien sûr avoir autant de stop/start que l’on veut, pour se concentrer sur autant de passages que l’on veut.

    #### Précautions et limites de la suspension de gravure

    Bien sûr, vous ne pouvez pas, avec ces commandes, vous concentrer sur l’affichage d’un index ou autre bibliographie, si toutes les références dans le texte sont passées. Il faut qu’il se trouve dans le texte gravé au moins quelques références pour que l’index ou la bibliographie finale affiche quelque chose.

    Bien sûr, si vous voulez régler par exemple la images flottantes d’un passage (pour qu’elles ne soient pas trop en bas de page, dépassantes), il faut vous assurer de prendre suffisamment de texte pour que le passage ne soit pas décalé lorsque tout le texte sera gravé. Arrangez-vous pour prendre un passage qui, au niveau de la mise en page, est complètement indépendant du reste du texte non gravé.

    #### Bloquer les références registrées

    _PFB_ utilise un système qui enregistre les marques de références lorsqu’on les rencontre. Par exemple, dès qu’il rencontre la    marque "`\\<-\\(ma_cible\\)`" il va enregistrer la marque de référence qui sera produite lorsque l’on rencontrera "`->\\(ma_cible\\)`". Par exemple "ma_cible (p. 213)". À chaque actualisation (gravure) du livre, la marque de référence est actualisée pour suivre l’évolution du livre.

    Mais lorsqu’on en arrive à travailler par portion de texte, si on actualise toujours la consignation de ces marques de référence, elles seront erronnées au niveau du numéro de page (ou autre paragraphe suivant la pagination). Par exemple, si on se concentre sur un chapitre XII situé à la page 210, la marque de la cible "`\\<-\\(ma_cible\\)`" deviendra "ma_cible (p.4)" au lieu de "ma_cible (p. 213)", ce qui risquera de modifier la mise en page.
    Pour palier ce problème, on peut demander à _PFB_ de désactiver, provisoirement, la consignation des références. On le fait grâce à l’option "`-no_update_registered_refs`" ou "`nouprefs`" en verson réduite.

    #### Astuce pour retrouver les marques de suspension

    Pour passer en revue rapidement toutes les marques de suspension, il suffit de faire une recherche sur `(( st`.
    EOT

end
