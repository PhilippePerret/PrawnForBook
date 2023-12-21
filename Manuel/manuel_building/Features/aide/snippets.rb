Prawn4book::Manual::Feature.new do

  titre "Les “Snippets”"


  description <<~EOT
    Les "snippets"^^ (ou *complétions*) sont particulièrement utiles lorsque l’on désire gagner du temps dans la rédaction de son livre (même si, philosophiquement, "gagner du temps" est un concept *contre-artistique*…)
    Ils consistent à taper quelques lettres, parfois une seule, de jouer la touche tabulation, et un texte vient remplacer automatiquement ces lettres.
    Par exemple, si nous avons un personnage qui s’appelle *Rostatopoulos* et que nous ne voulons pas taper chaque fois ce prénom (avec toutes les erreurs de typo possibles…), nous créons un snippet avec la lettre "R" majuscule et chaque fois que nous tapons "R" suivi de la touche tabulation, _PFB_ remplace ce "R" par "Rostatopoulos".

    ^^ Les *snippets* ne sont pas à confondre avec les variables textuelles qui s’écrivent textuellement dans le texte du fichier et seront ensuite remplacées par leur valeur fixe ou dynamique. Un *snippet* est remplacé immédiatement dans le texte par sa valeur définie.

    #### Exclusivement dans Sublime Text

    Mais cette fonctionnalité pratique ne fonctionne que dans un IDE adapté. En l’occurrence, à l’heure où nous écrivons ces lignes, elle ne fonctionne que dans l’application Sublime Text.

    #### Installer les snippets

    Pour pouvoir fonctionner, les snippets doivent être *installés* dans l’éditeur, il ne suffit pas qu’ils soient définis. Chaque fois que vous travaillez sur un nouveau livre, il faut installer les snippets définis.
    On installe ces *snippets* à l’aide de la commande (dans une console ouverte au dossier du livre) :
    (( line ))
    {-}`> pfb install`

    #### Programmer un snippet

    Programmer un snippet est simplissime, il suffit d’appeler la commande **`pfb snippet`**. Si l’on veut gagner du temps, il suffit de lui donner d’abord les lettres à taper (par exemple "R" dans notre exemple) suivi du texte de remplacement ("Rostatopoulos" dans notre exemple). Cela donnera :
    (( line ))
    {-}`> pfb snippet R Rostatopoulos`
    (( line ))
    Si le texte de remplacement contient plusieurs mots, il est indispensable de les mettre entre guillemets.
    (( line ))
    {-}`> pfb snippet R "Rostatopoulos Alexis Triponov"`
    (( line ))

    EOT


end
