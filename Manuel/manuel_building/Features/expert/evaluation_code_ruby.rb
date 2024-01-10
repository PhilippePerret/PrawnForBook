Prawn4book::Manual::Feature.new do

  titre "Évaluation du code ruby"

  description <<~EOT
    Tous les codes qui se trouveront entre "`\\#\\{..\\.}`" (ou entre "`\\#\\{\{\{.\\..}}}`" lorsque le code contient des accolades) seront évalués en tant que code ruby, dans le cadre du livre (c'est-à-dire qu'ils pourront faire appel à des méthodes personnalisées).
    Typiquement, on peut par exemple obtenir la date courante ou le numéro de version du livre pour l’insérer dans les premières pages à titre de repère, comme vous pouvez le voir dans l’exemple ci-dessous.

    #### Code ruby sans retour chariot

    Pour le moment, on ne peut pas utiliser de retours chariot dans le code ruby à évaluer. Les remplacer par des points virgules pour utiliser plusieurs lignes. Par exemple :
     `Ce code \\#\\{n = 3; 12.times do |i|; n += i; end\\}` 

    #### Utilisation unique des triples accolades

    Noter que contrairement à l’utilisation simple `\\#\\{..\\.}` qu’on peut trouver plusieurs fois par paragraphe, l’utilisation des triples accolades `\\#\\{\\{{..\\.}\\}}` ne doit se faire impérativement qu’une seule fois dans un même paragraphe.

    #### Retour du code

    Il faut garder en tête que le retour du code produit s’inscrit dans la page. Si vous voulez exécuter une opération qui ne doit pas produire de texte à inscrire, vous avez la solution…
    … soit d’ajouter `nil` ou `""` à la suite du code (après ";" évidemment) :
     `ce code \\#\\{2 + 2;nil} n’écrira rien.`
    … soit de commencer le code par le signe moins :
     `ce code \\#\\{\\- 2 + 2} n’écrira rien.`

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
    J’utilise actuellement la version \\\#{RUBY_VERSION} de ruby. Une opération simple permet de savoir que 2 + 2 est égal à \#{'#'}{2+2} et que le jour courant (au moment de l'impression de ce livre) est le \#{'#'}{Time.now.strftime('%d %m %Y')}. Je suis juste un calcul sans écriture\\\#{\\- 2 + 2}.

    EOT
  
  texte <<~EOT
    J’utilise actuellement la version \#{RUBY_VERSION} de ruby. Une opération simple permet de savoir que 2 + 2 est égal à \#{2+2} et que le jour courant (au moment de l'impression de ce livre) est le \#{Time.now.strftime('%d %m %Y')}. Je suis juste un calcul sans écriture\#{- 2 + 2}.

    EOT

end
