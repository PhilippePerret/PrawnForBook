Prawn4book::Manual::Feature.new do

  titre "Indentation des paragraphes"

  description <<~EOT

    La propriété "`book_format: text: indent:`" permet de déterminer l’indentation des paragraphes. On la définit avec une valeur numérique en points-ps ou dans toute autre valeur acceptée, comme les millimètres ('20mm') ou les pixels ('20px').

    Comme pour de nombreux éléments de publication, _PFB_ se comporte de façon intelligente avec les indentations. C’est-à-dire qu’il n’en ajoute, normalement, que là où c’est nécessaire. Il n’en met pas, par exemple, après un titre ou un paragraphe vide.

    Mais comme de nombreux éléments de publication, _PFB_ sait s’adapter aux besoins de permet de tout régler finement. Il est ainsi possible de définir explicitement une indentation qu’on veut ponctuellement différente, ou de la supprimer là où elle devrait se mettre. Étudiez les exemples suivants.

    #### Note sur l’indentation pour les experts

    Le cas échéant, sachez que l’indentation des paragraphes dans _PFB_ n’utilise pas, en vérité, la propriété `:indent_paragraphs`. Tout simplement parce cette propriété, à l’heure où l’on écrit ces lignes, n’est pas utilisable pour calculer la hauteur d’un bloc. On serait donc contraint de la supprimer, obtenant donc des résultats faux.
    Pour palier ce problème, on ajoute en réalité des espaces insécables vides avant le texte, pour atteindre peu ou prou la longueur désirée.
    EOT

  sample_texte <<~EOT
    Un texte avec l’indentation normale qui est réglée, ponctuellement pour cette fonctionnalité, à 15 mm
    \\(( {indentation: '40mm'} \\))
    Ce paragraphe, ponctuellement, aura une indentation de 40 mm définie par la ligne de code au-dessus de lui.
    Et ce troisième paragraphe utilise à nouveau l’indentation de 15 mm par défaut
    \\(( {no_indentation: true} \\))
    Ce dernier paragraphe, précédé d’un pfb-code supprimant son indentation, est imprimé contre la marge gauche.
    Et enfin, le dernier présente à nouveau l’indentation normale de 15 mm.
    EOT

  texte(:as_sample)

  recipe <<~EOT
    ---
    book_format:
      text:
        indent: '5cm'
    EOT

  sample_recipe <<~EOT #, "Autre entête"
    ---
    book_format:
      text:
        indent: 15mm
    EOT

  # init_recipe([:custom_cached_var_key])
  init_recipe([:text_indent])

end
