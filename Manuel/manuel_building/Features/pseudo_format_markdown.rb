Prawn4book::Manual::Feature.new do

  titre "Le format pseudo-markdown"

  description <<~EOT
    Le formatage pseudo-markdown permet de mettre le texte en forme de façon très simple, sans avoir à se soucier des raccourcis clavier ou des menus, par de simples caractères, comme montré ci-dessous.

    EOT

  sample_texte <<~EOT
    Un *paragraphe en italiques*.
    Un **paragraphge en gras**.
    Un __texte__ en souligné.
    * Un item de liste court.
    * Un item de liste plus long pour voir comment la ligne sera enroulée pour laisser la puce bien visible.
    EOT

end
