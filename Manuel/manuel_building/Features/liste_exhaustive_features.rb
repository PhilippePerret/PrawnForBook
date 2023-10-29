Prawn4book::Manual::Feature.new do

  titre "Liste exhaustive des fonctionnalités"

  # Ne pas mettre de virgule à la fin
  # 
  description <<~EOT.split("\n").join("\n\n")

    * colorisation des textes
    * suppression des veuves et des orphelines
    * suppression des lignes de voleur
    * nombreuses sortes de puces et puces personnalisées [[puces]]
    * évaluation à la volée du code ruby (pour des opérations, des constantes, etc.)
    * corrige l'erreur typographique de l'apostrophe droit
    * corrige l'erreur typographique de l'absence d'espace avant et après les chevrons
    * corrige l'erreur typographique de l'espace avant et après les guillemets droits et courbes
    * corrige l'oubli de l'espace avant les ponctuations doubles
    * corrige l'erreur d'espace avant les ponctuations doubles (pose d'une insécable)
    * changement de fonte (police) pour le paragraphe suivant [[change_fonte_for_next_paragraph]]

    EOT
end
