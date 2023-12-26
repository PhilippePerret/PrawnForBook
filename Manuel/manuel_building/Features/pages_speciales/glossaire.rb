Prawn4book::Manual::Feature.new do

  titre "Glossaire"


  description <<~EOT
    Pour certaines publications un peu techniques — ou des mémoires, des thèses — une page de glossaire rassemblant les termes techniques et leur définition peut être nécessaire. Académiquement (mémoire, thèses…) le glossaire doit être obligatoirement placé après la table des matières, la table des illustrations et la liste des abréviations si elle existe.
    
    #### Définition des termes du glossaire
    
    Si vous êtes un _expert_ de _PFB_, vous pouvez gérer le *glossaire* de la façon que vous voulez, en utilisant par exemple la puissance des _index_. Cela vous permettrait, par exemple, en plus des définitions, d’obtenir une liste de toutes les pages où les termes sont employés.
    Si vous n’êtes pas un expert, pas de panique, il suffit de rassembler vos termes dans un fichier `glossaire.txt` et ils seront insérés dans le livre à l’endroit voulu.
    Ce fichier fonctionne le plus simplement du monde, avec un terme collé à gauche et sa définition décalé d’une tabulation à droite :
    (( line ))
    ~~~
    Premier mot
      Sa définition précise sera placée ici.
      Elle peut tenir sur plusieurs lignes.
    Deuxième mot
      Sa définition ici.
    ~~~
    (( line ))
    Ensuite, dans le livre, il suffit d’utiliser une de ces marques :
    * `\\(( glossaire ))`
    * `\\(( glossary ))` ("glossaire" en anglais)

    #### Aspect de l’affichage du glossaire

    Le glossaire doit s’afficher de façon harmonieuse dans le livre, en s’appuyant sur les polices que vous utilisez. Mais comme tout élément de _PFB_, on peut définir très précisément l’aspect de ce glossaire.
    Cette définition se fait dans la section `inserted_pages`, dans une partie `glossaire` (ou `glossary`).
    ~~~yaml
    inserted_pages:
      glossaire:
        font: "police/style/taille/couleur"
        format: inline # table/autre ?
        term:
          font: "police/style/taille/couleur"
        definition:
          font: "police/style/taille/couleur"
    ~~~
    C’est le format qui va définir de l’apparence de votre glossaire. En format `inline` il apparaitra de cette manière :
    {{TODO: Image du format inline du glossaire}}
    En format `table` il apparaitra de cette manière :
    {{TODO: Image du format table du glossaire}}
    En format `???` il apparaitra de cette manière :
    {{TODO: Voir les autres types d’apparence}}
    EOT

  sample_texte <<~EOT
  \\(( glossaire ))
  EOT

  texte(:as_sample)

end
