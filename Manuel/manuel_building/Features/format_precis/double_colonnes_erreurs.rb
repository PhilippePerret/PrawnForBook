Prawn4book::Manual::Feature.new do

  subtitle "Problèmes avec les multi colonnes"

  description <<~EOT
    Cette section décrit les problèmes qui peuvent survenir avec les doubles ou multi colonnes.

    *Note : dans l’idéal, ce fichier devrait être supprimé car il sert surtout à reproduire les erreurs pour pouvoir les corriger dans l’application.*
    EOT

  # Note : pour le moment, on note beaucoup d’erreurs
  # # Les items ne sont pas les uns au-dessus des autres
  # # Page 2 Le texte n’est pas justifié à gauche
  # # Page 3, il y a 3 lignes d’un côté et une seule de l’autre
  # # Page 3, le texte n’est pas justifié au centre
  # 
  real_texte <<~EOT
    Une section en double colonnes, avec seulement deux items courts qui ne dépassent pas les colonnes.
    (( colonnes(2) ))
    Premier item
    Deuxième item
    (( colonnes(1) ))
    Texte sous la section multi-colonnes.

    (( new_page ))
    
    Section en double colonnes avec seulement deux items mais plus longs qu’une colonne (donc un passage à la ligne).
    (( colonnes(2) ))
    Premier item assez long pour passer à la ligne
    Deuxième item assez long pour passer à la ligne
    (( colonnes(1) ))
    Texte sous la section multi-colonnes.

    (( new_page ))

    Section en double colonnes avec trois items courts les un au-dessus des autres.
    (( colonnes(2) ))
    Un premier item
    Un deuxième item
    Un troisième item
    (( colonnes(1) ))
    Texte sous la section multi-colonnes.

    (( new_page ))

    Section en double colonnes avec un long paragraphe unique qui passe de la première colonne à la seconde.
    (( colonnes(2) ))
    Le paragraphe de cette section doit aller de la 1er colonne à la deuxième et surtout il doit générer deux colonnes qui sont de la bonne hauteur pour s’ajuster parfaitement au contenu sur plusieurs lignes.
    (( colonnes(1) ))
    Texte sous la section multi-colonnes.

    (( new_page ))

    Section en double colonnes avec plusieurs paragraphes qui passent de l’une à l’autre.
    (( colonnes(2) ))
    Le paragraphe de cette section doit aller de la 1er colonne à la deuxième.
    Il doit surtout générer deux colonnes qui sont de la bonne hauteur.
    Les colonnes se doivent de s’ajuster parfaitement au contenu sur plusieurs lignes.
    (( colonnes(1) ))
    Texte sous la section multi-colonnes.

    (( new_page ))

    Section en triple colonnes avec un long paragraphe unique qui passe de la première colonne à la seconde puis à la troisième.
    (( colonnes(3) ))
    Le paragraphe de cette section doit aller de la 1er colonne à la deuxième et ensuite à la troisième de la même façon et surtout il doit générer 3 colonnes de la bonne hauteur pour bien s’ajuster au contenu sur x lignes.
    (( colonnes(1) ))
    Texte sous la section multi-colonnes.

    (( new_page ))

    Section en triple colonnes avec plusieurs paragraphes qui passent de l’une à l’autre.
    (( colonnes(3) ))
    Le paragraphe de cette section doit aller de la 1er colonne à la deuxième.
    Nouveau paragraphe pour aller à la troisième de la même façon.
    Il doit surtout générer 3 colonnes de la bonne height pour bien s’ajuster au contenu sur x lignes.
    (( colonnes(1) ))
    Texte sous la section multi-colonnes.

    (( new_page ))
    
    Section en triple colonnes avec plusieurs paragraphes __alignés à gauche__ et __indentés__ qui passent de l’une à l’autre.
    (( colonnes(3) ))
    (( {align: :left, indent: "5mm" } ))
    Un texte très très long pour qu’il tienne sur plusieurs colonnes.
    Pour voir comment le texte se répartira.
    Il ne devrait pas être justifié, mais aligné à gauche.
    (( colonnes(1) ))
    Texte sous la section multi-colonnes.

    (( new_page ))

    Un texte au-dessus de la section à deux colonnes avec __changement d’alignement__ des paragraphes.

    (( colonnes(2) ))
    Un premier paragraphe avec l’alignement par défaut, c’est-à-dire un texte justifié.
    (( {align: :right} ))
    Le paragraphe suivant (celui-ci) est aligné à droite et il est de moyenne longueur. Il évalue 4 + 4 = \#{4 + 4}.
    (( {align: :left} ))
    On passe ensuite, ici, à un paragraphe aligné à gauche de la même longueur à peu près.
    (( {align: :center, size: 20, color: "FF0000"} ))
    Ce paragraphe est plus différent, avec une taille de police et une couleur différente. Il est également plus long. Il comporte de l’*italique* et du ***gras italique***.
    (( colonnes(1) ))
    Texte sous la section multi-colonnes.

    (( new_page ))
    
    Ce paragraphe se trouve au-dessus d’une section à 3 colonnes qui est séparée de 1 ligne de ce texte.
    (( colonnes(3, {lines_before: 1, lines_after:3 }) ))
    Une ligne
    Une autre ligne
    Une troisième ligne
    (( colonnes(1) ))
    Texte sous la section multi-colonnes qui doit être séparé par 3 lignes.

    (( new_page ))

    Les deux pages suivantes (dont celle-ci) présentent un texte très long qui va passer sur __plusieurs pages__. On profite de ce long texte pour essayer beaucoup de choses (lire le texte).
    (( colonnes(2) ))
    Ce très long texte va comporter beaucoup de choses pour vérifier que tout s’y passe bien. 
    Une liste à puce pour voir :
    * item 1
    * item 2
    * item 3
    Un paragraphe contenant du style html, de l’*italique*, du **gras**, du __souligné__, et même les ***__trois ensemble__***.
    (( {indent: "1cm"} ))
    Ce paragraphe est indenté de 1 centimètre, ce qui est pas mal pour le coup et il écrit la date du jour où ce livre a été actualisé. Il a été actualisé le \#{Time.now.strftime("%d %m %Y")} et cette date est incroyable, non ?
    Ce paragraphe-ci contient une note^^ numérotée automatiquement, qui devrait trouver son explication en fin de colonnes, si tout va bien. Il contient aussi une autre note^^ numérotée automatiquement aussi mais qui trouvera son explication sous la section à colonnes.
    ^^ Explication de la note initiée dans la colonne.
    (( colonnes(1) ))
    Texte sous la section multi-colonnes.
    ^^ Explication de la seconde initiée dans la colonne.

    EOT

  texte <<~EOT
    Le texte qui doit apparaitre dans le livre.
    Le retour de la construction du livre est :
    ```
    _building_resultat_
    ```
    ![page-1](width:"100%")
    (( line ))
    ![page-2](width:"100%")
    (( line ))
    ![page-3](width:"100%")
    (( line ))
    ![page-4](width:"100%")
    (( line ))
    ![page-5](width:"100%")
    (( line ))
    ![page-6](width:"100%")

    EOT

  real_recipe <<~YAML
    ---
    book_format:
      page:
        margins:
          top: 2mm
          bot: 8mm
    YAML

end
