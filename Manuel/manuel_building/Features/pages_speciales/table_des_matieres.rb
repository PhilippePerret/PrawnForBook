Prawn4book::Manual::Feature.new do

  titre "Table des matières"

  description <<~EOT
    Page 11, dans notre comptage intégral, on imprime la table des matières à l’endroit voulu à l’aide de la marque :
    **`\(( tdm \))`** pour "T"able "D"es "M"atières
    ou :
    **`\(( toc \))`** pour "T"able "Of" "C"ontent ("table des matières" en anglais).

    Noter que la table des matières, sauf indication contraire, se placera toujours sur une *belle page*, c’est-à-dire sur une page de droite.

    La *table des matières*, contrairement aux autres pages d’un livre _PFB_, va nécessité une attention particulière, en tout cas lorsqu’elle tient sur plusieurs pages.

    {{À REPRENDRE PAR RAPPORT À LA NOUVELLE APPROCHE}}
    On peut cependant empêcher ce comportement en mettant la propriété `not_on_even` ("pas sur la paire" en anglais) à true dans la recette.

    #### Table des matières en début d’ouvrage

    Si on inscrit la table des matières en début d’ouvrage, il faut calculer le nombre de pages qu’elle va occuper et le définir dans la propriété `page_count` de la section `table_of_content` ("table des matières" en anglais). Ce nombre doit être pair et il vaut 2 par défaut.
    Dans la pratique, estimez grossièrement la longueur de la table des matières en fonction de la taille de l’ouvrage et du nombre de titres et ajoutez 2 pour garder une certaine latitude. Ajustez le nombre final une fois l’ouvrage presque achevé pour supprimer les pages superflues (ou ajoutez-en de nouvelles si la table des matières "mange" sur le texte).

    #### Table des matières en fin d’ouvrage

    Si on inscrit la table des matières à la fin de l’ouvrage, il n’y a aucune précaution à prendre concernant le nombre de pages qu’elle couvrira.
    Pour ce manuel, dont on trouve deux tables des matières, une en début d’ouvrage et l’autre en fin d’ouvrage. Seule la table des matières en début d’ouvrage a dû faire l’objet d’un calcul du nombre de pages.

    #### Aspect de la table des matières

    Comme les autres réglages, on peut définir précisément la table des matières dans [[-recette/_titre_section_]], dans la partie `table_of_content` (qui signifie "table des matières" en anglais).
    On trouve ces propriétés :
    * **`pages_count`** | Définit le nombre de pages réservées par la table des matières. Ce nombre doit impérativement être pair pour conserver l’agencement des *belles pages* (pages impaires) et des *fausses pages* (pages paires) dans le livre. Par défaut, on compte 2 pages pour la table des matières. Cette valeur vaut 2 par défaut. Noter que les pages supplémentaires (il y en aura toujours deux) peuvent aussi être ajoutées explicitement dans le livre par des `\\(( new_page ))`.
    * **`level_max`** | Niveau maximum. Le niveau de titre qui sera affiché dans la table des matières. Par défaut, il est à 3, ce qui signifie que les titres jusqu’à 3 dièses seront affichés dans la table des matières (sauf exclusion).
    * **`title`** | Le grand titre à utiliser pour la table des matières. Par défaut, en français, c’est "Table des matières".
    * **`title_level`**. Le niveau de titre pour ce grand titre. Par défaut, c’est 1.
    * **`no_title`**. S’il ne faut pas imprimer de grand titre "Table des matières" (ou autre valeur de `title`), alors il faut mettre cette propriété à `true` (vrai).
    * **`font`**. Pour la fonte générale ([[*fonte string*|annexe/font_string]])
    * **`number_font`**. Fonte à utiliser pour les numéros de page ([[*fonte string*|annexe/font_string]]).
    * **`number_size`**. Si on ne veut changer que la taille du numéro (pas toute la fonte), on peut utiliser cette propriété.
    * **`numeroter`**. Si false (faux), on ne numérote pas la table des matières (éviter).
    * **`lines_top`** | Définit le nombre de lignes au-dessus du premier titre de chaque page de table des matières.
    * **`lines_bottom`**. Nombre de lignes au-dessous du dernier titre de chaque page de table des matières.
    * **`line_height`**. Hauteur de la ligne (entre chaque titre). Attention de ne pas donner une valeur plus petite que la taille des titres, sinon ils n’apparaitront pas.
    * **`not_on_even`** | Si true (vrai), on n’impose pas de commencer la table des matières sur une *fausse page* (à gauche). `false` par défaut.
    * **`vadjust_number`**. Nombre de points-post-scripts pour ajuster verticalement le numéro de la page en face du titre (un nombre positif fait descendre le numéro, un nombre négatif le fait monter),
    * **`vadjust_line`**. Nombre de points-ps pour ajuster verticalement la ligne pointillée d’alignement entre le titre et le numéro de page,
    * **`dash_line`**. Les *experts* peuvent modifier la ligne pointillée en jouant sur cette propriété. Cf. plus bas, à propos de la ligne d’alignement.
    * **`levelX`** où `X` va de 1 au niveau maximum de titre défini par `level_max`. Donc, par défaut, `level1`, `level2` et `level3`

    Chaque niveau de titre peut définir :

    * **`font`**. Sa fonte/style/taille/couleur,
    * **`size`** ou seulement sa taille, en gardant la police par défaut de la table des matières,
    * **`indent`**. Indentation du titre, donc son décalage à droite par rapport à la marge gauche.
    * **`number_font`** | ("fonte du nombre" en anglais) Si le nombre de tel ou tel niveau doit vraiment être très différent. En général, `number_size` suffit.
    * **`number_size`**. La taille du numéro (mais pour un meilleur aspect, il vaut mieux garder la taille générale).
    * **`caps`**. La modification (casse) du titre. Les valeurs possibles sont `all-caps` (tout en majuscule), `all-min` (tout en minustule), `title` (titre normal, en fonction de la langue du livre) ou `none` pour le laisser tel quel.
    * **`number_font`**. La police fonte/style/taille/couleur à utiliser pour les numéros de ce niveau de titre (mais il vaut mieux une grande cohérence avec l’ensemble et éviter de la définir).

    #### Exclusion de titres dans la table des matières

    On peut exclure de la table des matières des titres du niveau voulu (`level_max`) en ajoutant `{no_toc}` à leur titre, soit à la fin soit après les dièses. Par exemple :
     `\\### {no_toc} Titre hors TdM`
    ou :
     `\\## Titre hors TdM {no_toc}`
    Vous pouvez vérifier que le titre dans le texte en exemple ci-dessous ne sera pas imprimé dans la table des matières.
    *(rappel : "toc" signifie "table of content", c’est-à-dire "table des matières" en anglais — on peut aussi utiliser `{no_tdm}`)*

    #### Numérotation de la table des matières

    Le "numéro de page" utilisé dans la table des matières dépend directement de la pagination utilisée pour le livre. C’est le numéro de page seule si la pagination est à `pages`, c’est le numéro de paragraphe si la pagination est à `paragraphs` et c’est à page et paragraphe si la pagination est `hybrid`.

    #### Ligne d’alignement de la table des matières

    La *ligne d’alignement* est une ligne, souvent pointillée, qui relie le titre (à gauche) au numéro de page (à droite), et permet de mieux faire correspondre visuellement titre et numéro de page.
    Elle est définie dans la recette à l’aide de la propriété `dash_line`.
    `dash_line` est une table définissant `{:length, :space, :color}` où `:length` est la longueur du tiret (1 pour un point), `:space` est l’espace entre deux tirets et `:color` est la couleur hexadécimale du trait.
    Astuce : on peut obtenir une ligne très fine, très discrète, en mettant `dash_line` à `{length:1, space:0, color:"DDDDDD"}`. Noter que c’est le `space: 0` qui, en ne laissant aucun espace entre les points, génère une ligne.
    EOT

  sample_texte <<~EOT
    \\### {no_toc} TITRE HORS TDM
    Vous pouvez vérifier que ce titre ne sera placé ni dans la table des matières de début de livre ni dans celle de fin de livre.
    EOT

  texte(:as_sample)

  # TODO : Modifier l’aspect de la table des matières
  # recipe <<~EOT #, "Autre entête"
  #   ---
  #     # ...
  #   EOT

  # code_before(Proc.new { pdf.table_of_content&.reset })
  # code_after(Proc.new { pdf.table_of_content.reset })

  sample_recipe <<~YAML, "Propriétés qu’on peut trouver dans la recette"
    ---
    .\\..
    table_of_content:
      # Voir ci-dessus les explications de chaque propriété
      # - Titre -
      title: "Table des matières"
      title_level: 1
      no_title: false
      # - Contenu -
      level_max: 3
      numeroter: true
      # - Aspect -
      lines_top: 4
      lines_bottom: 4
      font: "<font>/<style>/<size>/<color>"
      number_font: "<font>/<style>/<size>/<color>"
      number_size: 10
      line_height: 14
      vadjust_line: 0     # ligne pointillée
      vadjust_number: 0   # numéro page
      dash_line: {length: 1, space: 3}
      # - Aspect des titres par niveau -
      level1:
        font: "<font>/<style>/<size>/<color>"
        size: 12
        number_size: null # => même que défaut
        caps: all-caps
        indent: 0
      level2:
        .\\..
        indent: 1cm
      level3:
        .\\..
        indent: 15mm
    YAML
  # # init_recipe([:custom_cached_var_key])
  recipe <<~YAML
    ---
    table_of_content:
      font: "Courier/regular/20/0000FF"
      number_font: "Helvetica/italic/18/009900"
      line_height: 24
    YAML

end #/ Prawn4book::Manual::Feature.new


# # Autre livre : pour montrer une table des matières particulière
# Prawn4book::Manual::Feature.new do

#   sous_titre "Exemple table des matières personnalisée"

#   real_texte <<~EOT
#     # Un grand titre
#     (( new_page ))
#     (( toc ))
#   EOT

#   real_recipe <<~YAML
#   ---
#   table_of_content:
#     title: "Sommaire"
#   YAML

#   texte <<~EOT
#   (( {align: :right} ))
#   ![page-1](width:"40%")
#   (( line ))
#   ![page-2](width:"40%")
#   EOT
# end
