Prawn4book::Manual::Feature.new do

  titre "Les Forces de <i>Prawn-For-Book</i>"

  description <<~EOT
    ***Prawn-for-book*** possède de nombreuses forces et de nombreux atouts dont nous ne pouvons que donner un aperçu non exhaustif dans cette introduction.

    * Sans configuration ou définitions, l’application produit un document PDF valide pour l’imprimerie professionnelle respectant toutes les normes et les habitudes en vigueur, avec par exemple toutes les lignes de texte alignées sur une grille de référence, avec une mise en page ne contenant aucune veuve, aucune orpheline et aucune ligne de voleur,
    * permet d’utiliser de façon simple les feuilles de styles,
    * respecte toutes les règles de typographie en vigueur,
    * produit une page de titre valide par défaut,
    * permet de travailler sur une collection entière,
    * permet de gérer automatiquement une infinité d’index,
    * gère facilement les bibliographies,
    * gère les références, même à d’autres livres,
    * gère les images flottantes,
    * produit bien sûr une table des matières valide par défaut,
    * extension infinie pour les experts qui connaissent le langage Ruby et la gem Prawn.

    Bien que _PFB_ soit capable de produire de façon automatique ce document, l’application offre la possibilité de définir tous les éléments de façon très précise et très fine pour obtenir le rendu exact souhaité, grâce à une *recette* qui accompagne le texte et où peuvent être paramétrés tous les aspects du livre.
    Plus loin encore, _PFB_ permet de travailler comme aucun autre logiciel sur **une collection entière**, grâce à un *fichier recette* partagé par tous les livres — chacun pouvant définir sa propre recette pour rectifier des aspects particuliers. De cette manière, on peut très simplement obtenir une collection cohérente partageant la même charte. On peut même obtenir des références croisées dynamiques entre les différents livres.

    Le reste de ce manuel vous permettra de découvrir l’ensemble des fonctionnalités à votre disposition.
    EOT

end
