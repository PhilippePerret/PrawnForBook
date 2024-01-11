Prawn4book::Manual::Feature.new do

  titre "Indentation des paragraphes"

  description <<~EOT

    La propriété "`book_format: text: indent:`" permet de déterminer l’indentation des paragraphes. On la définit avec une valeur numérique en points-ps ou dans toute autre valeur acceptée, comme les millimètres ('20mm') ou les pixels ('20px').

    Comme pour de nombreux éléments de publication, _PFB_ se comporte de façon intelligente avec les indentations. C’est-à-dire qu’il n’en ajoute, normalement, que là où c’est nécessaire. Il n’en met pas, par exemple, après un titre ou un paragraphe vide.

    Mais comme de nombreux éléments de publication, _PFB_ sait s’adapter aux besoins de permet de tout régler finement. Il est ainsi possible de définir explicitement une indentation qu’on veut ponctuellement différente, ou de la supprimer là où elle devrait se mettre. Étudiez les exemples suivants.

    #### Indentation en stylisation en ligne

    On peut ponctuellement introduire une indentation d’un paragraphe en utilisant la propriété `indent` ou `indentation`.
    (( {indent: '2cm'} ))
    Par exemple, ce paragraphe a été précédé du code `\\(( {indent: '2cm'} ))` et se retrouve donc indenté de 2 centimètres.
    (( {indentation: 8} ))
    Ce paragraphe, au contraire, a été précédé du code `\\(( {indentation: 8} ))` et se retrouve donc indenté de 8 points-postscript.
    Ce dernier paragraphe ne subit aucune indentation, parce que pour rappel, la _stylisation_inline_ ne s’applique qu’au paragraphe suivant.

    #### Pas d’indentation négative

    Noter que pour le moment il est impossible d’utiliser une indentation négative (à cause des limitations actuelles de  `Prawn`.

    #### Forcer l’identation du paragraphe

    Il peut arriver, parfois, que l’identation d’un paragraphe soit supprimée, sans raison apparente. Cela tient aux calculs parfois très compliqués que doit effectuer _PFB_. Le cas échéant, il suffit d’ajouter la marque `\\(( {indentation:true} ))` juste avant le paragraphe en question pour forcer son indentation.

    #### Note sur l’indentation pour les experts

    Le cas échéant, sachez que l’indentation des paragraphes dans _PFB_ n’utilise pas, en vérité, la propriété `:indent_paragraphs`. Tout simplement parce cette propriété, à l’heure où l’on écrit ces lignes, n’est pas utilisable pour calculer la hauteur d’un bloc. On serait donc contraint de la supprimer, obtenant donc des résultats faux.
    Pour palier ce problème, on ajoute en réalité des espaces insécables vides avant le texte, pour atteindre peu ou prou la longueur désirée.
    EOT

  sample_texte <<~EOT
    Un texte normal donc sans indentation puisque nous n’en utilisons pas dans ce manuel.
    \\(( {indentation: '40mm'} \\))
    Ce paragraphe, ponctuellement, possède une indentation de 40 mm définie par la ligne de code au-dessus de lui.
    Et ce troisième paragraphe utilise à nouveau l’indentation par défaut (donc pas d’indentation).
    <font name="Courier" size="3">    </font>Et normal.
    \\(( {no_indentation: true} \\))
    Ce dernier paragraphe, précédé d’un pfb-code supprimant son indentation, est imprimé contre la marge gauche (mais bon… c’est un test gratuit puisqu’il n’y a pas d’indentation par défaut…).
    EOT

  texte(:as_sample)

  sample_recipe <<~EOT #, "Autre entête"
    ---
    book_format:
      text:
        indent: '2cm'
    EOT

  init_recipe([:text_indent, :format_text])

end
