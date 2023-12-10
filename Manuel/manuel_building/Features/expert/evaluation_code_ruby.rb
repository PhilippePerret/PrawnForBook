Prawn4book::Manual::Feature.new do

  titre "Évaluation du code ruby"

  description <<~EOT
    Tous les codes qui se trouveront entre `\#{'#'}{...}` seront évalués en tant que code ruby, dans le cadre du livre (c'est-à-dire qu'ils pourront faire appel à des méthodes personnalisées)

    Typiquement, on peut par exemple obtenir la date courante.

    #### Évaluation au second tour

    Certaines opérations ou certains calculs ne peuvent s’opérer qu’au second tour de l’application^^ — typiquement, le nombre de pages du livre —. On utilise alors la tournure suivante pour réaliser ces opérations.
    (( line ))
    (( {align: :left} ))
    {-}`\\#\\{{{"\\#\\{<operation>\\}" if Prawn4book.second_turn\\?}}}`^^
    (( line ))
    Dans le code ci-dessus, le contenu des guillemets ne sera évalué qu’au second tour de l’application. Mais attention, cela peut occasionner un changement des numéros de page si le texte ajouté au second tour est conséquent. Il est donc plus prudent de mettre au premier tour un texte d’environ la longueur du résultat attendu pour ne pas fausser le suivi. Pour le numéro des pages, que nous estimons au départ à plusieurs centaines mais moins d’un millier nous utilisons :
    (( line ))
    (( {align: :left} ))
    {-}`\\#\\{{{ Prawn4book.first_turn\\? \\? "XXX" \\: "\\#\\{book.pages.count\\}" }}}`
    (( line ))
    … qui signifie qu’au premier tour, _PFB_ marquera simplement "XXX" et aux suivants il inscrira le nombre de pages.


    ^^ C’est le cas par exemple de l’impression du nombre de pages de ce manuel dans l’avant-propos, c’est-à-dire alors que le livre est à peine esquissé.
    ^^ Noter ici l’utilisation des trois accolades obligatoires lorsque le code lui-même a recours aux accolades.
    EOT

  sample_texte <<~EOT
    Une opération simple permet de savoir que 2 + 2 est égal à \#{'#'}{2+2} et que le jour courant (au moment de l'impression de ce livre) est le \#{'#'}{Time.now.strftime('%d %m %Y')}.

    EOT
  
  texte <<~EOT
    Une opération simple permet de savoir que 2 + 2 est égal à \#{2+2} et que le jour courant (au moment de l'impression de ce livre) est le \#{Time.now.strftime('%d %m %Y')}.

    EOT

end
