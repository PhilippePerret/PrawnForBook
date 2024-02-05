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

    Bien sûr, si vous voulez régler par exemple la images flottantes d’un passage (pour qu’elles ne soient pas trop en bas de page, dépassantes), il faut vous assurer de prendre suffisamment de texte pour que le passage ne soit pas décalé lorsque tout le texte sera gravé. Arrangez-vous pour prendre un passage qui, au niveau de la mise en page, est complètement indépendant du texte non gravé.
    EOT

end
