Prawn4book::Manual::Feature.new do

  titre "Types de numérotation"


  description <<~EOT

    #### Trois types de numérotation

    * **numérotation par page**
    * **numérotation par paragraphe**
    * **numéroation hybride**
    
    #### Formatage des numérotations

    (pour toutes les numérotations) On peut utiliser `_ref_` pour faire référence à la numérotation par défaut (sans parenthèses).
    On utilise `_page_` pour faire référence à la page. On utilise `_paragraph_` pour faire référence au paragraphe.
    Par exemple, si on veut que la référence ressemble à "au paragraphe 3 de la page 12", on met en valeur de `???` : `au paragraphe _paragraph_ de la page _page`.
    
    #### Formatage de la numérotation hybride

    EOT


end
