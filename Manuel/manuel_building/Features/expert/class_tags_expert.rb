Prawn4book::Manual::Feature.new do

  titre "*Class-tags* en mode expert"


  description <<~EOT
    Nous avons vu plus haut l’utilisation des [[*class-tags*|texte_detail/par_class_tag]] pour créer des sortes de *feuilles de styles*.
    {{Développer ici le fait qu’on peut faire plein de choses dans la méthode de formatage, comme récupérer le texte pour faire une liste des citations à la fin, ou faire un index des noms d’auteurs, etc. tout ce qu’on veut}}

    {{Montrer l’autre forme d’utilisation, on l’on prend carément `context[:pdf]` et qu’on utilise `pdf.update do` pour faire ce que l’on veut, en retournant nil pour ne rien marquer de plus}}

    {{lier ce qui précède à l’utilisation des tables et des printers. Ne pas les réexpliquer ici, faire des sections propres.}}

    {{Noter qu’on peut utiliser aussi une autre méthode, qui s’appelle "`build_\\<tag>_paragraph(paragraph, pdf)`" pour formater le paragraphe dans le style, en obtenant tout de suite le paragraphe et le pdf.}}

    {{Montrer comment on ajoute une image, un picto}}
    EOT

  sample_texte <<~EOT #, "Autre entête"
    Le texte en exemple. Si 'texte' n'est pas défini, sera interprété aussi. Sinon sera mis en illustration et c'est 'texte' qui sera interprété comme texte du livre.    
    EOT

  texte <<~EOT
    Texte à interpréter, si 'sample_texte' ne peut pas l'être.
    EOT

  recipe <<~EOT #, "Autre entête"
    ---
    # Cette recette doit être supprimée ou utilisée
    EOT

end
