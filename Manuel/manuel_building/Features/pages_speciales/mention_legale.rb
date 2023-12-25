Prawn4book::Manual::Feature.new do

  titre "La page de mention légale"


  description <<~EOT
    
    C’est la page du fameux *copyright*. Cette page se trouve après la page de titre. Si le copyright est défini dans la recette, cette page est automatiquement créée sans que vous ayez rien d’autre à faire.
    Le copyright doit être défini dans :
    (( line ))
    ~~~yaml
    inserted_pages:
      copyright: |
        @Philippe Perret, 2023-#{Time.now.year}

        Le Code de la propriété intellectuelle interdit toute
        reproduction et toute utilisation etc.
    ~~~
    (( line ))
    Le trait droit ("|") après le `copyright:` indique à YAML comment doit être lu le contenu qui commence sur la ligne suivante. Avec ce trait droit, un double retour de chariot sera transformé en un retour à la ligne tant qu’un retour de chariot simple (comme ci-dessus entre "toute" et "reproduction") sera remplacé en une espace typographique.
    EOT

end
