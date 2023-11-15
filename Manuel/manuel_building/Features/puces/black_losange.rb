Prawn4book::Manual::Feature.new do

  # titre "Les puces"
  # SUITE DES PUCES
  # 

  subtitle "Puce losange noir"

  recipe <<~YAML
    #<book_format>
    book_format:
      text:
        puce:
          text: :black_losange
          size: 14
          vadjust: -2
    #</book_format>
    YAML

  init_recipe([:format_text])

  sample_texte <<~EOT
    * Ceci est une puce :black_losange de 14 points, descendue de 2 points avec les autres paramètres laissés intacts,
    * Le second item identique,
    * Le troisième.
    EOT

end
