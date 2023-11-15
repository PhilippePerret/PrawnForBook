Prawn4book::Manual::Feature.new do

  # titre "Les puces"
  # SUITE DES PUCES
  # 

  subtitle "Puce personnalisées"

  description <<~EOT
    Enfin, on peut utiliser des puces personnalitées partant d'une image que vous fournissez. Il suffit de donner son chemin d'accès soit relatif, par rapport au dossier du livre ou de la collection (recommandé), soit absolu. Dans l'exemple, la puce se trouve dans le dossier 'images' du livre qui, comme son nom l'indique, contient toutes les images que nous utilisons dans le manuel.

    On peut aussi définir la propriété `:height` pour la hauteur de l'image. Si `:width` est défini (et non proportionnel), l'image sera déformée, sinon, la largeur sera proportionnellement adaptée à la hauteur.
    EOT

  puce    = "images/custom_bullet.png"
  vadjust = -2
  size    = 14
  left    = 8

  recipe <<~YAML
    #<book_format>
    book_format:
      text:
        puce:
          text: '#{puce}'
          size: #{size}
          vadjust: #{vadjust}
          left: #{left}mm
    #</book_format>
    YAML

  init_recipe([:format_text])

  _ps = vadjust > 1 ? 's' : ''
  
  sample_texte <<~EOT
    * Ceci est une puce personnalisée de #{size} points, remontée de #{vadjust} point#{_ps}, avec les autres paramètres laissés intacts,
    * Le second item identique,
    * Le troisième.
    EOT

end
