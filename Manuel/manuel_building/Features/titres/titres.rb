Prawn4book::Manual::Feature.new do

  titre "Les Titres"


  description <<~EOT
    Les choses à décrire :

    * les éléments de base que sont la fonte, la taille et le style
    * le placement sur une page particulière (next_page, belle_page, alone)
    * l'alignement (:align) qui permet de mettre le titre :left, :right ou :center
    * utilisation d'un titre de niveau élevé pour faire un titre gros et particulier. Montrer qu'on se sert de :alone pour définir qu'il doit être seul sur la page et que, dans ce cas, on peut se servir de :lines_before pour le placer verticalement et de :align pour l'aligner
    EOT

  sample_texte <<~EOT
    Le texte en exemple. Si 'texte' n'est pas défini, sera interprété aussi. Sinon sera mis en illustration et c'est 'texte' qui sera interprété comme texte du livre.    
    EOT

  texte <<~EOT
    Texte à interpréter, si 'sample_texte' ne peut pas l'être.
    EOT

end
