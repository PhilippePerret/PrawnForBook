Prawn4book::Manual::Feature.new do


  subtitle "Poids des occurrences"

  description <<~EOT
    Que ce soit pour les index — général ou personnalisés — ou pour les bibliographies, nous pouvons, comme nous l’avons mentionné, indiquer le poids des occurrences en plaçant un point d’exclamation après la parenthèse ouverte pour une occurrence importante ou en plaçant un point pour une occurrence de moindre importance.
    Ce fichier montre comment on peut personnaliser le résultat en fin de livre.
    EOT

  real_texte <<~EOT
    Sur la première page, je fais une référence de poids normal au livre book(dracula).
    Je fais aussi une référence de poids normal à book(l’assomoir).
    (( new_page ))
    Sur la deuxième page, une référence importante au livre book(!notre dame de paris) en utilisant son titre.
    (( new_page ))
    une book(.référence mineur au film précédent|notre dame de paris) mais sans utiliser son titre.
    Je parle surtout de book(!l’assomoir) dans la page trois.
    (( new_page ))
    À la page 4 de trouve une book(.référence mineure|l’assomoir) au livre de Zola mais sans citer son nom.
    (( biblio(book) ))
    EOT
  real_recipe <<~EOT
    ---
    bibliographies:
      book:
        title: Livres
        path: assets/biblios/books

    inserted_pages:
      #
      # Aspect pour la page d’index
      #
      page_index:
       aspect:
          canon: "//14/007700"
          number:
          font: "Courier/italic/9/555555"
          main: 
            font: "Courier/bold/9.5/000000"
          minor:
            font: "Courier/italic/8.5/999999"
      #
      #
      #
      page_de_garde: false
      page_de_titre: false
      faux_titre: false
    EOT

  texte <<~EOT
    ![page-1]
    ![page-2]
    ![page-3]
    ![page-4]
    ![page-5]
    ![page-6]
    (( new_page ))
    EOT


end
