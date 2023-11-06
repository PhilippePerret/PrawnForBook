Prawn4book::Manual::Feature.new do

  titre "Gestion des tirets conditionnels"

  description <<~EOT
    On peut insérer très simplement des tirets conditionnels à l'aide de la marque {-}.
    EOT

  sample_texte <<~EOT
    Dans ce texte, vers la fin de la ligne on a anti{-}cons{-}ti{-}tu{-}tion{-}nel{-}lement qui peut s'adapter grâce aux tirets conditionnels.
    EOT

  texte <<~EOT
    Dans ce texte, vers la fin de la ligne on a anti{-}cons{-}ti{-}tu{-}tion{-}nel{-}lement qui peut s'adapter grâce aux tirets conditionnels.
    EOT

end
