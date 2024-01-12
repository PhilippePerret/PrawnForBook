Prawn4book::Manual::Feature.new do

  titre "Stylisation en ligne"


  description <<~EOT
    Nous appelons *stylisation en ligne* ou *inline styling* en anglais la possibilité de styliser un paragraphe quelconque par une ligne de code propre à _PFB_, c’est-à-dire entre double parenthèse. Comme nous l’avons vu dans [[texte/intro_inline_styling]], ce style se met dans une table, entre accolade.
    \\(( \\{color: \\"FF0000\\"} ))
    (( {color: "FF0000"} ))
    D’ores et déjà, noter que cette stylisation s’applique au paragraphe suivant et *seulement* au paragraphe suivant. C’est-à-dire au texte qui suit, jusqu’à un premier retour chariot. Ce paragraphe a été mis en rouge grâce à cette *stylisation en ligne* et vous noterez que (sans que nous ayons rien fait) le paragraphe suivant a retrouvé l’aspect normal.

    #### Stylisation en ligne par table

    Comme vous pouvez le voir, la *stylisation en ligne* se fait en définissant une table, c’est-à-dire un code simple, entre accolades : `\\{..\\.}`.
    Experts : sachez qu’il s’agit simplement d’une table ruby, et vous pouvez passer à la suite.
    À l’intérieur de ces deux accolades, on va trouver les *propriétés* avec leur *valeur*. Ci-dessus, on trouve la *propriété* `color` ("couleur" en anglais) avec la *valeur* `FF0000`
    Pour définir une proprité, on a donc son nom, suivi tout de suite de deux points (ne surtout pas mettre d’espace) et sa valeur :
    (( line ))
    (( {align: :center} ))
     `{ \\<propriété>: \\<valeur> }` 
    (( line ))
    Chaque définition de propriété est séparée par une virgule.
    (( line ))
    (( {align: :center} ))
     `{ \\<propriété1>: \\<valeur>,  \\<propriété2>: \\<valeur>, \\<propriété3>: \\<valeur>, etc.}` 
    (( line ))
    La *valeur*, très souvent, est un nombre (p.e. "`12`") ou une chaine de caractères entre guillemets droits (p.e. "\\"Bonjour\\""). Il peut arriver que ce soit un `Symbol` (un type particulier du langage Ruby reconnaissable à ses deux points au début) (p.e. "`:center`") ou une constante définie par _PFB_ ou par vous (p.e. "`LINE_HEIGHT`").
    La *valeur* peut être aussi une dimension avec unité. Dans ce cas, elle doit obligatoirement être mise entre guillemets droits, par exemple "`\\"2.5cm\\"`". Comme vous pouvez le voir, une valeur flottante (décimale) utilise le point anglais, par la virguler française.
    Mais cette valeur peut être aussi une opération (p.e. "`2 * LINE_HEIGHT`"), une concaténation (p.e. "`"une" + " concat"`") ou toute autre expression que Ruby comprend (p.e. "`%\\w\\{un autre jour}.join(\\"+\\")`" qui produira "`un+autre+jour`")).

    #### Liste des propriétés de la stylisation en ligne

    Voici la liste des propriétés qui peuvent être appliquées au paragraphe suivant (et seulement le paragraphe suivant) :
    * **`size`** | Taille de la police du paragraphe suivant.
    * **`font`** | Nom de la police à utiliser. Elle doit bien sûr être définie et embarquée (voir [[recette/definition_fontes]]).
    * **`style`** | Le style à appliquer, parmi `normal`, `italic`, `bold`, `[:italic, :bold]` ou tout autre style défini explictement pour les fontes embarquées. Voir [[recette/definition_fontes]].
    * **`indent`** (ou `indentation`) | Indentation du paragraphe suivant, avec ou sans unité (p.e. '100' ou '8mm').
    * **`align`** | Alignement du paragraphe. Peut avoir l’une des valeurs *Symbol* suivante : `:left` ("gauche" en anglais, donc alignement à gauche), `:right` ("droite" en anglais, donc alignement à droite), `:center` ("centre" en anglais, donc centré) ou `:justify` ("justifié" en anglais donc justifié — noter que par défaut, un paragraphe est justifié, dans _PFB_, donc cette marque ne serait utile que dans un contexte où le paragraphe ne serait plus centré, un tableau par exemple).
    * **`margin_left`** | ("marge gauche" en anglais) définit la marge gauche.
    * **`margin_right`** | ("marge droite" en anglais) définit la marge droite suplémentaire laissée après le texte.
    * **`kerning`** | ("crénage" en anglais) si la valeur est à `true` (elle l’est par défaut), Prawn gèrera de façon intelligente les espaces entre les lettres pour avoir le meilleur rendu.
    * **`character_spacing`** | ("espace entre les lettres" en anglais)
    * **`word_space`** | ("espace entre mots" en anglais) définit explicitement l’espace qu’on veut trouver entre deux mots. À utiliser discrètement et parcimonieusement.
    EOT

  @segments = []

  def add_to_segments(seg)
    @segments << "Le code :"
    @segments << "(( line ))"
    @segments << "```\n#{seg}\n```"
    @segments << "… produira :"
    @segments << "(( line ))"
    @segments << seg # .gsub(/\\/.freeze, '')
    @segments << "(( line ))"
  end


  ftsize  = 20
  indent  = '8mm'
  font    = 'Reenie'
  couleur = 'FF0FF0'

  add_to_segments <<~EOT
  (( {font:"#{font}", size:#{ftsize}, indent:"#{indent}", color:"#{couleur}" } ))
  Le présent paragraphe est mis en forme par de la STYLISATION EN LIGNE qui met la police à #{font}, la taille de police à #{ftsize} pt, l’indentation à #{indent} et la couleur à #{couleur}.
  EOT

  add_to_segments <<~EOT
  (( {margin_left: "2cm", margin_right: "2cm"} ))
  Un paragraphe qui se trouve entre deux marges resserrée de 2 cm chacune.
  EOT
  
  add_to_segments <<~EOT
  (( {margin_left: "2cm", width: PAGE_WIDTH - 4.cm } ))
  Le même résultat (deux marges supplémentaire de 2 centimètres) peut s’obtenir avec la propriété ’width’ et un calcul.
  EOT

  add_to_segments <<~EOT
  (( { character_spacing: 4, kerning: true, align: :left } ))
  Un texte avec les lettres espacées.
  (le *kerning* à `true` indique de gérer les espaces entres les lettres pour avoir le meilleur rendu)
  EOT

  # - Pas pris en compte pour le moment -
  # wspace = 40

  # add_to_segments <<~EOT
  # (( { word_space: #{wspace} } ))
  # Un texte dont tous les mots ont été séparés de #{wspace} points-postscript.
  # EOT

  lbef = 4
  laft = 3
  
  add_to_segments <<~EOT
  Le paragraphe avant pour voir les lignes vides après.
  (( { lines_before: #{lbef}, lines_after: #{laft} } ))
  Un texte avec un `lines_before` de #{lbef} (donc #{lbef} lignes vides avant)  et un `lines_after` de #{laft} (donc avec #{laft} lignes vides après.
  Le paragraphe après pour voir les lignes vides avant.
  EOT

  # On assemble le texte
  texte(@segments.join("\n"))


end
