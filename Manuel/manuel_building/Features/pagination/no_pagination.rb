Prawn4book::Manual::Feature.new do

  sous_titre "Page sans pagination"
  #
  # Lire la note du fichier arret_pagination pour comprendre pourquoi
  # on met cette partie dans un autre fichier (donc une autre
  # fonctionnalité)

  description <<~EOT
    On peut également supprimer la pagination de la page courante avec la marque `\\(( no_pagination ))`.
    Pour obtenir la page suivante, nous avons utilisé le code :
    ~~~
    (( new_page ))
    (( no_pagination ))
    (( move_to_line(12) ))
    (( {size:20} ))
    Cette page ne possède ni numéro de page ni entête.
    (( new_page ))
    ~~~
    (( new_page ))
    (( no_pagination ))
    (( move_to_line(12) ))
    (( {size:20} ))
    Cette page ne possède ni numéro de page ni entête.
    (( new_page ))
    \#{-book.page(pdf.page_number).pagination = true}
    EOT

    # NOTE : Attention : on ne peut pas vraiment faire une vraie
    # simulation, du fait que ce n’est pas vraiment le texte en flux
    # normal. Donc si on met plusieurs pages, par exemple, on se
    # retrouve avec d’autres pages encore après qui n’ont pas de
    # pagination non plus. Alors qu’en mode réel, tout fonctionne
    # bien.

end
