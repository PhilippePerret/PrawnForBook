Prawn4book::Manual::Feature.new do

  titre "Page de dédicace"


  description <<~EOT
    Sur cette page est adressée une dédicace.
    Comme [[pages_speciales/mention_legale]], il suffit que la propriété `dedicace` soit définie dans `inserted_pages` pour que cette page soit insérée dans le livre, correctement formatée et positionnée.
    (( line ))
    ~~~yaml
    inserted_pages:
      dedicace: |
        Je dédis cet ouvrage à tous les chiens malheureux de
        la terre, afin que leur souffrance s’abrège.
    ~~~
    (( line ))
    On peut également la définir très précisément avec :
    (( line ))
    ~~~yaml
    inserted_pages:
      dedicace:
        content: |
          Je dédis cet ouvrage à tous les chiens malheureux de
          la terre, afin que leur souffrance s’abrège.
        font: "<police>/<style>/<taille>/<couleur>"
        line: <numéro de ligne>
        leading: <interlignage>
    ~~~
    (( line ))
    La propriété `font` est une *fonte-string* dont vous pouvez tout apprendre à la page [[__page__|annexe/font_string]] dans l’annexe.

    #### Dédicace sur plusieurs pages

    Une dédicace peut être très longue et tenir sur plusieurs pages. Dans ce cas, il est peut-être bon de ne pas la définir dans la recette mais plutôt dans le livre. Noter qu’une dédicace sur plusieurs pages doit être numérotée donc qu’il n’y a rien à faire par rapport à ça.
    Indiquons juste qu’on peut choisir facilement la première ligne sur laquelle doit commencer la dédicace grâce à la commande `move_to_line` ("se déplacer à la ligne" en anglais).
    Une dédicace sur plusieurs pages pourra donc ressembler à ça ce qui suit.
    EOT

    sample_texte <<~EOT
    \\(( new_page ))
    \\(( move_to_line(12) ))
    \\(( {style: :italic, size: 14, font: 'Courier', indentation: 40} ))
    Je voudrais, par ces quelques lignes, adresser une dédicade à celle sans qui ce manuel n’aurait jamais vu le jour, je veux parler de ma chienne Poupette qui reste pour moi bla bla bla sur plusieurs pages.
    \\(( new_page ))
    EOT

    texte(:as_sample)

end
