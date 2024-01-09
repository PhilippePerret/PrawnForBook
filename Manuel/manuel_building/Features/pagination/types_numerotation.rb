Prawn4book::Manual::Feature.new do

  titre "Types de numérotation"


  description <<~EOT

    #### Trois types de numérotation

    Il existe 3 types de numérotation dans _PFB_ : par page, par paragraphe et hybride (page et paragraphe). Ces types affectent le foliotage des pages (ce qu’on appelle la *numérotation des pages*) mais également et surtout les références aux différents endroits du livre, par exemple dans la table des matières ou les index divers.
    On règle ce type dans la propriété `pagination` (ou `numerotation`) de la section `book_format: page:` :
    (( line ))
    ```yaml
    ---
    book_format:
      page:
        pagination: pages
    ```
    (( line ))
    Dans un livre (pour le moment, le type de numérotation doit s’appliquer à tout un livre), on peut choisir entre :

    * **numérotation par page** | C’est la numérotation traditionnelle, avec le numéro de la page. C’est le type qui devra être utilisé pour un roman par exemple. Valeur à donner à `pagination` : `pages`
    * **numérotation par paragraphe** | Dans cette numérotation, chaque paragraphe est numéroté. Elle convient à des ouvrages assez courts, lorsque l’on doit pouvoir faire référence à des paragraphes précis. Valeur à appliquer à `pagination` : `parags`.
    * **numérotation hybride** | Le problème de la numérotation par paragraphe, c’est que les chiffres deviennent très élevés pour un ouvrage d’un dimension conséquente. C’est là que la *numérotation hybride* entre en jeu. Dans cette numérotation, qui fonctionne avec les pages, chaque paragraphe est numéroté, mais en reprenant à 1 à chaque *fausse page* (page gauche paire). Et l’on fait référence à un paragraphe précis en indiquant son numéro de page et son index. Par exemple "page 12 paragraphe 8". Vous pouvez voir cette numérotation en action dans [[pagination/numerotation_paragraphes]]. Valeur à appliquer à `pagination` : `hybrid`.
    
    #### Où servent les numérotations ?

    Bien sûr, quand on parle de *pagination*, on pense surtout au numéro de page qu’on trouve en entête ou en pied de page des pages du livre.
    Dans _PFB_, cette numérotation présentera le numéro de la page pour les types `pages` et `hybrid` et présentera le numéro du premier et du dernier paragraphe pour le type `parags`.
    (( line ))
    Mais ces *numéros* servent aussi lorsqu’on fait référence à une cible placée ailleurs dans le livre.
    Imaginons par exemple que tous les chapitres du livre aient été référencés, grâce à des :
      `\\<-\\(chapitre_\\<X>)`
    Dans ce cas, on peut faire référence à tel ou tel chapitre avec la marque :
      `->\\(chapitre_\\<X>)`
    … qui présentera une référence par page, par paragraphe ou par page et paragraphe dans le type hybride. 
    C’est ce que nous appellerons une *référence* dans la suite.

    #### Format des numérotations

    Le format par défaut des numérotations est le suivant :
    (( line ))
    (( {align: :center} ))
    | Type | Format | Exemple |
    | pages  | "page \\<num>" | "page 12" |
    | parags | "§ \\<num parag>" | "§ 12" |
    | hybrid | "p. \\<num page> § \\<num parag>" | "p. 2 § 5" |
    |/|
    
    #### Formatage de la référence dans la recette

    On peut modifier le format par défaut ci-dessus dans la recette dans la partie `book_format: text: references:` en définissant la propriété `format_\<type pagination>` donc par exemple `format_hybrid` pour le format de pagination hybride, avec numéro de page et numéro de paragraphe. Dans la définition de ce format, on utilise `_page_` pour le numéro de page et `_paragraph_` pour le numéro de paragraphe.
    Par exemple, si l’on est en pagination de type `hybrid` et que l’on veut que les références soient marquées "au paragraphe xxx de la page yyy", on écrira dans la recette :
    (( line ))
    ```yaml
    book_format:
      text:
        references:
          format_hybrid: "au paragraphe _paragraph_ de la page _page_"
    ```
    (( line ))
    Ci-dessus, `_paragraph_` sera remplacé par le numéro de paragraphe de la cible et `_page_` sera remplacé par le numéro de page.

    #### Formatage de la référence à la volée

    On peut également utiliser, ponctuellement, une marque de référence différente de celle définie, lorsque cette  marque ne se justifie pas.
    Par exemple, si vous voulez faire référence à un chapitre, sans citer son nom, mais juste sa page, dans un texte comme "au chapitre de la page 12", alors vous pouvez le faire de cette manière :
    (( line ))
    ```
    Rendez-vous au chapitre de la page ->(_page_|chapitre5) pour 
    connaitre la suite.
    ```
    (( line ))
    Note : pour mémoire, le code `->\\(...)` fait référence à une cible définie ailleurs. Voir [[references/cross_references]] pour le détail.
    (( line ))
    Dans cette utilisation, on emploie `_ref_` pour faire référence au format défini (ce qui n’a pas vraiment de sens, mais on peut le faire), on emploie `_page_` pour faire référence au numéro de la page de la cible et `_paragraph_` pour faire référence au numéro de paragraphe de la cible. Notez que dans une pagination hybride, il convient d’indiquer la page et le paragraphe car l’indication au seul paragraphe serait insuffisant.
    Par exemple, si on veut que la référence ressemble à "au paragraphe 3 de la page 12", on mettra dans la première partie de la référence : `au paragraphe _paragraph_ de la page _page`.



    #### Aspect physique des références

    Si vous n’êtes pas un expert, vous ne pouvez pas définir la fonte (police, style, taille et couleur) d’une référence dans le texte (elle doit être identique à la fonte du texte lui-même, pour la cohérence). En revanche, il est tout à fait possible de la déterminer pour la [[-pages_speciales/table_des_matieres]], les index — cf. [[pages_speciales/index_page]] — ou les bibliographie — [[bibliographies/customisation]].

    EOT


end
