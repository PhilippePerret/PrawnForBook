(( toc ))
# Avant-propos
Ce manuel présente toutes les fonctionnalités, à jour, de l’application “Prawn-for-book” (“Prawn pour les livres”), application dont la principale vocation est d’**obtenir un document PDF professionnel prêt pour l’imprimerie** à partir d’un simple fichier de texte (contenant le contenu du livre, le roman par exemple).
Ce manuel de #{{{Prawn4book.second_turn? ? book.pages.count.to_s : "XXX"}}} pages est auto-produit par “**Prawn-for-book**”, c’est-à-dire qu’il est construit de façon *programmatique* par l’application elle-même. Il en utilise toutes les fonctionnalités puisqu’il génère de façon automatisé les exemples et notamment les *helpers* de mise en forme, les références croisées ou les bibliographies. En ce sens, ce manuel sert donc aussi de test complet de l’application puisqu’une fonctionnalité qui ne fonctionnerait pas ici ne fonctionnerait pas non plus dans le livre produit.
Si vous êtes intéressé(e) de voir comment il est généré, vous pouvez consulter principalement le fichier markdown `texte.pfb.md`, le fichier ruby `prawn4book.rb` et le fichier recette yaml `recipe.yaml` qui le définissent, dans le dossier `Manuel/manuel_building` de l’application.

# Fonctionnalités
(( build_features ))

(( biblio(film) ))
(( biblio(article) ))
(( toc ))
