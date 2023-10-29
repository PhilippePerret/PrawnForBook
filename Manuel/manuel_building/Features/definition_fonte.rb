Prawn4book::Manual::Feature.new do

  titre "Définition de la fonte par défaut"

  description <<~EOT
    Bien que l'application propose, clé en main, une fonte qui peut être utilisée pour imprimer un livre, on peut définir n'importe quelle fonte comme fonte par défaut, et même une fonte personnelle dont on aura au préalable acheté la licence (c'est presque toujours nécessaire si le livre doit être vendu).
    EOT

  font_name  = "Times-Roman"
  font_style = ''
  font_size  = 20

  sample_recipe <<~EOT
    book_format:
      text:
        default_font_and_style: "#{font_name}/#{font_style}"
        default_font_style: "#{font_style}"
        default_font_size: #{font_size}
    EOT



  recipe({
    default_font_n_style: "#{font_name}/#{font_style}",
    default_font_style: font_style,
    default_font_name: "#{font_name}",
    default_font_size: font_size,
  })

  texte <<~EOT
    (( font(name: "#{font_name}", size: #{font_size}, style: "#{font_style}") ))
    Pour écrire ce texte, nous avons ponctuellement modifié la police par défaut en utilisant la fonte #{font_name} avec une taille de #{font_size} et le style #{font_style}.
    EOT

end
