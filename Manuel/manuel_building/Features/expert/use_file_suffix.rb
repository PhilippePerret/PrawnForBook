Prawn4book::Manual::Feature.new do

  titre "Utiliser le suffixe du fichier"


  description <<~EOT
    Dans la partie [[format_precis/filename_suffix]], nous avons vu comment ajouter un suffixe au nom de fichier.
    Ce suffixe peut-être utiliser dans les programmes, les méthodes, en invoquant la donnée `Pdfbook.current.filename_suffix` (ou `book.filename_suffix` si `book` est défini).

    #### Exemple de deux utilisations

    ##### Pour le numéro de version

    Nous pouvons utiliser le numéro de version pour suffixer le nom du fichier produit, avec la commande :
    (( line ))
    ~~~
    pfb build -suffix="-v1.2"
    ~~~
    (( line ))
    On peut alors utiliser le code suivant dans un programme pour ajouter la version, par exemple dans une page de titre.
    (( line ))
    ~~~ruby
    version = PdfBook.current.filename_suffix[2..-1]
    # => version = "1.2"
    ~~~
    (( line ))

    ##### Pour produire deux ou plus livres différents

    On peut imaginer par exemple de faire un livre pour macOs et un livre pour PC/Windows sans avoir à produire deux fichier `pfb.md` différents (et surtout être obligé de les tenir à jour en même temps).
    Dans ce cas, on peut imaginer utiliser un suffixe qui contiendra la version à produire. Par exemple `mac` ou `pc` dans :
    (( line ))
    ~~~bash
    pfb build -suffix="-mac"
    ~~~
    (( line ))
    Dans le programme, il suffira de récupérer la version du livre à faire avec :
    (( line ))
    ~~~ruby
    version_livre = book.filename_suffix == "-mac" ? :mac : :windows
    ~~~
    (( line ))
    EOT

end
