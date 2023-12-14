Prawn4book::Manual::Feature.new do

  titre "Erreurs et notices"


  description <<~EOT
    On peut signaler des erreurs (messages rouges) et des messages de notices (messages bleus) au cours de la construction du livre grâce, respectivement, aux méthodes `add_erreur("<message>")` et `add_notice("<message>")`.
    Ces méthodes doivent être placées seules sur une ligne, entre des doubles parenthèses.
    {-}\\(( add_erreur("<message d’erreur>") ))
    **Attention :  Par défaut, ces messages ne seront pas imprimés dans le livre, ils n’apparaitront, en console, que lorsque l’on construira le livre.**

    #### Position

    Un des grands avantages de ces messages est qu’ils indiquent clairement la source de l’erreur ou de la note. Ils indiquent le numéro de page dans le livre, ainsi que le numéro de ligne dans le fichier source ou le fichier inclus. De cette manière, on retrouve très rapidement l’endroit concerné par la note ou l’erreur.
    {{ add_notice("TODO: C’est à implémenter, je crois") }}

    #### Utilisation

    On peut utiliser ces méthodes par exemple pour signaler une erreur dans le livre, qu’on ne peut pas corriger au moment où on la voit. Exemple :
    {-}\\(( add_erreur("Il manque ici le chapitre 13") ))
    Ou simplement pour signaler une chose qu’il faut garder en tête. Par exemple :
    {-}\\(( add_notice("Bien s’assurer que l’image qui suit soit en haut de la page.") ))

    EOT

  sample_texte <<~EOT #, "Autre entête"
    Un paragraphe.
    \\(( add_notice("Une simple notice pour l’exemple.") ))
    Un autre paragraphe.
    \\(( add_erreur("Une erreur signalée.") ))
    Un troisième paragraphe.
    EOT

end
