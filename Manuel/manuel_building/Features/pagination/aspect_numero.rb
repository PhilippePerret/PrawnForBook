Prawn4book::Manual::Feature.new do

  subtitle "Aspect du numéro"

  description <<~EOT
    L'aspect du numéro (sa police, son style, sa taille, sa couleur) peut être défini très précisément dans la recette. On utilise pour cela les paramètres suivant.
    La couleur est exprimée de façon hexadécimale (voir l'explication page (( ->(couleur) )) ).
    *(remarquez que ci-dessous nous pouvons utiliser des *variables* au lieu de répéter plusieurs fois la même information. Ici, c'est la fonte par défaut que nous avons mise dans une variable)*
    EOT

  sample_recipe <<~EOT
    ---
    # Recette du livre
    book_format:
      page:
        num_font: "<police>/<style>/<taille>/<couleur>"
    EOT

end
