Prawn4book::Manual::Feature.new do

  titre "Injection"

  description <<~EOT
    **`book.inject(pdf, string, idx, self)`** est vraiment la formule magique pour ajouter du contenu au livre. L’avantage principale de cette méthode est d’analyser précisément le type de contenu — représenté ici par `string` — et de le traiter conformément à son type. Par exemple :
    * si `string` est `\\"![images/mon.svg]\\"`, alors ce sera une image qui sera traitée,
    * si `string` est `\\"### Mon beau titre\\"` alors c’est un titre qui sera inséré,
    * si `string` est `\\"(( new_page ))\\"` alors on passera à la nouvelle page^1.

    ^1 Bien sûr, ici, dans le programme, on pourrait utiliser `pdf.start_new_page`, mais l’idée derrière l’utilisation de `book.inject(.\\..)` est de pouvoir utiliser le même code que dans le livre. Inutile d’apprendre une nouvelle langue ou de fouiller dans le code du programme pour savoir comment exécuter telle ou telle action.
    (( line ))
    **`idx`** correspond à l’index du paragraphe dans la source injectée, il n’a de valeur que pour le débuggage. Dans le programme, il correspond par exemple au numéro de ligne dans le fichier. On pourra l’utiliser comme l’on veut.
    (( line ))
    **`self`** correspond dans le programme à l’instance du fichier de texte (`Prawn4book::InputTextFile`). On peut le définir comme tel si le code injecté vient d’un fichier (même si, dans ce cas, il vaudrait mieux utiliser tout simplement la `string` : `(( include mon/fichier.md ))`). Si elle n’est pas fourni, elle sera égale à `"user_metho"`.
    {{TODO: Développer encore}}
    EOT

end
