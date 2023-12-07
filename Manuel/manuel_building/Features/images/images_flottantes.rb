Prawn4book::Manual::Feature.new do

  titre "Images flottantes"


  description <<~EOT
    Cette partie décrit comment obtenir une image flottante dans le texte.
    Cette image est définie en mettant son `float` ("flottant") à `:left` ("gauche") ou `:right` ("droite"). Note : on ne permet pas l’utilisation d’une image flottante au milieu, ce qui ne se fait jamais dans un livre qui n’est pas purement graphique.
    Le texte à enrouler autour de l’image est mis au-dessus de l’image et précédé d’un point d’exclamation. 

    ##### Positionnement exact de l’image

    On peut déterminer le positionnement exact de l’image de façon générale, dans le recette (pour que toutes les images disposent de la même présentation) ou pour chaque image en particulier en définissant les paramètres `float_top` (hauteur de l’image par rapport à la hauteur du texte)

    {{TODO: montrer comment une valeur négative pour :float_top permet de commencer l’image au-dessud du texte
      - montrer comment une valeur négative pour :right (quand c’est le flottement à gauche qui est demandé) permet de couvrir l’image
      - montrer comment un texte plutôt court n’écrit aucune ligne sous l’image
      - montrer comment un texte long écrit ses lignes sous l’image
      - montrer comment un texte long écrit ses lignes sous l’image mais en tenant compte du :float_bottom
      - montrer comment un left_margin éloigne de la marge gauche pour un float: :left
      - montrer comment un right_margin éloigne le texte de l’image
        pour un float: :left
      - montrer qu’il y a toujours une valeur par défaut pour le
        right_margin (quand float: :left) et le left_margin quand
        float: :right
      - montrer comment jouer sur left_margin et right_margin, avec les deux float, pour position l’image exactement où l’on veut et montrer l’incidence que ça peut avoir sur le texte (en montrant comment le texte s’adapte à ces valeurs)
      - voir comment les choses se passent quand on arrive en bas de page (par exemple, le cas piège serait celui où un peu de texte doit rester sur la page précédente et l’image doit passer à la page suivante)
      - montrer comment deux paragraphes courts, mais précédés de "!", s’enroulent autour de l’image. Contre : deux paragraphes courts, mais dont le deuxième n’est précédé de "!".

    }}
    EOT

  new_page_before(:sample_texte)

  sample_texte <<~EOT #, "Autre entête"
    \\!Un texte qui va simplement se placer à droite de l’image, sans dépasser ni en haut ni en bas.
    \\!\\[exemples/moins_large_border.jpg](float: :left, width: 100)
    \\(( line \\))
    \\!Texte placé à gauche d’une image qui porte le float à :right (flottante à droite) et le :width à 100.
    \\!\\[exemples/moins_large_border.jpg](float: :right, width: 100)
    \\(( line \\))
    \\!Un texte qui va commencer au-dessus de l’image, sur deux lignes, puis s’enrouler à droite de l’image pour repasser ensuite ses dernières lignes sous l’image. Aucune marge n’est ajouté à gauche (`left: 0`) et une marge de 10 est définie entre l’image et le texte (`right: 10`).
    \\!\\[exemples/moins_large_border.jpg](float: :left, floating_top: 30, width: 100, margin_left: 0, margin_right: 2)
    EOT

  texte(:as_sample)

end
