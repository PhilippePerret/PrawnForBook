Prawn4book::Manual::Feature.new do

  subtitle "Formatage des notes de pages"

  description <<~EOT
    Comme tous les autres aspects d’un livre _PFB_, l’aspect des notes de page peut être réglé de façon très fine grâce à la recette du livre ou de la collection.

    On peut définir la fonte, la taille et le style. On peut définir si les traits qui sont mis au-dessus et en dessous doit être appliqués (pour ne pas les imprimer, mettre `note_page_borders` à `false` ou `0`).
    Par défaut, les notes sont alignées à gauche comme le texte, mais grâce à `note_page_left`, on peut définir de les mettre en retrait. La valeur est un nombre de points-pdf (points post-script).
    EOT

  recipe <<~EOT #, "Autre entête"
    ---
      .\\..
      book_format:
        text:
          notes_page:
            font: "Times-Roman"
            size: 15
            style: ""
            color: CCCCCC
            borders: 8
            border_color: 00FF00
            left: 40
    EOT

  init_recipe([:fonte_note_page])

  texte <<~EOT
    Ceci est une note automatique^^ avec une autre note auto-incrémentée^^ et une troisième note^^ pour voir.
    On en a même une quatrième^^ sur un autre paragraphe.
    ^^ Explication de la note automatique
    ^^ Explication de la note auto-incrémentée (ou "note automatique")
    ^^ Explication de la troisième note, qui tiendra elle sur trois lignes pour bien voir l’aspect de ces notes et voir que la ligne (le *border*) est conforme à ce que l’on a décidé, avec couleur et épaisseur.
    ^^ Bien sûr, les explications des notes auto-incrémentées doivent être dans l’ordre de leur apparition dans les paragraphes.
    Un paragraphe à la suite du bloc de notes.
    EOT

end
