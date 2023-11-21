Prawn4book::Manual::Feature.new do

  new_page_before(:feature)

  title "Exemple complexe"

  # description <<~EOT
  #   La description
  #   EOT

  sample_texte <<~EOT #, "Autre entête"
    \\(( new_page ))
    Une première page pour voir l’entête et le pied de page définis (ça se poursuit sur l’autre page).
    \\(( new_page ))
    Une seconde page qui doit permettre aussi de voir l’entête et le pied de page sur les deux pages, car on ne sait pas, *a priori*, où va se retrouver cette page puisque le manuel est autoproduit par _PFB_ lui-même !
    Donc cette page que vous lisez peut se trouver en "fausse page", c’est-à-dire à gauche du livre, en page paire, aussi bien qu’en "belle page", c’est-à-dire à droite du livre, en page impaire.
    Ainsi, dans tous les cas vous devriez pouvoir obtenir une nouvelle page contenant l’entête et le pied de page voulu. 
    Donc, à la différence des pages par défaut, on devrait trouver ici, à gauche, le numéro de page au milieu, alors qu’il est à gauche dans le pied de page droit, avec le nombre total de pages dans le manuel.
    On doit trouver en à gauche de la page gauche le titre principal courant, donc le chapitre, qui s’intitule "Entêtes et Pieds de pages".
    Et on doit trouver sur la page droite, en entête, le numéro de version "4.452" à gauche et au milieu le sous-titre du chapitre donc "Exemple complexe".
    EOT
  texte(:as_sample)

  # texte <<~EOT
  #   Texte à interpréter, si 'sample_texte' ne peut pas l'être.
  #   EOT

  recipe <<~EOT #, "Autre entête"
    ---
    headers_footers:
      dispositions:
        exemple1:
          name: "Exemple headers/footers complexe pour manuel"
          font: "Courier/regular/12/FF0000"
          pages: "\#{first_page - 2}-\#{first_page + 3}"
          header: "| -TIT3   || -v4.452 | TIT4- |"
          footer: "| x | NUM || NUM/TOT | PhP |"
          header_font: "Reenie/normal/20/009900"
    EOT

  # init_recipe([:custom_cached_var_key])


  # À chaque nouvelle fonctionnalité présentées/construite dans le
  # manuel, on remet la recette à son état initiale. Mais pour ce
  # module particulier, qui concerne les entêtes et pieds de page,
  # il faut conserver la recette étendue avec les nouveaux pieds de
  # page qui seront imprimés seulement à la toute fin de la création
  # du manuel autoproduit.
  # Cette procédure sert donc à ajouter vraiment à la recette la
  # nouvelle disposition
  proc_fix_headers_footers = Proc.new do
    # DATA, ici, normalement, contient les nouveaux entêtes et 
    # pied de page
    Prawn4book::Recipe::DATA[:headers_footers][:dispositions][:exemple1][:pages] = "#{pdf.page_number - 2}-#{pdf.page_number + 2}"
    @init_recipe_state = Marshal.dump(Prawn4book::Recipe::DATA)  
  end

  code(proc_fix_headers_footers)

end
