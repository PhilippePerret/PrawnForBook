module Prawn4book
  
  def self.run
    command = Prawn4book::Command.new(help? ? 'help' : CLI.main_command)
    command.run
  end

end #/module Prawn4book
