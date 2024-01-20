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
    Un texte au-dessus de la section en 2 colonnes avec des items.
    (( colonnes(2) ))
    Un premier item
    Un deuxième item
    Un troisième item
    (( colonnes(1) ))
    Un texte sous la partie en deux colonnes avec des items les uns sur les autres.

    (( new_page ))

    Un texte qui vient au-dessus de la section en trois colonnes.
    (( colonnes(3) ))
    (( {align: :left} ))
    Un texte très très long pour qu’il tienne sur plusieurs colonnes. Pour voir comment le texte se répartira. Normalement, il ne devrait pas être justifié, mais aligné à gauche.
    (( colonnes(1) ))
    Un texte sous la partie en trois colonnes justifiée à gauche.

    (( new_page ))

    Un texte au-dessus de la section à deux colonnes.
    (( colonnes(2) ))
    (( {align: :center} ))
    Ici, on devrait avoir un texte aligné au centre dans les deux colonnes qui ont été affectées à cette section.
    (( colonnes(1) ))
    Un texte sous la partie en deux colonnes justifiée au centre.

    (( new_page ))
    Un texte au-dessus de la section à deux colonnes avec changement d’alignement

    (( colonnes(2) ))
    Un premier paragraphe avec l’alignement par défaut, c’est-à-dire un texte justifié.
    (( {align: :right} ))
    Le paragraphe suivant (celui-ci) est aligné à droite et il est de moyenne longueur. Il évalue 4 + 4 = \#{4 + 4}.
    (( {align: :left} ))
    On passe ensuite, ici, à un paragraphe aligné à gauche de la même longueur à peu près.
    (( {align: :center, size: 20, color: "FF0000"} ))
    Ce paragraphe est plus différent, avec une taille de police et une couleur différente. Il est également plus long. Il comporte de l’*italique* et du ***gras italique***.
    (( colonnes(1) ))
    Ce paragraphe se trouve en dessous de la section à plusieurs colonnes. Il sert à s’assurer qu’il n’y a pas d’espace entre la section multi-colonne et le texte qui suit.

    (( new_page ))
    Ce paragraphe se trouve au-dessus d’une section à 3 colonnes qui est espacé de 2 lignes de cette section.
    (( colonnes(3, {lines_before: 2, lines_after:4 }) ))
    Une ligne
    Une autre ligne
    Une troisième ligne
    (( colonnes(1) ))
    Ce texte se trouve sous la section à 3 colonnes et séparé de 4 lignes de cette section.
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

end
