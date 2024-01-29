Prawn4book::Manual::Feature.new do


  subtitle "Poids des occurrences"

  description <<~EOT
    Que ce soit pour les index — général ou personnalisés — ou pour les bibliographies, nous pouvons, comme nous l’avons mentionné, indiquer le poids des occurrences en plaçant un point d’exclamation après la parenthèse ouverte pour une occurrence importante ou en plaçant un point pour une occurrence de moindre importance.
    Ce fichier montre comment on peut personnaliser le résultat en fin de livre.
    EOT

  real_texte <<~EOT
    Sur la première page, je fais une référence de poids normal au livre book(dracula).
    Je fais aussi une référence de poids normal à book(l’assomoir).
    Et enfin, puisque cette page contient une référence au trois livres, une référence aussi à book(notre dame de paris).
    J’indexe aussi le mot index(bibliothèque) sans poids.
    (( new_page ))
    Sur la deuxième page, une référence importante au livre book(!notre dame de paris) en utilisant son titre.
    (( new_page ))
    une book(.référence mineur au film précédent|notre dame de paris) mais sans utiliser son titre.
    Je parle surtout de book(!l’assomoir) dans la page trois.
    (( new_page ))
    À la page 4 se trouve une book(.référence mineure|l’assomoir) au livre de Zola mais sans citer son nom.
    Le mot index(!bibliothèque) est ici très important.
    Et je mets aussi une référence mineure au mot index(.bibliothèque) dans la même page, pour avoir les deux. C’est la première qui l’emporte.
    (( new_page ))
    Une référence faible au mot index(.bibliothèque) à la page 5. Mais il y a deux références à index(.bibliothèque).
    Pour voir si le poids le plus fort le remporte, on met ici une référence faible au mot index(.bout en train) et ici une index(référence normale|bout en train).
    (( biblio(book) ))
    (( index ))
    EOT
  real_recipe <<~EOT
    ---
    bibliographies:
      book:
        title: Livres
        path: assets/biblios/books
        picto: book
        format: "%{title} (%{author|monauteur})"
        number:
          font: "Helvetica/italic/9/555555"
          main: 
            font: "Helvetica/bold/10/000000"
          minor:
            font: "Helvetica/light/8/999999"

    inserted_pages:
      #
      # Aspect pour la page d’index
      #
      page_index:
       aspect:
          canon: "//14/007700"
          number:
            font: "Helvetica/italic/9/555555"
            main: 
              font: "Helvetica/bold/9.5/000000"
            minor:
              font: "Helvetica/italic/8.5/999999"
      #
      #
      #
      page_de_garde: false
      page_de_titre: false
      faux_titre: false
    EOT

  texte <<~EOT
    La page de bibliographie, à la fin du livre, ressemblera à :
    ![page-8](width:"70%")
    La page d’index ressemblera à :
    ![page-12](width:"70%")
    (( new_page ))
    EOT


end
