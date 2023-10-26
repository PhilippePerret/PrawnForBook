Prawn4book::Manual::Feature.new do

  hline = 30

  titre "Alignement sur la grille de référence"

  description <<~EOT
    De façon naturelle et sans aucune intervention de l'auteur ou du metteur en page, les lignes de texte sont alignées sur une tt(grille de référence) ce qui permet un affichage professionnel.

    Cette grille de référence ne dépend que du paramètre `:line_heigth` (hauteur de ligne) dans la recette.

    Note : pour l'exemple, nous avons demandé l'[affichage de la tt(grille de référence)](#afficher_grille_reference_et_marges) afin de voir que les lignes de texte sont effectivement parfaitement alignées, malgré le changement de taille de la police.
    EOT

  texte <<~EOT
    <font name="Numito" size="14">Un premier paragraphe dans une police de taille 14 alors que la hauteur de ligne est réglée ici à #{hline}.</font>
    <font name="Numito" size="8">Un autre paragraphe dans une police de taille. Lorem #{'ipsum lorem ipsum'*30}</font>
    EOT

  recipe <<~YAML
    ---
    book_format:
      page:
        show_grid: true
      text:
        line_height: #{hline}
    YAML

end
