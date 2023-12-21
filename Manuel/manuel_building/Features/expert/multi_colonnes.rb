Prawn4book::Manual::Feature.new do

  titre "Mode Multi-colonnes"

  description <<~EOT
    En tant qu’expert, vous pouvez utiliser le mode multi-colonnes (affichage du texte sur plusieurs colonnes) à l’intérieur des formateurs.
    Bien entendu, vous pouvez, si vous êtes parfaitement à l’aise avec ça, utiliser les `column_box` de **Prawn**. Mais _PFB_ propose là aussi des outils plus élaborés qui permettront une mise en page assistée.
    Imaginons l’index `entree` qui permet de gérer les entrées du dictionnaire que vous construisez. À la fin du livre, vous voulez afficher cette index sur trois colonnes. Vous allez donc implémenter la méthode `CustomIndexModule#print_index_entree` dans le fichier `formater.rb`.
    Elle ressemblera au code de la page suivante.
    (( new_page ))
    ~~~ruby
    module CustomIndexModule
       
      # Méthode appelée automatiquement si le code 
      #   `(( index\\\\(entree) ))’
      # est utilisé dans le texte
      #
      def print_index_entree(pdf)
        
        # Les paramètres d’instanciation du multi colonnes
        params = {
          column_count: <nombre de colonnes>,
          width:        <largeur si autre que page complète>,
          gutter:       <gouttière si autre que valeur défaut>,
          lines_before: <nombre de lignes avant si autre que 1>,
          lines_after:  <nombre de lignes après si autre que 1>,
          space_before: <espace avant si nécessaire>,
          space_after:  <espace après si nécessaire>
        }
        # On instancie un texte multi-colonnes
        mc_block = Prawn4book::PdfBook::ColumnsBox.new(book, **params)

        # items contient la liste de toutes les entrées
        items.each_with_index do |item_id, occurrences, idx|
          # On traite les items pour obtenir le texte
          str = ...
          # On en fait une instance de paragraphe
          para = Prawn4book::PdfBook::NTextParagraph.new(
            book: book, 
            raw_text: str, 
            pindex:idx, 
          )
          # On peut indiquer la source, pour les messages d’erreur
          # éventuels
          para.source = "Construction de l’index des entrées"
          # On peut supprimer l’indentation éventuelle
          para.indentation = 0
          # Et on injecte le paragraph dans le bloc multi-colonnes
          mc_block << para
        end

        # On diminue la fonte à utiliser et on l’utilise
        fonte = Prawn4book::Fonte.dup_default
        fonte.size = 10
        pdf.font(fonte)

        # Il suffit maintenant d’imprimer ce bloc multi-colonnes
        mc_block.print(pdf)

        # Done!
      end

    end #/module
    ~~~
    (( line ))

    EOT


end
