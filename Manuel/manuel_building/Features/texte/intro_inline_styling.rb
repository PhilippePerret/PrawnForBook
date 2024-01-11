Prawn4book::Manual::Feature.new do

  titre "Introduction à la stylisation en ligne"

  description <<~EOT
    _PFB_ offre une fonctionnalité très puissante, nommée "stylisation en ligne" ("inline styling" en anglais), qui permet de définir localement n’importe quel paragraphe au niveau de son aspect, de son style.
    Cette *stylisation* s’inscrit juste avant le paragraphe à modifier, entre les doubles parenthèses caractéristiques de _PFB_ et des accolades :
    (( line ))
    ```
    \\(( \\{... ici la stylisation en ligne ...} \\))
    Ici le paragraphe qui sera "touché" par la stylisation.
    ```
    EOT

  couleur = "FF9F00"

  sample_texte <<~EOT
    \\(( \\{indentation: 100, color: '#{couleur}'} ))
    Un paragraphe qui va se retrouver indenté de 100 points-postscript et dans une couleur hexadécimale #{couleur}.
    EOT
  texte(:as_sample)

end
