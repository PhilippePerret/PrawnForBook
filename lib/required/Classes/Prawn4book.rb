module Prawn4book

  VERSION = '1.0.0'
      
  def self.run
    begin
      command = Prawn4book::Command.new(help? ? 'help' : CLI.main_command)
      command.run
    rescue FatalPrawForBookError => e
      puts "\n\n" + e.message.rouge
      if debug?
        puts e.backtrace.join("\n")
      end
    rescue RecipeError => e
      warn "Ne plus utiliser. Utiliser FatalPrawForBookError plutôt"
      puts "\nERREUR DE DÉFINITION DE LA RECETTE\n#{e.message}".rouge
    end
    puts "\n\n"
  end

end #/module Prawn4book
