Prawn4book::Manual::Feature.new do

  new_page_before(:feature)

  titre "Les références croisées"

  description(File.read(__dir__+'/cross_references.md'))

  sample_texte <<~EOT
    J’ai dans cette phrase une cible MA_CIBLE qui sera appelée à la page suivante\\<-(exemple_cible).
    \\(( new_page ))
    La cible MA_CIBLE se trouve à la page \\->(exemple_cible).
    Sur ce paragraphe je fais référence à un passage qui se trouve \\->(ex_autre_cible|sur la \\_ref_ du livre) avec un appel personnalisé.

    EOT

  ex1 = 'Une référence à \->(exemple_cible|une _ref_ deux) pour voir.'

  ex2 = 'Une référence à \->(exemple_cible| la page bonne _page_) pour avoir le numéro.'

  ex3 = 'Une référence \->(exemple_cible|au paragraphe _paragraph_ de la page _page_ \\\\(_ref_\\\\)).'

  texte <<~EOT
    J’ai dans cette phrase une cible MA_CIBLE qui sera appelée à la page suivante<-(exemple_cible).

    (( new_page ))

    La cible MA_CIBLE se trouve à la page ->(exemple_cible).

    <-(ex_autre_cible)
    Ici se marque une référence (cible) à AUTRE_CIBLE pour montrer, sur la page suivante, comment sera présentée la marque personnalisée.

    (( new_page ))

    Sur ce paragraphe je fais référence à un passage qui se trouve ->(ex_autre_cible|sur la _ref_ du livre) avec un appel personnalisé.

    #### Marque personnalisée

    Dans la marque personnalisée, on peut utiliser `_ref_` pour indiquer où doit se marquer la marque de référence.
    * `#{ex1}`
    => #{deslash(ex1)}

    (( line ))

    On peut utiliser `_page_` pour le numéro de page (et seulement le numéro de page).
    * `#{ex2}`
    => #{deslash(ex2)}

    (( line ))

    Enfin, on peut utiliser `_paragraph_` (sans "e") pour le numéro du paragraphe^^.

    * `#{ex3}`^^
    => #{deslash(ex3)}

    ^^ Mais dans ce cas, notez que suivant le format de pagination, ce numéro pourra être le numéro absolu ou le numéro par rapport à la double-page (cf. [[pagination]])
    ^^ Noter que les parenthèses, à l’intérieur de la *marque de référence*, ont été "échappées" (précédées du signe "\\\\") afin de ne pas être prises pour la fin de l’*appel* de référence.
    EOT

end
