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

    #### Options de la commande `build`

    La commande de construction du livre (**`build`**) supporte plusieurs options qui affectent son comportement :
    (( line ))
    **`-open#{' '*13}`** Ouvrir le livre une fois construit.
    **`-display_margins#{' '*2}`** Construit le livre avec les marges visibles.
    **`-grid#{' '*13}`** Construit le livre avec les lignes de référence.
    **`-debug#{' '*12}`** Affiche des messages d’erreur plus précis.


    EOT

end
