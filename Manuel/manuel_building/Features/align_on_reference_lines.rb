Prawn4book::Manual::Feature.new do

  hline = 30

  titre "Alignement sur la grille de référence"

  show_grid(1..-1)
  line_height hline
  new_page_before(:texte)

  description <<~EOT
    De façon naturelle et sans aucune intervention de l'auteur ou du metteur en page, les lignes de texte sont alignées sur une tt(grille de référence) ce qui permet un affichage professionnel.

    Cette grille de référence ne dépend que du paramètre `:line_heigth` (hauteur de ligne) dans la recette.

    Note : pour l'exemple, nous avons demandé l'[affichage de la tt(grille de référence)](#afficher_grille_reference_et_marges) afin de voir que les lignes de texte sont effectivement parfaitement alignées, malgré le changement de taille de la police.
    EOT

  first_font_size = 20

  texte <<~EOT
    (( font(name:"Numito", size:#{first_font_size}, style: :normal) ))
    Un premier paragraphe dans une police de taille #{first_font_size} alors que la hauteur de ligne est réglée ici à #{hline}.
    
    (( font(name:"Numito", size:8, style: :normal) ))
    Un autre paragraphe dans une police de taille. Lorem #{'ipsum lorem ipsum ' * 60}
    EOT

end
