Prawn4book::Manual::Feature.new do

  new_page_before(:feature)

  subtitle "Format de la légende"

  description <<~EOT
    Comme nous l’avons mentionné, par défaut, la légende d’une image se formate avec la police par défaut, la taille diminuée de une unité, le style *italique* et la couleur noire.
    Mais cet aspect naturel, qui passera pour tous les livres, peut être modifié pour tout le livre, dans les [[recette/grand_titre]], ou de façon ponctuelle^^ grâce aux données avant le paragraphe définissant l’image.
    ^^ Ce genre de modification doit être absolument évitée pour garder une cohérence dans l’aspect général du livre.
    EOT

  exstr = [
    '\\!\\[exemples/image.svg](legend: \\"Une légende dans le style défini en recette\\")',
    '\\!\\[exemples/image.svg](legend: \\"Légende avec couleur et taille ponctuelle\\", legend_color: [0,110,20,23], legend_size: 22)',
    '\\!\\[exemples/image.svg](legend: \\"Autre fonte, style, taille et couleur\\", legend_font: \\"Helvetica\\", legend_size: 14, legend_style: :regular, legend_color:[10,10,100,10], vadjust_legend: 15, space_before: 10)'
  ].map do |excode|
    <<~EOT
    `#{excode}`
    #{excode.gsub('\\','')}
    EOT
  end.join("\n(( new_page ))\n")

  exstr = "#{exstr}\nEnim excepteur non ea officia sunt nostrud exercitation occaecat aliqua nostrud."

  texte(exstr, "Codes suivis de leur interprétation")

  recipe <<~EOT #, "Autre entête"
    ---
    book_format:
      images:
        legend:
          font: Courrier
          size: 8
          color: "0FF0F0"
    EOT

  init_recipe([:format_images])

end
