Prawn4book::Manual::Feature.new do

  titre "Définition de la couleur"


  description <<~EOT
    Dans ***Prawn-For-Book*** comme dans *Prawn*, la couleur s'exprime de façon hexadécimale(( <-(couleur) )).
    Une couleur hexadécimale — c'est-à-dire "exprimée en base 16" — est composée de trois paires de chiffres/lettres — par exemple 'AA', 'BB' et 'CC' qui forment 'AABBCC' — chaque paire représente une valeur de 0 à 125 — '00' vaut 0 et 'FF' vaut 125 — en RGB — Red/rouge, Green/vert, Blue/bleu — c'est-à-dire que la première paire indique la quantité de rouge, la seconde la quantité de vert et la troisième la quantité de bleu)
    Quand tous les signes sont égaux — par exemple '55555' — la couleur est grise, sauf pour '000000' qui est noir et 'FFFFFF' qui est blanc.
    EOT

  sample_texte <<~EOT
    Un texte avec du <color rgb="000077">bleu</color>.
    EOT

  texte <<~EOT
    Un texte avec du <color rgb="000077">bleu</color>.
    EOT

end
