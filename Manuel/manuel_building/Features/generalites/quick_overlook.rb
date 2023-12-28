Prawn4book::Manual::Feature.new do

  titre "Aperçu rapide des commanges"


  description <<~EOT
    Si vous avez déjà consulté l’aide et produit votre premier livre, vous aurez peut-être simplement besoin d’un rafraichissement de mémoire sur les commandes de base. Ce chapitre les expose.

    *(note : toutes ces commandes s’effectuent dans une console/un terminal ouvert dans le dossier du livre à considérer)*
    (( line ))
    **`pfb init#{' '*9}`** Instanciation d’un nouveau livre/une nouvelle collection.
    **`pfb build#{' '*8}`** Construction du livre.
    **`pfb build -open#{' '*2}`** Construction et ouverture du livre.
    **`pfb build -t#{' '*5}`** Exportation du livre
    **`pfb open#{' '*9}`** Ouvrir un élément quelconque.
    **`pfb install#{' '*6}`** Installer le livre (les snippets).
    **`pfb calc#{' '*9}`** Pour effectuer des calculs (marges, couverture…).

    #### Options de la commande `build`

    La commande de construction du livre (**`build`**) supporte plusieurs options qui affectent son comportement :
    (( line ))
    **`-open#{' '*9}`** Ouvrir le livre une fois construit.
    **`-margins#{' '*6}`** Construit le livre avec les marges visibles.
    **`-grid#{' '*9}`** Construit le livre avec les lignes de référence.
    **`-debug#{' '*8}`** Affiche des messages d’erreur plus précis.
    **`-bat#{' '*10}`** Pour "Bon À Tirer (cf. ci-dessous)"

    L’option **`-bat`** assure de produire le document "bon à tirer", c’est-à-dire prêt à être envoyé à l’imprimeur (ou à être déposé dans la bibliothèque KDP). Par exemple, elle s’assure que les marges ou la grille de référence n’ait pas été affichée (par les options) ou elle s’assure que les problèmes d’images (signalées en erreur fatale dans le rapport final, mais sans interrompre la construction quand `-bat` n’est pas utilisé) ont tous été réglés.
    **Moralité : produisez toujours le document final avec cette option `-bat`.**
    EOT

end
