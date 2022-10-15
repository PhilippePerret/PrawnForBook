module Prawn4book
  
  def self.run
    command = Prawn4book::Command.new(help? ? 'help' : CLI.main_command)
    command.run
      # case CLI.main_command
      # when 'generate', 'build'
      #   PdfBook.get_current.generate
      # when 'open', 'ouvre'
      #   require_module('open', :open_something)
      # when 'tools', 'tool'
      #   require_module('tools', :play_tools)
      # when 'essais', 'sandbox' # pour faire des essais
      #   require_module('sandbox', :play_sandbox)
      # end
  end
end #/module Prawn4book
