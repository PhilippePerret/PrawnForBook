Prawn4book::Manual::Feature.new do

  titre "Gestion des tirets conditionnels"

  description <<~EOT
    On peut insérer très simplement des tirets conditionnels^^ à l'aide de la marque `{-}` dans le texte, à l’endroit où doit se trouver un tiret conditionnel.
    ^^ Pour rappel, un *tiret conditionnel* permet d’indiquer explicitement où doit se faire une césure (une coupure de mot en fin de ligne à droite) si cette césure est nécessaire et seulement si cette césure est nécessaire, ce qui fait son intérêt. Lorsque le mot est long, on peut placer plusieurs tirets conditionnels qui laisseront _PFB_ choisir le meilleur en fonction du contexte.
    EOT

  trou = ' ' * 6
  sample_texte <<~EOT
    Dans#{trou}ce#{trou}texte,#{trou}vers#{trou}la#{trou}fin#{trou}de#{trou}la#{trou}ligne#{trou}on#{trou}a anti\\{\\-}cons\\{\\-}ti{\\-}tu{\\-}tion{\\-}nel{\\-}lement qui peut s'adapter grâce aux tirets conditionnels.
    Sans les tirets conditionnels :
    Dans#{trou}ce#{trou}texte,#{trou}vers#{trou}la#{trou}fin#{trou}de#{trou}la#{trou}ligne#{trou}on#{trou}a anticonstitutionnellement qui NE peut PAS s'adapter.
    EOT

  texte(:as_sample)

end
