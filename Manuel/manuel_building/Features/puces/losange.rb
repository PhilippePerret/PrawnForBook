Prawn4book::Manual::Feature.new do

  # titre "Les puces"
  # SUITE DES PUCES

  subtitle "Puce losange"

  description <<~EOT
    On peut définir une autre puce dans la [[recette/recette_livre]] ou la [[recette/recette_collection]], dans la partie `text:` de `book_format:`.
    EOT

  sample_recipe <<~YAML
    #<book_format>
    book_format:
      ...
      text:
        ...
        puce:
          text: :losange
          vadjust: 2
          hadjust: 4
          left: 20mm
          size: 18
    #</book_format>
    YAML

  recipe({
    format_text: {
      puce: {
        text: :losange, size: 18, vadjust:2, hadjust: 4, left: '20mm'
      }
    }
  })

  sample_texte <<~EOT
    * Ceci est une puce losange de 18 points, remontée de 2 points, déplacée à droite de 4, et écartée du texte de 20 millimètres,
    * Le second item de liste est identique,
    * Ainsi que le troisième.
    EOT

end
