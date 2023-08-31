module Prawn4book

  VERSION = '1.0.0'
      
  def self.run
    begin
      command = Prawn4book::Command.new(help? ? 'help' : CLI.main_command)
      command.run
    rescue RecipeError => e
      puts "\nERREUR DE DÉFINITION DE LA RECETTE\n#{e.message}".rouge
      puts "\n\n"
    end
  end

end #/module Prawn4book
