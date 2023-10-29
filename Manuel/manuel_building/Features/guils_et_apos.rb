Prawn4book::Manual::Feature.new do

  titre "Correction automatique des guillemets et apostrophes"

  description <<~EOT
    En belle typographie, les guillemets et les apostrophes ne s'utilisent pas en dépit du bon sens, ils répondent, tout comme les ponctuations, à des certaines règles. Certaines sont relatives, d'autres sont absolues.
    Tous les apostrophes droits (« ' ») seront remplacés par des apostrophes courbes (« ’ »).
    Tous les guillemets droits (« " ») — réservés à la langue anglaise — sont transformés en guillemets courbes (“…”) ou en chevrons (« … ») en fonction de la recette du livre ou de la collection.
    Les espaces insécables oubliées* avant les ponctuations doubles sont ajoutées et les points de suspension en trois points sont remplacés par leur signe unique.
    * « espace » est un mot féminin en typographie.
    De la même manière, pour les tirets longs ou demi-longs pour mettre du texte en exergue — comme ici —, il est nécessaire de mettre à l'intérieur des espaces insécables qui empêcheront le tiret de se retrouver seul à la ligne.
    EOT

  sample_recipe <<~EOT
    book_format:
      text:
        guillemets: ['« ', ' »']
    EOT

  recipe({guillemets: ['« ', ' »']})

  sample_texte <<~EOT
    Remarquez ici le \\"guillemets droits\\" et il y a plein d'apostrophes droits mais laissés dans du \#{'#'}{"code"} reconnu comme tel.
    Un point d'exclamation doit être toujours précédé d'une espace insécable\\! Comme le point d'interrogation\\? Oui.\\.. (après ce \\"oui\\", trois points seront remplacés par un seul signe que nous appelons "LE point de suspension" \\—essayez de les attraper avec votre souris\\—)
    Remarquez ci-dessus le texte entre tirets longs. Des espaces ont été ajoutées.
    EOT

  texte <<~EOT
    Remarquez ici le "guillemets droits" et il y a plein d'apostrophes droits mais laissés dans du \#{"code"} reconnu comme tel.
    Un point d'exclamation doit être toujours précédé d'une espace insécable! Comme le point d'interrogation? Oui... (après ce "oui", trois points seront remplacés par un seul signe que nous appelons "LE point de suspension" —essayez de l'attraper avec votre souris—)
    Remarquez ci-dessus le texte entre tirets longs. Des espaces ont été ajoutées.
    EOT

end
