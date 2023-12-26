Prawn4book::Manual::Feature.new do 

  titre "Export comme document PDF"

  description <<~EOT
    Bien que _PFB_ soit principalement pensé pour produire un PDF pour l'imprimerie, on peut également s'en servir pour produire un fichier PDF numérique (comme ce manuel par exemple).
    Les différences sont les suivantes :
    * les liens seront interactifs (quand on clique sur un renvoi, on rejoint ce renvoi),
    * les adresses internet externes sont activables (quand on clique sur l’adresse, on rejoint le site dans son navigateur),
    * **la table des matières est interactive**, il suffit de cliquer sur un titre pour rejoindre la partie.

    Pour déterminer l'export en livre numérique, il faut agir sur la donnée `book_format: book: format:` en mettant sa valeur à `pdf`.

    *(le format normal est `publishing`)*
    EOT

  sample_recipe <<~EOT
    ---
    book_format:
      book:
        format: pdf
    EOT
end
