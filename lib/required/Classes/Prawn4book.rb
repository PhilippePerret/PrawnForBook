module Prawn4book

  VERSION = '1.0.0'
      
  def self.run
    command = Prawn4book::Command.new(help? ? 'help' : CLI.main_command)
    command.run
  end

end #/module Prawn4book
