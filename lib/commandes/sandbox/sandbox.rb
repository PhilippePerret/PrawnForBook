=begin
  Bac à sable de l'application, pour faire des essais

  Il suffit de :
  * si nécessaire, se placer dans le dossier voulu
  * écrire le code ci-dessous dans la méthode play_sandbox
  * jouer la commande 'pfb sandbox'

=end
module Prawn4book
  # ::runner
  class Command
    def proceed
      Prawn4book.play_sandbox
    end
  end #/Command

  def self.play_sandbox
    clear
    
    operation = "Récupération du texte du GAT en français"

    puts "Programmation du bac à sable pour #{operation}.".jaune

    # if test?
    #   puts "TEST MODE".bleu
    # end



  end
end #/module Prawn4book
