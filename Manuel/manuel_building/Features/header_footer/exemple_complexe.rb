Prawn4book::Manual::Feature.new do

  new_page_before(:feature)

  subtitle "Exemple complexe"

  # description <<~EOT
  #   La description
  #   EOT

  sample_texte <<~EOT #, "Autre entête"
    \\(( new_page ))
    Une première page pour voir l’entête et le pied de page définis.
    \\(( new_page ))
    Une seconde page
    EOT

  # texte <<~EOT
  #   Texte à interpréter, si 'sample_texte' ne peut pas l'être.
  #   EOT

  recipe <<~EOT #, "Autre entête"
    ---
    headers_footers:
      font: "Courier/regular/15/FF0000"
      dispositions: 
        first_page: \#{first_page}
        last_page:  \#{first_page + 4}
        header: "| -TIT1 || -v4.452 | TIT2- |"
        footer: "| x | NUM || NUM/TOT | PhP |"
    EOT

  # init_recipe([:custom_cached_var_key])

end
