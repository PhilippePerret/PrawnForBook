Prawn4book::Manual::Feature.new do

  titre "Les \"Fontes-Strings\""

  description <<~EOT
    Pour définir les polices dans les éléments, à commencer par la recette, on utilise de préférence ce qu’on appelle dans _PFB_ les "**fonte-string**" ("string" signifie quelque chose comme "caractère" en anglais).
    Ces *fonte-strings* se présentent toujours de la même manière, par une chaine de caractères (de lettres) contenant 4 valeurs séparées par des balances, dans l’ordre :
    * le **nom** de la police,
    * le **style** de la police (qui doit être définie,
    * la **taille** à appliquer au texte (en points-pdf),
    * la **couleur** éventuelle (pour la définition de la couleur, voir [[annexe/definition_couleur]]).
    EOT

  sample_recipe <<~YAML
    ---
    font: "<police>/<style>/<taille>/<couleur>"

    # Par exemple

    font: "Numito/bold_italic/23/FF0000"

    YAML

end
