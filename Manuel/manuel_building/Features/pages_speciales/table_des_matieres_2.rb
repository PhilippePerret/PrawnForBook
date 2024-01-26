Prawn4book::Manual::Feature.new do

  sous_titre "Exemple table des matières personnalisée"

  real_texte <<~EOT
    # Un grand titre
    (( new_page ))
    (( toc ))
  EOT

  real_recipe <<~YAML
  table_of_content:
    title: "Sommaire"
  book_format:
    titles:
      level1:
        lines_after: 0
        lines_before: 0
        next_page:  false # pour ne pas ajouter de page avant
        belle_page: false # idem
        alone: false
  YAML

  texte <<~EOT
  (( line ))

  (( {borders: nil} ))
  |   | ![page-1](width:"48%") |
  | ![page-2](width:"48%") | ![page-3](width:"48%") |
  |/|
  EOT
end

Prawn4book::Manual::Feature.new do
  sous_titre "Table des matières entièrement customisée"
  real_texte <<~EOT
    (( toc ))
    # Un titre de niveau 1
    ## Un titre de niveau 2
    ## Autre titre de niveau 2
    # Un titre de niveau 1
    EOT

  texte <<~EOT
    Table des matières entièrement customisée (personnalisée).
    ![page-1]
    EOT
end
