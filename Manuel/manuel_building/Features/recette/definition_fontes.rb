Prawn4book::Manual::Feature.new do

  titre "Définition des fontes (embarquées)"

  description <<~EOT
    Bien que l’application propose, clé en main, des fontes à utiliser pour imprimer son livre, on peut définir n’importe quelle fonte dont on possèderait la licence commerciale pour être utilisée pour tout élément du livre (texte, titres, etc.). Mais afin que l’imprimeur puisse s’en servir, il faut l’embarquer dans son document PDF à destination de cet imprimeur.

    #### Conseil concernant l’emplacement des fontes

    Il vaut mieux faire un dossier `fontes` dans votre dossier de collection ou de livre et y dupliquer les polices que vous voulez utiliser. De cette manière, si vous avez à transmettre le dossier à un collaborateur (ou autre), celui-ci ou celle-ci pourra imprimer correctement le livre, avec les fontes voulues (qu’il ou elle devra charger dans ses fontes personnelles).

    #### Styles obligatoires pour les fontes

    Si vous voulez utiliser la mise en forme HTML utilisant des `<i>` ou des `<em>` pour les italiques, des `<b>` ou des `<strong>` pour les gras, ou les deux en même temps, il est obligatoire de définir les styles `italic`, `bold` et `bold_italic`.
    EOT

end
