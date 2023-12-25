Prawn4book::Manual::Feature.new do

  titre "La page des remerciements"


  description <<~EOT    
    C’est toujours bien de remercier, avant le texte, les gens qui vous ont épaulé dans la conception de votre projet de livre.
    La page des remerciements (qui peut tenir sur plusieurs pages), se trouve toujours sur une *fausse page*, donc une page paire, à gauche, en face de l’avant-propos ou de la préface s’ils existent.
    Elle est créée par vous, dans le texte du livre, juste après la marque de la table des matières — cf. [[pages_speciales/table_des_matieres]].
    Pour s’assurer de bien se trouver sur une page paire, plutôt que la marque `\\(( new_page ))`, on peut utiliser la marque `\\(( fausse_page ))` ou `\\(( even_page ))`.
    Si elle tient sur une seule page, il ne faut pas la numéroter. Avec d’inscrire le `\\(( even_page ))` il faut donc penser à ajouter un `\\(( stop_pagination ))` et penser à redémarrer cette pagination à la fin.
    Une page de remerciements pourra donc ressembler à :
    (( line ))
    ~~~
    (( stop_pagination ))
    (( even_page ))
    Je voudrais remercier…
    … ma chienne Poupette
    … ma femme Michèle
    (( restart_pagination ))
    (( new_page ))
    ~~~
    (( line ))
    Notez que si vous êtes absolument certain que cette page de remerciements ne tiendra que sur une seule page, vous pouvez simplement utiliser la marque `\\(( no_pagination ))` *après* être passé sur la bonne page (`no_pagination` concerne la page sur laquelle on se trouve et seulement la page sur laquelle on se trouve — cf. [[pagination/titre_section]]).
    (( line ))
    ~~~
    (( even_page ))
    (( no_pagination ))
    Je voudrais remercier…
    … ma chienne Poupette
    … ma femme Michèle
    (( new_page ))
    ~~~
    (( line ))
    EOT

end
