Prawn4book::Manual::Feature.new do

  titre "Messages d’erreurs et notices"


  description <<~EOT
    On peut signaler des erreurs (messages rouges) et des messages de notices (messages bleus) au cours de la construction du livre grâce, respectivement, aux méthodes `erreur\\("<message>")` (ou `error\\("<message>")`) et `notice\\("<message>")`.
    Ces méthodes doivent être placées seules sur une ligne, entre des doubles parenthèses.
    {-}\\(( erreur\\("<message d’erreur>") ))
    **Attention :  ces messages ne seront jamais gravés dans le livre, ils n’apparaitront qu’en console lorsque l’on construira le livre.**

    #### Position

    Un des grands avantages de ces messages est qu’ils indiquent clairement la source de l’erreur ou de la note. Ils indiquent le numéro de page dans le livre, ainsi que le numéro de ligne dans le fichier source ou le fichier inclus. De cette manière, on retrouve très rapidement l’endroit concerné par la note ou l’erreur.

    #### Utilisation

    On peut utiliser ces méthodes par exemple pour signaler une erreur dans le livre, qu’on ne peut pas corriger au moment où on la voit. Exemple :
    {-}\\(( erreur\\("Il manque ici le chapitre 13") ))
    Ou simplement pour signaler une chose qu’il faut garder en tête. Par exemple :
    {-}\\(( notice\\("Bien s’assurer que l’image qui suit soit en haut de la page.") ))

    #### Exemple

    (( notice("Une note depuis le manuel.") ))
    À cet endroit précis nous avons placé un appel à une note avec le code :
    {-}`(( notice\\("Une note depuis le manuel.") ))`
    Vous devriez la voir si vous lancer la [[annexe/reconstruction_manuel]].

    EOT

  texte <<~EOT, "Exemple dans texte.pfb.md"
    Un paragraphe.
    \\(( add_notice(\\"Une simple notice pour l’exemple.\\") ))
    Un autre paragraphe.
    \\(( add_erreur(\\"Une erreur signalée.\\") ))
    Un troisième paragraphe.
    EOT

end
