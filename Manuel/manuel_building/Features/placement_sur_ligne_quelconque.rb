Prawn4book::Manual::Feature.new do

  titre "Placement sur une ligne quelconque"

  new_page_before(:feature)

  description <<~EOT
    Grâce aux code *pfb* on peut se placer sur une ligne quelconque du texte à l'aide des méthodes `move_to_line(x)`.
    EOT

  sample_texte <<~EOT
    Le code ci-dessous permet de placer le paragraphe sur la dernière ligne de la page.
    \\(\\( move_to_line(-1) ))
    Ce paragraphe est placé sur la dernière ligne.
    EOT

  texte <<~EOT
    Le code ci-dessous permet de placer le paragraphe sur la dernière ligne de la page.
    (( move_to_line(-1) ))
    Ce paragraphe est placé sur la dernière ligne.
    EOT

end
