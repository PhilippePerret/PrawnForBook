Prawn4book::Manual::Feature.new do

  titre "Ajouter un suffixe au nom du fichier livre"


  description <<~EOT
    Par défaut, le nom du livre gravé (i.e. du fichier PDF) porte le nom `book.pdf`.
    On peut lui ajouter un suffixe à l’aide de l’option de commande `-suffix="<suffixe à ajoute>"`.
    Par exemple, si la commande est :
    (( line ))
    ~~~bash
    pfb build -suffix="-mon_suffixe"
    ~~~
    (( line ))
    … alors le nom du fichier `.pdf` sera `book-mon_suffixe.pdf`.

    EOT

end
