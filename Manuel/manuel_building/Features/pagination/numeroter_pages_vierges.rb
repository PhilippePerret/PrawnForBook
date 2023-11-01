Prawn4book::Manual::Feature.new do

  subtitle "Numérotation des pages vierges"

  description <<~EOT
    Les pages vierges peuvent être numérotée en modifiant la donnée `book_format: page: :no_num_if_empty:` ("no num if empty" signifie "pas de numéro si la page est vide").
    EOT

  sample_recipe <<~EOT
    ---
    book_format:
      page:
        no_num_if_empty: false
    EOT

end
