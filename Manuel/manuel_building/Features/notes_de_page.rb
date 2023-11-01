Prawn4book::Manual::Feature.new do


  new_page_before(:feature)

  titre "Notes de pages"

  description <<~EOT
    Un parti-pris de ***Prawn-For-Book***, que certains regretteront sans doute, est de ne jamais utiliser de notes de bas de page. Si elles sont souvent pratiquées, nous pensons qu'elles offrent une mauvaise expérience à la lectrice ou au lecteur, et que souvent il ne prend pas la peine d'interrompre le flux de sa lecture pour consulter une note.
    
    Nous avons donc pris l'option d'utiliser plutôt les "notes de page" qui se placent plutôt, en général, à la fin du paragraphe ou à la fin du bloc cohérent de paragraphes.

    Ou de les reporter toutes à la fin de l'ouvrage.

    EOT

  sample_texte <<~EOT
    Ceci est un paragraphe avec une note numérotée^^ de façon automatique, bien pratique par exemple pour les notes de fin d'ouvrage.
    Ceci est un paragraphe avec une note numérotée^112 explicitement.
    
    ^^ Note de la note numérotée automatiquement.
    ^112 Note de la note numéroté explicitement.
    EOT

  texte <<~EOT
    Ceci est un paragraphe avec une note numérotée^^ de façon automatique, bien pratique par exemple pour les notes de fin d'ouvrage.
    Ceci est un paragraphe avec une note numérotée^112 explicitement.
    
    ^^ Note de la note numérotée automatiquement.
    ^112 Note de la note numéroté explicitement.
    EOT

end
