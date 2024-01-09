Prawn4book::Manual::Feature.new do


  description <<~EOT
    Enfin, on peut utiliser des puces personnalitées partant d'une image que vous fournissez. Il suffit de donner son chemin d'accès soit relatif, par rapport au dossier du livre ou de la collection (recommandé), soit absolu. Dans l'exemple, la puce se trouve dans le dossier 'images' du livre qui, comme son nom l'indique, contient toutes les images que nous utilisons dans le manuel.

    On peut aussi définir la propriété `:height` pour la hauteur de l'image. Si `:width` est défini (et non proportionnel), l'image sera déformée, sinon, la largeur sera proportionnellement adaptée à la hauteur.
    EOT

  data_for_puce(
    subtitle:   "Puce personnalisée",
    puce:       "images/custom_bullet.png",
    size:       14,
    vadjust:    2,
    left:       8,
    )

end
