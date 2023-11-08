Prawn4book::Manual::Feature.new do

  titre "Liste exhaustive des fonctionnalités"

  # Ne pas mettre de virgule à la fin
  # 
  description <<~EOT.split("\n").join("\n\n")

    * définition de la taille du livre
    * pagination automatique et personnalisable
    * définition de la fonte par défaut
    * définition des pages spéciales à insérer [[pages_speciales/pages_speciales]]
    * justification par défaut des textes
    * colorisation des textes
    * suppression des veuves et des orphelines
    * suppression automatique des lignes de voleur
    * nombreuses sortes de puces et puces personnalisées [[puces/puces]]
    * évaluation à la volée du code ruby (pour des opérations, des constantes, etc.)
    * traitement des références croisées
    * traitement dynamique des références à d'autres livres
    * génération dynamique de contenu
    * corrige l'erreur typographique de l'apostrophe droit
    * corrige l'erreur typographique de l'absence d'espace avant et après les chevrons
    * corrige l'erreur typographique de l'espace avant et après les guillemets droits et courbes
    * corrige l'oubli de l'espace avant les ponctuations doubles
    * corrige l'erreur d'espace avant les ponctuations doubles (pose d'une insécable)
    * corrige l'absence d'espace insécable à l'intérieur des tirets d'exergue
    * changement de fonte (police) pour le paragraphe suivant [[change_fonte_for_next_paragraph]]
    * placement sur n'importe quelle ligne de la page
    * exportation seulement du texte produit
    * exportation comme livre numérique (pur PDF)

    EOT
end
