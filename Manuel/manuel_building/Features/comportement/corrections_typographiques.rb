Prawn4book::Manual::Feature.new do
  
  titre "Corrections typographiques"

  description <<~EOT
    _PFB_ procède pour vous à de nombreuses corrections typographiques d’erreurs qu’on rencontre encore trop souvent dans les livres — et même dans les textes de l’éducation nationale —, la typographie étant la grande oubliée de la langue française alors qu’elle répond à des conventions aussi fermes que l’orthographe ou la grammaire. Mais même les professeur\\(e)s, à l’Éducation Nationale, en ignore ou en néglige les règles. Bref…
    Voici les corrections automatique auxquelles procède _PFB_ :
    * Une *espace insécable* avant toute ponctuation double (note : "espace" est féminine, en typographie). Une ponctuation double est une ponctuation qui s’écrit avec deux signes séparés, c’est-à-dire les deux points, le point d’exclamation, le point d’interrogation, le point virgule ou le point d’ironie. Même si vous oubliez cet espace (comme c’est le cas en anglais), PFB le corrige pour vous.
    * En français, on ne doit pas utiliser les guillemets droits ("\\") qu’utilisent le anglais. Par défaut, _PFB_ les remplacera de beaux chevrons français. Sauf si vous précisez, dans la recette, les guillemets à utiliser.
    * De la même manière, même s’il s’agit plus ici d’esthétique, tous les apostrophes simples (droits) seront remplacés par des apostrophes courbes (attention, il arrive que certaines mauvaises polices ne possède pas le glyphe en question).
    * Exposant pour les *n-ième*. PFB corrige même les fautes classiques de "1\\ère" au lieu de "1\\re" ou de "4\\ème"/"4\\eme" au lieu de "4\\e".
    * Les *points de suspension* sont en fait un seul caractère d’imprimerie (on devrait même plus justement parler *du* point de suspension).
    * Le *tiret d’exergue*, souvent remplacé improprement par un signe "-" (moins), sera remplacer par le tiret long (par défaut) ou le demi-long s’il est préconisé dans la recette.
    EOT

    texte <<~EOT, "Les corrections en action"
    #### Les Exposants
    **1\\er** deviendra **1er**.
    **1\\ère** (fautif) deviendra **1re**.
    **12\\e** deviendra **12e**.
    **12\\ème** (fautif) deviendra **12e**.
    **12\\eme** (fautif) deviendra **12e**.
    **XIV\\e** deviendra **XIVe**.
    **XIV\\ème** (fautif) deviendra **XIVe**.
    **XIV\\eme** (fautif) deviendra **XIVe**.
    
    #### Les guillemets et apostrophes
    **\\"mauvais guillemets\\"** deviendra** "mauvais guillemets" **avec de beaux chevrons.
    Ici **l\\'apostrophe** deviendra **l'apostrophe** (grossissez bien la page pour voir la droiture du premier et la courbure du second, qui doit être "**’**").
    
    #### Les espaces avant ponctuations
    **Un oubli\\!** deviendra **Un oubli!**
    
    #### Le\\(s) point\\(s) de suspension
    **Pas trois points\\.\\..** deviendra **pas trois points...** (pour voir cette modification, vous devez essayer de copier les trois points…)

    #### Les tirets longs
    Le tiret long, dans la police courante : — entre tirets — pour voir.
    **entre \\- tirets longs \\- pour voir** deviendra **entre - tirets longs - pour voir**.
    **je sais \\-vraiment\\- bien** deviendra **je sais -vraiment- bien**.
    **je sais \\- vraiment.** deviendra **je sais - vraiment.**
    EOT
end
