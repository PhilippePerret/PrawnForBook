Prawn4book::Manual::Feature.new do

  titre "Définition des fontes (embarquées)"

  description <<~EOT
    Bien que l’application propose, clé en main, des fontes à utiliser pour imprimer son livre, on peut définir n’importe quelle fonte dont on possèderait la licence commerciale pour être utilisée pour tout élément du livre (texte, titres, etc.). Mais afin que l’imprimeur puisse s’en servir, il faut l’embarquer dans son document PDF à destination de cet imprimeur.

    #### Conseil concernant l’emplacement des fontes

    Il vaut mieux faire un dossier `fontes` dans votre dossier de collection ou de livre et y dupliquer les polices que vous voulez utiliser. De cette manière, si vous avez à transmettre le dossier à un collaborateur (ou autre), celui-ci ou celle-ci pourra imprimer correctement le livre, avec les fontes voulues (qu’il ou elle devra charger dans ses fontes personnelles).
    EOT

  font_name  = "Times-Roman"
  font_style = ''
  font_size  = 20

  recipe <<~EOT
    book_format:
      text:
        default_font_and_style: "#{font_name}/#{font_style}"
        default_font_style: "#{font_style}"
        default_font_size: #{font_size}
    EOT

  init_recipe([:default_font_n_style])

  texte <<~EOT
    (( font(name: "#{font_name}", size: #{font_size}, style: "#{font_style}") ))
    Pour écrire ce texte, nous avons ponctuellement modifié la police par défaut en utilisant la fonte #{font_name} avec une taille de #{font_size} et le style #{font_style}.
    EOT

end
