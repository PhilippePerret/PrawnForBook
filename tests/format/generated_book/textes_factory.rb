module Factory
class Text
###################       CLASSE      ###################
class << self
  def text_moyen
    @text_moyen ||= begin
      <<~TEXT
      Ceci est un texte moyen qui contient une dizaine de lignes sur plusieurs paragraphes.
      Il doit permettre de positionner du texte sur une page pour vérifier le bon positionnement.
      Contrairement à un long texte, il ne remplit pas une page complète mais ce paragraphe, par exemple, qui contient des accents et des diacritiques, s'étire pendant l'été, ça c'est sûr, sur plusieurs lignes presque jusqu’en bas. On se croirait dans du Proust !
      TEXT
    end
    return @text_moyen.dup
  end


  def long_text_with_tdm_and_index
    @long_text_with_tdm_and_index ||= begin
      <<~TEXT
      (( table_des_matieres ))
      # Le premier grand titre (Titre 1)
      Une index:introduction à ce livre qui doit servir à tester par exemple la numérotation complète, qu'elle se fasse dans la table des matières, sur chaque page ou dans un index de fin d'ouvrage.
      ## Sous-Titre 1 du grand titre
      Dans ce sous-titre, on va pouvoir tester pas mal de chose. Et notamment indexer les index(mots|mot) utiles pour voir le résultat.
      # Grand titre 2
      ## Premier sous-titre du grand titre 2
      Ici on détaille tout ce qu'on va trouver. On doit avoir un index avec « index:mot », avec « index:introduction ».
      ## Deuxième sous-titre titre 2
      Voluptate tempor magna culpa nostrud consectetur elit dolor dolor velit velit id laborum dolore consectetur cupidatat sed adipisicing.
      Nostrud sint consectetur cillum proident dolor occaecat sed reprehenderit officia in et aliquip reprehenderit eiusmod nostrud nostrud laboris aliqua reprehenderit laboris esse irure.
      ## Troisième sous-titre titre 2
      Non anim in nulla proident ut elit nostrud laborum amet sed officia irure ad cillum incididunt veniam voluptate enim eiusmod nostrud et elit cupidatat culpa et eiusmod nisi exercitation commodo sit officia dolore consequat occaecat amet enim voluptate sunt amet dolor elit esse reprehenderit occaecat dolor ut ut laborum pariatur consectetur ut duis sint et consequat sunt id quis qui aliqua tempor in fugiat nisi sunt aute quis cillum ullamco eiusmod excepteur fugiat ex laboris adipisicing in aliqua tempor nostrud in exercitation est consectetur fugiat amet eiusmod nostrud non reprehenderit sed culpa commodo pariatur et nisi do amet et aute minim elit nostrud id quis ex reprehenderit consectetur ut irure sed laboris elit sunt magna labore mollit laborum officia ea minim ullamco duis ut dolor cupidatat in dolor enim et ut eiusmod occaecat quis labore eu magna ut exercitation eu exercitation do quis ut irure sunt duis incididunt occaecat dolor labore amet deserunt elit sunt labore proident officia elit est et eu ex reprehenderit dolore officia duis cupidatat nisi dolore minim in aute consequat nostrud mollit amet sunt esse est exercitation mollit amet tempor dolor laboris velit ut enim laborum elit minim nostrud culpa sed sit non est irure esse excepteur ut dolor qui ut nulla labore laboris exercitation quis.
      Ça peut faire une belle index:introduction à la dramaturgie, de façon succinte et efficace.
      (( index ))
      TEXT
    end
    return @long_text_with_tdm_and_index.dup
  end
end #/<< class << self
###################       INSTANCE      ###################

end #/Text
end #/module Factory
