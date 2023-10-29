Prawn4book::Manual::Feature.new do

  # titre "Les puces"
  # SUITE DES PUCES
  # 

  subtitle "Puce carrée noire"

  sample_recipe <<~YAML
    #<book_format>
    book_format:
      text:
        puce:
          text: :black_square
          size: 20
          vadjust: 2
    #</book_format>
    YAML

  recipe({
    format_text: {
      puce: {
        text: :black_square, size: 20, vadjust:2, hadjust: 0, left: '4mm'
      }
    }
  })

  sample_texte <<~EOT
    * Ceci est une puce `:black_square` de 20 points, remontée de 2 points, avec les autres paramètres laissés intacts,
    * Le second item identique,
    * Le troisième.
    EOT

end
