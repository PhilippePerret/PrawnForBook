Prawn4book::Manual::Feature.new do

  subtitle "Problèmes avec les multi colonnes"

  description <<~EOT
    Cette section décrit les problèmes qui peuvent survenir avec les doubles ou multi colonnes.

    *Note : dans l’idéal, ce fichier devrait être supprimé car il sert surtout à reproduire les erreurs pour pouvoir les corriger dans l’application.*
    EOT

  real_texte <<~EOT
    (( colonnes(2) ))
    Un premier item

    Un deuxième item
    (( colonnes(1) ))

    (( new_page ))

    (( colonnes(3) ))
    (( {align: :left} ))
    Un texte très très long pour qu’il tienne sur plusieurs colonnes. Pour voir comment le texte se répartira. Normalement, il ne devrait pas être justifié.
    (( colonnes(1) ))
    EOT

  texte <<~EOT
    Le texte qui doit apparaitre dans le livre.
    Le retour de la construction du livre est :
    ```
    _building_resultat_
    ```
    Des items sur deux colonnes :
    ![page-1](width:"100%") 
    (( line ))
    Une longue phrase sur trois colonnes :
    ![page-2](width:"100%")


    EOT

end
