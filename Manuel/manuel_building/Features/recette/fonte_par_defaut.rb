Prawn4book::Manual::Feature.new do

  titre "Définition de la fonte par défaut du texte"

  description <<~EOT
    Bien que l'application propose, clé en main, une fonte qui peut être utilisée pour imprimer un livre, on peut définir n'importe quelle fonte comme fonte par défaut, et même une fonte personnelle dont on aura au préalable acheté la licence (c'est presque toujours nécessaire si le livre doit être vendu).
    EOT

  real_texte <<~EOT
    Un texte avec la police par défaut. C’est celle définie dans la recette, avec les autres données. Vous pouvez par exemple remarquer la hauteur de ligne (line_height) particulièrement haute ici.
    EOT

  real_recipe <<~YAML
    ---
    # Définition des fontes
    # ---------------------
    fonts:
      Reenie:
        normal: "assets/fontes/Reenie_Beanie/ReenieBeanie-Regular.ttf"
    #
    # Format du livre (texte, page, etc.)
    # -----------------------------------
    book_format:
      text:
        font: "Reenie/normal/20/000077"
        line_height: 32

    YAML

  new_page_before(:texte)

  texte <<~EOT
    ![page-1]
    EOT
end
