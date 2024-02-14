Prawn4book::Manual::Feature.new do

  titre "Parsing du paragraphe"


  description <<~EOT
    (( {color:"FF0000"} ))
    **Note : éviter d’appeler directement la méthode **`__parse`**. Définir de préférence les méthodes `pre_parse`, `parse` et `post_parse`.** cf. [[expert/corrections_textes_propres]].
    Un texte de paragraphe est souvent constitué de variables, de code, qui dépendent du contexte ou sont définis pour un livre. En règle générale, ces variables sont estimées au cours de la fabrication du livre.

    Mais parfois, il est nécessaire de forcer cette interprétation lorsque beaucoup de texte est produit de façon informatique (par programmation), comme par exemple un dictionnaire qui serait produit à partir d’une base de données de mots.

    Dans ce cas, il faut explicitement appeler la méthode :
    (( {align: :center} ))
     `Prawn4book::PdfBook::AnyParagraph.__parse` 
    … en lui fournissant les bons arguments :
    (( line ))
    ~~~ruby
    str_corriged = \\
      Prawn4book::PdfBook::AnyParagraph.__parse(<string>, <context>)
    ~~~
    où :
    `\\<string>` est la chaine produite `[String]`.
    `\\<context>` est une table `[Hash]` définissant `:pdf` et `:paragraph`^^
    ^^ Rappel : pour obtenir `:pdf` et `:paragraph`, se souvenir que plusieurs méthodes de parsing et de formatage personnalisées peuvent utiliser leur nombre de paramètres pour déterminer les informations qui seront transmises.
    EOT

end
