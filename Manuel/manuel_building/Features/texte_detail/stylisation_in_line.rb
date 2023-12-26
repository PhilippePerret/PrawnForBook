Prawn4book::Manual::Feature.new do

  titre "La Stylisation en ligne"

  description <<~EOT
    La *stylisation en ligne* (*in line* en anglais) concerne une fonctionnalité très puissante de _PFB_. Elle permet, ponctuellement, de styliser le paragraphe suivant.
    (( {color: 'FF0000'} ))
    D’ores et déjà, noter que cette stylisation s’applique au paragraphe suivant et *seulement* au paragraphe suivant. C’est-à-dire au texte qui suit, jusqu’à un premier retour chariot. Ce paragraphe a été mis en rouge grâce à cette *stylisation en ligne* et vous noterez que (sans que nous ayons rien fait) le paragraphe suivant a retrouvé l’aspect normal.
    La *stylisation en ligne*, est donc un code, simple, qui se place sur la ligne juste au-dessus du paragraphe que l’on veut styliser.
    EOT


end
