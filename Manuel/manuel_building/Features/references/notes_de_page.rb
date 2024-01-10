Prawn4book::Manual::Feature.new do


  new_page_before(:feature)

  titre "Notes de pages"

  description <<~EOT
    Un des partis-pris fort de _PFB_, que certains regretteront sans doute, est de ne jamais utiliser de *notes de bas de page*. Malgré leur usage, nous pensons qu'elles offrent une mauvaise expérience à la lectrice ou au lecteur, et que souvent ce lecteur ou cette lectrice n’apprécie pas d'interrompre sa lecture pour consulter ces notes.
    
    Nous avons donc pris l'option d'utiliser plutôt les "notes de page" qui se placent, en général, à la fin du paragraphe ou à la fin du bloc cohérent de paragraphes (vous pouvez les placer à l’endroit que vous voulez, mais elles seront toujours insérées dans le flux du texte, donc sur la page suivante si vous les placez trop loin).

    Vous pouvez également décider de les reporter toutes à la fin de l'ouvrage. Mais alors, assurez-vous que ce ne soit pas des notes capitales dont l’ignorance nuierait à la compréhension du texte…

    EOT

  sample_texte <<~EOT
    Ceci est un paragraphe avec une note numérotée^{-}^ de façon automatique, bien pratique par exemple pour les notes de fin d'ouvrage.
    Ceci est un paragraphe avec une note numérotée^{-}112 explicitement.
    ^{-}^ Note de la note numérotée automatiquement.
    ^{-}112 Note de la note numéroté explicitement.
    EOT

  texte <<~EOT
    Ceci est un paragraphe avec une note numérotée^^ de façon automatique, bien pratique par exemple pour les notes de fin d'ouvrage.
    Ceci est un paragraphe avec une note numérotée^112 explicitement.
    ^^ Note de la note numérotée automatiquement.
    ^112 Note de la note numéroté explicitement.
    Un paragraphe après les notes.
    EOT

end
