Prawn4book::Manual::Feature.new do

  titre "Mode Multi-colonnes"

  description <<~EOT
    En tant qu’expert, vous pouvez utiliser le mode multi-colonnes (affichage du texte sur plusieurs colonnes) à l’intérieur des formateurs.
    Bien entendu, vous pouvez, si vous êtes parfaitement à l’aise avec ça, utiliser les `column_box` de **Prawn**. Mais _PFB_ propose là aussi des outils plus élaborés qui permettront une mise en page assistée.
    Imaginons l’index `entree` qui permet de gérer les entrées du dictionnaire que vous construisez. À la fin du livre, vous voulez afficher cette index sur trois colonnes. Vous allez donc implémenter la méthode `CustomIndexModule#print_index_entree` dans le fichier `formater.rb`.
    Elle ressemblera à ça :
    (( line ))
    ~~~ruby
    module CustomIndexModule

      def print_index_entree(pdf)
        
      end

    end #/module
    ~~~
    (( line ))

    EOT


end
