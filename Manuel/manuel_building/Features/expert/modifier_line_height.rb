Prawn4book::Manual::Feature.new do

  titre "Modification de la hauteur de ligne"


  description <<~EOT
    En tant qu’expert, vous pouvez modifier localement la hauteur de ligne (`line_height`) de deux façons.
    Noter cependant que cette modification n’est pas à prendre à la légère puisqu’elle va bousculer l’harmonie des lignes du livre. Elle doit se faire en priorité sur une *belle page* (une page de gauche, paire) afin que les lignes des pages en vis à vis restent alignées et se réserver à l’annexe du livre, par exemple, ou à la page des index, quand des tailles de police plus petites sont utilisées.

    #### Modification de la hauteur de ligne dans le texte

    Au fil du texte, la hauteur de ligne peut être redéfinie avec :
    (( line ))
    ~~~pfb
    (( line_height(<nouvelle hauteur>, {fname:<police>, fsize:<taille>, fstyle:<style>}) ))
    ~~~
    (( line ))
    Par exemple :
    (( line ))
    ~~~pfb
    (( line_height(10, {fname:'Garamond', fsize:9, fstyle:'normal'}) ))
    ~~~
    (( line ))


    #### Modification de la hauteur de ligne par formateur

    On peut appeler une méthode définie dans `prawn4book.rb` par exemple :
    (( line ))
    ~~~ruby
    # ./prawn4book.rb
    module Prawn4book

      def redefinir_hauteur_de_ligne(pdf, valeur)
        pdf.line_height = valeur
        Fonte.default = ...
      end

    end
    ~~~
    (( line ))
    Et dans le texte par exemple (mais cette méthode pourrait être appelée de n’importe où) :
    (( line ))
    Un texte quelconque.\\#\\{redefinir_hauteur_de_ligne\\(10)}

    EOT



end
