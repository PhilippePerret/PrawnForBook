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
      # #{long_title1}
      Une index:introduction à ce livre qui doit servir à tester par exemple la numérotation complète, qu'elle se fasse dans la table des matières, sur chaque page ou dans un index de fin d'ouvrage.
      ## #{title1_subtitle1}
      Dans ce sous-titre, on va pouvoir tester pas mal de chose. Et notamment indexer les index(mots|mot) utiles pour voir le résultat.
      # #{title2}
      ## #{title2_subtitle1}
      Ici on détaille tout ce qu'on va trouver. On doit avoir un index avec « index:mot », avec « index:introduction ».
      ## #{title2_subtitle2}
      Voluptate tempor magna culpa nostrud consectetur elit dolor dolor velit velit id laborum dolore consectetur cupidatat sed adipisicing.
      Nostrud sint consectetur cillum proident dolor occaecat sed reprehenderit officia in et aliquip reprehenderit eiusmod nostrud nostrud laboris aliqua reprehenderit laboris esse irure.
      ## #{title3}
      Non anim in nulla proident ut elit nostrud laborum amet sed officia irure ad cillum incididunt veniam voluptate enim eiusmod nostrud et elit cupidatat culpa et eiusmod nisi exercitation commodo sit officia dolore consequat occaecat amet enim voluptate sunt amet dolor elit esse reprehenderit occaecat dolor ut ut laborum pariatur consectetur ut duis sint et consequat sunt id quis qui aliqua tempor in fugiat nisi sunt aute quis cillum ullamco eiusmod excepteur fugiat ex laboris adipisicing in aliqua tempor nostrud in exercitation est consectetur fugiat amet eiusmod nostrud non reprehenderit sed culpa commodo pariatur et nisi do amet et aute minim elit nostrud id quis ex reprehenderit consectetur ut irure sed laboris elit sunt magna labore mollit laborum officia ea minim ullamco duis ut dolor cupidatat in dolor enim et ut eiusmod occaecat quis labore eu magna ut exercitation eu exercitation do quis ut irure sunt duis incididunt occaecat dolor labore amet deserunt elit sunt labore proident officia elit est et eu ex reprehenderit dolore officia duis cupidatat nisi dolore minim in aute consequat nostrud mollit amet sunt esse est exercitation mollit amet tempor dolor laboris velit ut enim laborum elit minim nostrud culpa sed sit non est irure esse excepteur ut dolor qui ut nulla labore laboris exercitation quis.
      Ça peut faire une belle index:introduction à la dramaturgie, de façon succinte et efficace.
      (( index ))
      TEXT
    end
    return @long_text_with_tdm_and_index.dup
  end

  # @note
  #   Le "-" à la fin des titres permet de ne pas les confondre
  #   Sans ce tiret on pourrait trouver le title1 avec que c'est le
  #   long_title1 qui est inscrit
  def title1
    @title1 ||= "Grand Titre 1-"
  end
  def long_title1
    @long_title1 ||= "Grand Titre 1 très Long et grand-"
  end
  def title2
    @title2 ||= "Grand titre 2-"
  end
  def title3
    @title3 ||= "Troisième sous-titre titre 2-"
  end
  def title1_subtitle1
    @title1_subtitle1 ||= "Sous-Titre 1 du grand titre"
  end
  def title2_subtitle1
    @title2_subtitle1 ||= "Premier sous-titre du grand titre 2"
  end
  def title2_subtitle2
    @title2_subtitle2 ||= "Deuxième sous-titre titre 2"
  end
end #/<< class << self
###################       INSTANCE      ###################

end #/Text
end #/module Factory
