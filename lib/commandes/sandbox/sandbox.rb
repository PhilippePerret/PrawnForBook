=begin
  Bac à sable de l'application, pour faire des essais
=end
module Prawn4book
  # ::runner
  class Command
    def proceed
      Prawn4book.play_sandbox
    end
  end #/Command

  def self.play_sandbox
    
    puts "On peut programmer le bac à sable pour des essais.".jaune

    # if test?
    #   puts "TEST MODE".bleu
    # end

    # choix = Q.ask("Que veux-tu ?")
    # puts "Le choix est #{choix.inspect}"
  end
end #/module Prawn4book
