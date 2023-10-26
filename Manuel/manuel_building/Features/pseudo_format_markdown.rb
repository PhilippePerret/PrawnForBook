Prawn4book::Manual::Feature.new do

  titre "Le format pseudo-markdown"

  description <<~EOT
    Le formatage pseudo-markdown permet de mettre le texte en forme de façon très simple, sans avoir à se soucier des raccourcis clavier ou des menus, par de simples caractères.
    
    On peut utiliser “*texte*” pour mettre en italiques, “**texte**” pour mettre en gras ou encore “__texte__” (avec deux traits plats) pour souligner.
    EOT

  sample_code <<~EOT
    Un *paragraphe en italiques*.
    Un **paragraphge en gras**.
    Un __texte__ en souligné.
    EOT

end
