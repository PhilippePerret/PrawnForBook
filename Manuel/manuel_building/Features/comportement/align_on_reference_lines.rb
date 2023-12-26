Prawn4book::Manual::Feature.new do

  hline = 30

  titre "Alignement sur la grille de référence"

  show_grid(1..-1)
  line_height hline
  new_page_before(:texte)

  description <<~EOT
    De façon naturelle et sans aucune intervention de l’auteur ou du metteur en page, les lignes de texte sont automatiquement alignées sur une ce qu’on appelle une *grille de référence* qui produit un affichage professionnel.

    Cette grille de référence ne dépend que du paramètre `line_heigth` ("hauteur de ligne" en anglais) dans la recette — voir [[texte_detail/hauteur_de_ligne]].

    Note : pour l’exemple, nous avons demandé l’affichage de la *grille de référence* — voir [[aide/afficher_grille_reference_et_marges]] afin de constater par vous-même que les lignes de texte sont effectivement parfaitement alignées, malgré le changement de taille de la police.
    EOT

  first_font_size = 20

  texte <<~EOT
    (( font(name:"Numito", size:#{first_font_size}, style: :normal) ))
    Un premier paragraphe dans une police de taille #{first_font_size} alors que la hauteur de ligne est réglée ici à #{hline}.
    
    (( font(name:"Numito", size:8, style: :normal) ))
    Un autre paragraphe dans une police de taille. Lorem #{'ipsum lorem ipsum ' * 60}
    \#{-pdf.update_current_line}
    (( new_page ))
    EOT

end
