Prawn4book::Manual::Feature.new do

  titre "Page d’index"

  description <<~EOT
    Si l’on peut faire autant d’index que l’on désire avec _PFB_ (cf. [[bibliographies/custom_indexes]]), il n’en reste pas moins qu’il existe une page d’index à proprement parler, comme il en existe dans de nombreux livres. 

    #### Ajout d’un mot dans la page d’index

    Pour qu’un mot soit dans la page d’index, il suffit qu’il soit entouré de `index\\(\\<le mot>)`.
    Ce mot devient alors la clé de l’index ainsi que son *nom humain*. Nous verrons plus tard qu’il sera possible de le redéfinir.
    Si un mot doit être affiché différemment que sa clé, il suffit d’ajouter sa clé dans la parenthèse, après un trait droit. Typiquement, cela survient lorsque le mot est composé et qu’il doit être employé au pluriel. Par exemple, nous voulons avoir "chef-d’œuvre" comme mot indexé. Nous pouvons alors utiliser :
    {-}`C’est un index\\(chef-d’œuvre) et ce sont des index\\(chefs-d’œuvre|chef-d’œuvre).`
    Bien entendu, la deuxième fois, il faut s’assurer que la clé soit bien la même.

    #### Importance (poids) de l’occurrence d’un mot indexé

    On peut préciser la pertinence d’une occurrence d’un mot indexé grâce au caractère "!" (pour *forte*, *principale*) ou "." (pour *faible* ou *mineur*) placé avant l’index, toujours juste après la parenthèse ouvrante.
    Ainsi :
    (( line ))
    ~~~text
    Ceci est une index\\(!occurrence|repaire\\) forte à l’index "repaire" tandis que :
    Cette index\\(.occurrence|repaire\\) est une occurrence faible.
    ~~~

    #### Utilisation d’une clé virtuelle pour les index

    Afin de simplifier la clé des index — "chef-d’œuvre" est une clé un peu difficile, comme "Comité Internationnal Olympique", et elles sont *dangereuses* dans le sens où l’erreur de frappe peut vite survenir… — on peut utiliser des clés virtuelles.
    Par exemple, nous voulons utiliser "cio" au lieu de "Comité International Olympique". Nous ferons alors :
    {-}`Dans le index(Comité Olympique|cio) — qui s’appelle en vérité le index(Comité International Olympique|cio), il y a plusieurs membres.`
    Pour que la clé fonctionne, nous devons défnir dans un fichier ruby (`prawn4book.rb`, `formater.rb`, etc.) la table `INDEX` qui va définir le rapport entre la clé et le texte qui devra être gravé dans la page d’index. Elle se définit de la manière suivante :
    (( line ))
    ~~~ruby
    module Prawn4book
      INDEX = {
        cio: "Comité International Olympique",
        \\<clé>: "\\<mot dans index>",
      }
    end
    ~~~
    (( line ))
    Les clés de cette table doivent impérativement être en minuscule, même si la clé utilisée dans le texte ne l’est pas.

    #### Format de la page d’index

    Dans la recette (du livre ou de la collection) on peut définir l’aspect de l’index. Cela revient à définir l’aspect du *canon* (le mot indexé) et l’aspect des numéros de page (ou de paragraphe suivant le type de pagination).
    Voyez ci-dessous, dans l’exemple de recette, les propriétés définissables.
    EOT

  sample_texte <<~EOT #, "Autre entête"
    index\\(le mot) sera indexé sous la clé "le mot" tandis que index\\(les mots|le mot) sera également indexé sous la clé "le mot" même si c’est un mot différent. On peut d’ailleurs mettre index\\(ce que l’on veut|le mot) à partir du moment où la clé est définie.
    Une occurrence marquée index\\(!le mot) sera considérée comme importante (forte).
    Une occurrence marquée au contraire index\\(.le mot) sera considérée comme peu importante (faible).
    EOT

  texte(:as_sample)

  sample_recipe <<~YAML, "Dans la recette"
    ---
    inserted_pages:
      page_index:
        aspect:
          canon:
            font: "police/style/taille/couleur"
          number:
            font: "police/style/taille/couleur"
            main:
              font: "police/style/taille/couleur"
            minor:
              font: "police/style/taille/couleur"
    YAML




end
