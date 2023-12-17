Prawn4book::Manual::Feature.new do

  titre "Manuel et autres aides"

  description <<~EOT
    Tout au long de la conception de son livre — et sa production — on peut obtenir de l’aide sur _PFB_ de plusieurs façon.
    La façon la plus complète consiste à ouvrir ce *manuel autoproduit* qui contient l’intégralité des fonctionnalités de _PFB_ expliquées de façon détaillée. C’est incontestablement **la bible de l’application**. Pour l’ouvrir, il suffit de jouer :
    {-}`> pfb manuel`
    (( line ))
    On peut obtenir une aide beaucoup plus succincte, rappelant les commandes de base, en jouant au choix l’une de ces commandes :
    {-}`> pfb`
    {-}`> pfb aide`
    {-}`> pfb -h`
    {-}`> pfb --help`

    #### Aide _PFB_ en ligne de commande

    On peut obtenir une aide rapide sur un sujet donné, ou un mot, ou une fonctionnalité, en développant la commande `pfb aide` :
    (( line ))
    {-}`> pfb aide "le mot ou l’expression recherché"`
    (( line ))
    Après avoir lancé cette commande, _PFB_ affiche tous les endroits du manuel qui contiennent l’expression recherchée (par pertinence) et permet de développer le passage.

    #### Rechercher régulière dans l’aide

    On peut même faire une recherche *régulière* avec une *expression rationelle* (si vous ne comprenez pas, cette fonctionnalités n’est peut-être pas pour vous…). L’expression rationnelle se trouvera entre guillemets et commencera et et terminera avec une balance ("/").
    (( line ))
    {-}`> pfb aide "/<expression à rechercher>/"`
    (( line ))
    Quelques exemples :
    * Pour rechercher deux mots qui doivent se trouver dans la même phrase, et dans l’ordre donnée : `pfb aide "/mot1(.+?)mot2/"`.
    * Pour chercher plusieurs mots : `pfb aide "/(mot1|mot2)/"`.
    * Pour chercher un mot exact, mais qui peut être au pluriel : `pfb aide "/\\\\bmots?\\\\b/"` (le `\\\\b` désigne un délimiteur de mots).

    EOT

end
