Prawn4book::Manual::Feature.new do

  # titre "Les puces"
  # SUITE DES PUCES
  # 

  subtitle "Puce gros tiret"

  taille_tiret = 100
  vadjust = 65
  left = '20'

  recipe <<~YAML
    #<book_format>
    book_format:
      text:
        puce:
          text: :hyphen
          size: #{taille_tiret}
          vadjust: #{vadjust}
          left: #{left}mm
    #</book_format>
    YAML

  init_recipe([:format_text])

  sample_texte <<~EOT
    * Ceci est une puce `:hyphen` de #{taille_tiret} points, remontée de #{vadjust} points, texte décalé de #{left}mm, avec les autres paramètres laissés intacts,
    * Le second item identique,
    * Le troisième.
    EOT

end
