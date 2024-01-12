Prawn4book::Manual::Feature.new do

  titre "Méthodes d’helpers en mode expert"

  description <<~EOT
    Une fonctionnalité très pratique concerne ce qu’on appelle en ruby les *helpers*, c’est-à-dire (comme vous devez le savoir en tant qu’expert) des méthodes qui permettre de mettre en forme des textes récurrents. 
    Imaginons qu’on veuille par exemple un format d’horloge (donnant l’heure) très particulier dans le texte. Plutôt que de répéter ce formatage pour chaque horloge à écrire, on va créer un *helper* qui va faire l’opération pour nous.
    Cet *helper* devra être une méthode d’instance de `PdfBook::AnyParagraph` (ou `PdfBook::NTextParagraph` s’il ne concerne que les paragraphes de texte) du module `Prawn4book` par exemple dans le fichier `prawn4book.rb` ou `formater.rb`.

    #### Anti-collision pour les noms de méthode d’helper

    Pour le moment, les méthodes d’helper se situant à un haut niveau des instances, il peut y avoir *collision de nom* (quand le nom de l’helper est déjà utilisé par l’instance) ce qui détraquerait complètement la construction du livre.
    L’astuce pour être sûr d’éviter cette erreur est simple : il suffit d’utiliser une première fois ce helper dans votre texte, comme s’il existait, mais sans implémenter l’helper (ou en le mettant dans un commentaire, comme s’il n’existait pas). Si le programme provoque une erreur (de méthode inconnue ou il se bloque), alors vous savez que votre méthode est unique, qu’il n’y a pas collision.
    Vous pouvez alors décommenter votre helper pour l’utiliser.
    EOT

  sample_code <<~EOC, "Par exemple dans ./formater.rb"
  module Prawn4book
    class PdfBook::AnyParagraph
      def horloge hhmmss
        h, m, s = hhmmss.split(':').map { |n| n.to_i }
        [h + __s(h), m + __s(m), s + __s(s)].join(' ')
      end
      #
      def __s val
        val.to_i > 1 ? "s" : ""
      end

    end
  end
  EOC

  sample_texte <<~EOT
  Un texte avec une horloge à \\\#{horloge('1:12:02')} et une autre à \\\#{horloge('0:1:1')} pour terminer à \\\#{horloge('3:03:15')}.
  EOT

  texte(:as_sample)

end
