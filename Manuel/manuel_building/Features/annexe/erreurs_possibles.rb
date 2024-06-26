Prawn4book::Manual::Feature.new do

  titre "Erreurs possibles"

  description <<~EOT
    Cette section liste les erreurs fréquentes ou possibles et donne leur solution.
    (( line ))

    erreur::Une table ne s’affiche pas.

    Avez-vous bien pensé à terminer la table par une dernière ligne contenant (et contenant seulement) "`\\[\\/]`" ?

    (( line ))
    
    erreur::Une ligne de table ne s’affiche pas en table.

    Vérifier qu’il n’y ait pas une espace malheureuse après le dernier trait droit ("|") définissant la ligne.

    (( line ))
    
    erreur::La table des matières déborde sur les pages suivantes

    Il faut lui prévoir plus de page. Augmenter le chiffre dans :
    (( line ))
    ```yaml
    inserted_pages:
      table_of_content:
        # ...
        page_count: 2 # <= mettre 4 au lieu de 2
    ```
    (( line ))

    erreur::La liste des illustrations déborde sur les pages suivantes

    Il faut lui octroyer plus de pages. Augmenter le `page_count` dans :
    (( line ))
    ```yaml
    inserted_pages:
      illustrations:
        # ...
        page_count: 2 # <= mettre 4 au lieu de 2
    ```
    (( line ))

    erreur::La liste des abréviations déborde sur les pages suivantes

    Il faut lui octroyer plus de pages. Augmenter le `page_count` dans :
    (( line ))
    ```yaml
    inserted_pages:
      abbreviations:
        # ...
        page_count: 2 # <= mettre 4 au lieu de 2
    ```
    (( line ))

    erreur::Le glossaire déborde sur les pages suivantes

    Il faut lui octroyer plus de pages. Augmenter le `page_count` dans :
    (( line ))
    ```yaml
    inserted_pages:
      glossary:
        # ...
        page_count: 2 # <= mettre 4 au lieu de 2
    ```
    (( line ))

    erreur::Problème d’affichage de deux images

    Il arrive que lorsqu’on enchaine deux images sur deux lignes consécutives, de la manière suivante :
    (( line ))
    ```
    \\!\\[premiere_image.jpg](... propriétés ...)
    \\!\\[deuxième_image.png](... propriétés ...)
    ```
    (( line ))
    … un problème peut être généré. Pour l’éviter, il devrait suffire de passer une ligne entre les deux images :
    (( line ))
    ```
    \\!\\[premiere_image.jpg](... propriétés ...)

    \\!\\[deuxième_image.png](... propriétés ...)
    ```
    (( line ))

    erreur::La section multi-colonnes en fin de livre ne s’affiche pas.

    Assurez-vous d’avoir bien terminé cette section par la marque `(( colonnes\\(1) ))` sur une ligne seule.
    
    (( line ))

    erreur::Un code de type `\\(( \\{align: :right }))` n’est pas interprété.

    *(il apparait "en dur" dans la page)*

    Assurez-vous ne bien avoir laissé une espace avant le `\\))` final (et une après le `\\((` initial).


    EOT


end
