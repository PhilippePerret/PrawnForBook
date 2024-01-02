Prawn4book::Manual::Feature.new do

  titre "Liste des abréviations"


  description <<~EOT
    La *liste des abréviations*, qui donne la liste de toutes les abréviations utilisées dans le livre et leur signification, s’affichera dans le livre en utilisant une des marques suivantes :
    * `\\(( list_of_abbreviations ))`,
    * `\\(( loa ))`,
    * `\\(( liste_des_abreviations ))`,
    * `\\(( lda ))`.
    Cela produit — par défaut — une table comme celle ci-dessous.

    #### Emplacement traditionnel de la liste des abréviations

    Si cette table se place traditionnellement après la table des matières ou la table des illustrations si elle existe, le fait qu’on l’insère dans un livre _PFB_ par une marque signifie qu’on peut l’introduire à l’endroit que l’on veut, à la fin du livre par exemple.

    Comme pour la [[pages_speciales/table_des_matieres]], si la liste des abréviations tient sur plusieurs pages, il faut définir ce nombre de page précisément car _PFB_ ne le fera pas pour vous.

    #### Définition d’une abréviation

    Les abréviations se définissent au fil du texte avec la marque :
    (( line ))
    `abbr\\(\\<abréviation>|\\<signification>)`
    (( line ))
    *Noter les deux "b" comme dans "abbreviation" en anglais.*
    Par exemple :
    (( line ))
    `... abbr\\(p.|page) ... abbr\\(par.|paragraph) ... abbr\\(PFB|Prawn-for-book) ...`
    (( line ))
    Ce code enregistrera l’abréviation avec sa signification.
    Dans ce manuel, nous utilisons les abréviations abbr(par.|paragraphe) pour "paragraphe", abbr(p.|page) pour "page" ou abbr(PFB|Prawn-for-book) pour "Prawn-for-book" et aussi abbr(coll.|collection) pour "collection". Vous les retrouverez dans la liste ci-après.

    #### Aspect de la liste des abréviations

    Comme toujours, _PFB_ propose une mise en page harmonieuse des abréviations, inspirée de la mise en page générale du livre et des listes d’abréviations habituelles.
    Il est cependant possible de redéfinir tous les aspects de cette liste des appréciations, dans la recette, dans la section `inserted_pages`, partie `abbreviations` (noter les deux "b") :
    (( line ))
    ```yaml
    inserted_pages:
      abbreviations:
        belle_page:   true
        title:        "Liste des abréviations"
        title_level:  2 # mettre à 0 pour ne pas l’afficher
        page_count:   2
        font:         null # fonte par défaut

    ```
    (( line ))
    * **`belle_page`** | Si `true` ("vrai" en anglais), la liste des abréviations commencera toujours sur une *belle page*, c’est-à-dire une page impaire, à droite.
    * **`title`** | Le titre de la page, en général "Abréviations" ou "Liste des abréviations".
    * **`title_level`** | Niveau de titre du titre.
    * **`page_count`** | Nombre de pages occupées par la liste des abréviations. Ce doit être obligatoirement un nombre paire. Si le nombre fourni n’est pas paire, ce sera le nombre paire suivant qui sera utilisé.
    * **`font`** | La *font-string* (cf. [[annexe/font_string]]) à appliquer pour l’affichag abréviations et de leur signification.
    EOT

  sample_texte <<~EOT
  \\(( lda ))
  EOT

  texte(:as_sample)

end
