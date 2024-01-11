Prawn4book::Manual::Feature.new do

  titre "Stylisation en ligne"


  description <<~EOT
    Nous appelons *stylisation en ligne* ou *inline styling* en anglais la possibilité de styliser un paragraphe quelconque par une ligne de code propre à _PFB_, c’est-à-dire entre double parenthèse. Comme nous l’avons vu dans [[texte/intro_inline_styling]], ce style se met dans une table, entre accolade.
    (( {color: 'FF0000'} ))
    D’ores et déjà, noter que cette stylisation s’applique au paragraphe suivant et *seulement* au paragraphe suivant. C’est-à-dire au texte qui suit, jusqu’à un premier retour chariot. Ce paragraphe a été mis en rouge grâce à cette *stylisation en ligne* et vous noterez que (sans que nous ayons rien fait) le paragraphe suivant a retrouvé l’aspect normal.

    #### Liste des propriétés de la stylisation en ligne

    Voici la liste des propriétés qui peuvent être appliquées au paragraphe suivant (et seulement le paragraphe suivant) :
    * **`size`** | Taille de la police du paragraphe suivant.
    * **`indent`** (ou `indentation`) | Indentation du paragraphe suivant, avec ou sans unité (p.e. '100' ou '8mm').
    * **`font`** | Nom de la police à utiliser. Elle doit bien sûr être définie et embarquée (voir [[recette/definition_fontes]]).
    EOT

  ftsize = 17
  indent = '8mm'
  font   = 'Reenie'

  sample_texte <<~EOT #, "Autre entête"
    \\(( \\{font:"#{font}", size:#{ftsize}, indent:"#{indent}" } \\))
    Le présent paragraphe est mis en forme par de la STYLISATION EN LIGNE qui met la police à #{font}, la taille de police à #{ftsize} pt, l’indentation à #{indent}.
    EOT

  texte(:as_sample)


end
