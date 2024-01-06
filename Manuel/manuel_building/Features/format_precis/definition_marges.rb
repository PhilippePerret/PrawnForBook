Prawn4book::Manual::Feature.new do

  titre "Définition des marges"

  description <<~EOT
    ![marges.svg](name: "Définition des marges, entêtes et pieds de page")
    Des marges par défaut sont proposées, mais vous pouvez tout à fait définir celles que vous voulez très précisément, dans la recette du livre ou de la collection.
    La seule chose à comprendre, par rapport aux documents dont vous avez l'habitude, c'est qu'ici les pages sont paires ou impaires, en vis-à-vis, et définissent donc :

    * une marge haute et une marge basse (traditionnelle),

    * une marge *intérieure*, qui comme son nom l'indique est à l'intérieur du livre, près de la reliure, de la *charnière*, du *dos du livre* (souvent confondu avec la *tranche du livre*),

    * une marge *extérieure*, qui comme son nom l'indique est tournée vers l'extérieur du livre, vers la tranche (la vraie cette fois).

    Ces marges sont donc définies par les propriétés `top` ("haut" en anglais) `bot` (pour « bottom », "bas" en anglais), `ext` (pour « extérieur ») et `int` (pour « intérieur »).

    NB : Quels que soient les réglages, il y aura toujours un *fond perdu* ("bleeding" en anglais) de 10 pps (points-postscript) autour de la page. C’est la "marge" que s’accorde l’imprimeur pour découper le livre.
    Traditionnellement, la marge intérieure est plus large que la marge extérieure, car une bonne partie de cette marge est prise dans la reliure.
    De la même manière, la marge basse est plus large que la marge haute car elle contient le numéro de page. Il peut cependant arriver que la marge haute contienne un entête.

    Pour régler parfaitement les marges, vous pouvez soit ajouter l'option `-margins` à la commande `pfb build` qui construit le livre, soit mettre le `show_margins` de la recette à true, comme nous l'avons fait ci-dessous.

    Dans l'exemple ci-dessous nous avons volontaire *pousser* les valeurs pour rendre bien visibles les changements. 
    EOT

  top_margin = 40
  bot_margin = 20
  int_margin = 35
  ext_margin = 2

  top_mg_mm = "#{top_margin}mm".to_pps
  bot_mg_mm = "#{bot_margin}mm".to_pps
  int_mg_mm = "#{int_margin}mm".to_pps
  ext_mg_mm = "#{ext_margin}mm".to_pps

  real_recipe <<~EOT
    book_format:
      page:
        margins:
          top: #{top_margin}mm
          bot: #{bot_margin}mm
          ext: #{ext_margin}mm
          int: #{int_margin}mm
        show_margins: true
    EOT

  real_texte <<~EOT
    Pour cette page, où les marges sont visibles, on illustre des marges de page à #{top_margin} mm en haut, #{bot_margin} mm en bas, #{int_margin} mm à l'intérieur et #{ext_margin} mm à l'extérieur.
    Vous remarquez donc une immense marge en haut, une grande marge en bas, une marge externe toute petite (*ce qui ne serait pas du tout bon pour une impression de livre*) et une marge intérieure moyenne.
    Remarquez aussi que le texte est automatiquement justifié, il s'aligne parfaitement sur le bord de ces marges gauche et droite, ce qui donne un rendu impeccable.
    EOT

  texte <<~EOT
    Les marges sont visibles grâce au `show_margins` mis à `true` dans la recette. On aurait pu aussi jouer la commande avec l’option `-margins`.
    ![page-1](height:300)
    ![page-2](height:300)
    EOT
end
