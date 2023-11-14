Prawn4book::Manual::Feature.new do

  titre "Insérer une image"


  new_page_before(:feature)
  new_page_before(:texte)

  description <<~EOT
    Pour insérer une image dans le flux du livre, on utilise le code pseudo-markdown **`\\!\\[chemin/vers/image]`**. Si des données sont à passer, on utiliser **`\\!\\[vers/image](\\<data>)`** où `\\<data>` est une [[table_ruby]].
    Noter que ce code doit obligatoirement se trouver sur une ligne seule.

    ##### Chemin d’accès à l’image

    Le chemin d’accès à l’image peut se donner…
    * relativement au dossier du livre,
    * relativement au dossier 'images' du livre (s’il existe),
    * relativement au dossier de la collection s’il y a collection,
    * relativement au dossier 'images' de la collection s’il y a collection.
    Les formats (jpg, tiff, png, svg)

    ##### Positionnement de l’image

    Par défaut, l’image est placée au centre. Pour la mettre à droite ou à gauche, utiliser respectivement `align: right`, `align: :left` et/ou la définition de `left` (décalage avec la marge gauche) et `right` (décalage avec la marge droite), comme dans les exemples ci-dessous.
    Par défaut, l’image s’insère de façon fluide et naturelle avec le texte qui la précède et qui la suit. Mais on peut définir l’espacement de façon très précise avec les propriétés `space_before` ("espace avant") et `space_after` ("espace après"), comme dans les exemples suivant (voir l’exemple 18, par exemple, à la page ->(exemple_image_18)).

    Pour un placement optimum, on peut ajuster la position de l’image verticalement à l’aide de `vadjust` ("ajustement vertical"). L’ajustement horizontal, bien entendu, peut se faire avec `right` et `left`. Bien sûr, il est raisonnable de ne faire ces aajustements qu’à la dernière minute, lorsque le livre est presque finalisé.

    ##### Taille de l’image

    La taille de l’image peut être définie avec `width:` (largeur), `height:` (hauteur) et/ou `scale:` (échelle). Notez que la largeur sera toujours ramenée à la largeur du livre si elle est supérieure, et la hauteur sera toujours ramenée à sa hauteur de la page si elle excède. Si vraiment on sait ce qu’on veut faire et qu’on désire tout contrôler soi-même, on peut ajouter l’option `no_resize: true` qui empêchera tout redimensionnement (à vos risques et péril 🤣 comme dans l’exemple 19 à la page ->(exemple_image_19)).

    ##### Légende de l’image

    Une légende peut être définie en donnant la donnée `legend: \\"La légende de l’image\\"`. Par défaut, cette légende sera inscrite avec la même police que la police courante, avec une taille de une unité inférieure et en italique.

    {{TODO: Modification, par la recette, de a) la taille, b) le style, c) la police, d) la largeur de la légende}}

    ##### Image SVG

    Les images SVG sont incontestablement les meilleures images pour l’impression dans le sens où elles conservent leurs qualités quelle que soit la taille adoptée. On peut le voir sur les exemples ci-dessous. Elles sont donc à privilégier.

    ##### Rogner une image SVG

    Rogner une image svg [[image_rogner_svg]].

    {{TODO: les data}}

    ##### Exemples

    Les exemples ci-dessous sont tous construits à partir du code exact donné en exemple. Vous pouvez donc lui faire pleinement confiance.
    EOT

  ex16_height = 1000

  EXEMPLES = {
    1 => {
      text:   "Une image trop large sera réduite à la taille du livre.",
      code:   '\!\[images/exemples/plus_large.jpg]',
      line_after: true
    },
    2 => {
      left: true,
      text: 'La même image, mais avec une légende, insérée (notez qu’ici on n’a pas indiqué `images` dans le chemin d’accès, puisque ce dossier est implicite).',
      code: '\!\[exemples/plus_large.jpg](legend:\\"Image plus grande réduite en largeur\\")',
      page_after: true
    },
    3 => {
      text: 'Une image PNG trop haute, *sans légende*, qui sera réduite à la taille d’une page du livre et mise sur la page suivante.',
      code: '\!\[exemples/plus_haute.png]'
    },
    4 => {
      text: 'Une image PNG trop haute, *avec légende*, qui sera réduite à la taille d’une page du livre et mise sur la page suivante.',
      code: '\!\[exemples/plus_haute.png](legend:\\"Image plus haute réduite et\\<br>placée sur la page suivante\\")',
      page_after: true
    },
    5 => {
      text: 'Une image PNG trop haute, dont on réduit explicitement la hauteur.',
      code: '\!\[exemples/plus_haute.png](height:\\"30%\\", legend:\\"Trop haute avec height à 30%\\")',
      left: true,
    },
    6 => {
      left: true,
      text: 'Une image PNG trop haute, dont on réduit explicitement la hauteur mais qui doit faire la largeur de la page. Elle va bien entendu être complètement déformée…',
      code: '\!\[exemples/plus_haute.png](height:\\"30%\\", width:\\"100%\\", legend:\\"Trop haute avec height à 30% et width à 100%\\")'
    },
    7 => {
      text: 'Une image plus petite que la largeur sera laissée telle quelle.',
      code: '\!\[exemples/moins_large.jpg](legend:\\"Image centrée\\")',
      line_after: true
    },
    8 => {
      text: 'Image plus petite en largeur, alignée à gauche et décalée vers la droite, sans légende.',
      code: '\!\[exemples/moins_large.jpg](left: \\"2cm\\")',
      line_after: true
    },
    9 => {
      text: 'Image plus petite en largeur, avec légende, alignée à gauche et décalée vers la droite. Noter comment la légende a été découpée pour passer à la ligne. Noter également l’utilisation d’un ajustement vertical pour l’image (`vadjust`) et pour la légende (`vadjust_legend`).',
      code: '\!\[exemples/moins_large.jpg](left: \\"2cm\\", vadjust: 1, legend:\\"Image à gauche décalée\<br>vers\<br>la droite\\", vadjust_legend: 10)',
      left: true,
      line_after: true
    },
    10 => {
      text: 'Image plus petite en largeur alignée à droite.',
      code: '\!\[exemples/moins_large.jpg](align: :right, legend:\\"Alignée à droite\\")',
      left: true,
      line_after: true
    },
    11 => {
      text: 'Image plus petite en largeur alignée à droite et décalée vers la gauche.',
      code: '\!\[exemples/moins_large.jpg](right: 2.cm, legend:\\"À 2 cm de la droite\\")',
      line_after: true
    },
    12 => {
      text: 'Image plus petite que la largeur, agrandie avec "`width: \"100%\"`" pour tenir dans la largeur (déconseillé car cela "abîme" l’image).',
      code: '\!\[exemples/moins_large_et_bas.jpg](width:\\"100%\\", legend:\\"Image agrandie à 100 % avec une grande légende qui doit tenir sur plusieurs lignes car une légende, par défaut, couvre la moitié de la page, mais on peut changer ce comportement.\\")',
      left: true,
      line_after:true
    },
    13 => {
      text: 'Image plus grande grâce à "`scale: 2.5`".',
      code: '\!\[exemples/moins_large.jpg](scale: 2.5, legend:\\"Image avec scale de 2.5\\")',
      left: true,
    },
    14 => {
      text: 'Image SVG affichée sans aucune indication.',
      code: '\!\[exemples/image.svg]',
    },
    15 => {
      text: 'Image SVG grossie.',
      code: '\!\[exemples/image.svg](width: \\"100%\\")',
    },
    16 => {
      text: "On ne peut pas (à ma connaissance) modifier disproportionnellement une image SVG dans Prawn même avec des valeurs explicites. Ci-dessous, la hauteur, bien que mise à #{ex16_height}, reste proportionnée à la largeur.",
      code: "\\!\\[exemples/image.svg](width: 200, height: #{ex16_height})",
    },
    17 => {
      text: 'Image SVG avec légende. Remarquez l’utilisation de `vadjust_legend ("ajustement vertical de la légende") qui permet ici de l’éloigner de l’image.`',
      code: '\!\[exemples/image.svg](width:\\"80%\\", legend:\\"Image SVG avec légende\\", vadjust_legend: 10)',
      left: true,
    },
    18 => {
      text: '<-(exemple_image_18)Image avec de l’espace avant et de l’espace après définis par les propriétés `space_before` ("espace avant") et `space_after` ("espace après").',
      code: '\!\[exemples/plus_large.jpg](space_before:180, space_after: 100, legend:\\"La légende se place toujours bien.\\")',
      left: true,
      page_before: true,
    },
    19 => {
      text: '<-(exemple_image_19)Image sans aucun redimensionnement, grâce à l’option `no_resize`. Cette image "mange" évidemment sur la marge extérieure…',
      code: '\!\[exemples/plus_large.jpg](no_resize:true, width:1000, left:0.1)',
      left: true,
      page_before: true,

    },
  } #/ EXEMPLES

  # last_for_try = 5
  last_for_try = 18

  lines = []
  # (1..last_for_try).each do |iex|
  # [last_for_try].each do |iex|
    # data_exemple = EXEMPLES[iex]
  EXEMPLES.each do |iex, data_exemple|
    lines << data_exemple[:before] if data_exemple[:before]
    lines << '(( new_page ))' if data_exemple[:page_before]
    lines << '(( {align: :left} ))' if data_exemple[:left]
    lines << "**EXEMPLE #{iex} • ** #{data_exemple[:text]}<br>`#{data_exemple[:code]}`"
    lines << deslash(data_exemple[:code])
    lines << data_exemple[:after] if data_exemple[:after]
    lines << '(( line ))' if data_exemple[:line_after]
    lines << '(( new_page ))' if data_exemple[:page_after]
  end
  lines << "Fin des exemples d’images."

  texte lines.join("\n"), "Aspect des images en fonction du code"

end
