Prawn4book::Manual::Feature.new do

  titre "Exportation du texte"


  description <<~EOT
    Pour corriger orthographiquement le texte, par exemple avec Antidote, on peut bien sûr prendre le texte du fichier `texte.pfb.md` en faisant abstraction de tout ce qui relève de la mise en forme et des codes éventuels.
    Mais lorsque ces codes "extra-texte" représentent une quantité non négligeable, il est préférable de procéder à un export du seul texte du livre.
    Pour se faire, il suffit de jouer la construction du livre avec l’option `-t`.
    (( line ))
    ~~~
    > cd chemin/vers/mon/livre
    > pfb build -t
    ~~~
    
    (( line ))
    Le texte seul du livre est alors mis dans un fichier `only_text.txt` ("seulement le texte" en anglais) à la racine du livre. C’est ce fichier qu’il faut corriger.
    EOT

end
