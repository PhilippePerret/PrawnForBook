require_relative '../Divers/constants'

module Prawn4book

  NAME    = 'Prawn-For-Book'
  SUBNAME = 'Write and publish!'
  
  VERSION = begin
    File.read(File.join(APP_FOLDER,'VERSION')).strip
  end
      
  def self.run
    begin
      command = Prawn4book::Command.new(help? ? 'help' : (version? ? 'version' : CLI.main_command))
      command.run
    rescue PFBFatalError => e
      puts "\n\n" + e.message.rouge
      if debug?
        puts e.backtrace.join("\n")
      end
    rescue RecipeError => e
      warn "Ne plus utiliser. Utiliser PFBFatalError plutôt"
      puts "\nERREUR DE DÉFINITION DE LA RECETTE\n#{e.message}".rouge
    end
    puts "\n\n"
  end

end #/module Prawn4book
