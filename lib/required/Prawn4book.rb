module Prawn4book
  
  def self.run
    if help?
      require_module('help', :display_help)
    else
      case CLI.main_command
      when 'init', 'create'
        require_module('pdfbook/init')
        PdfBook.define_book_recipe
      when 'generate', 'build'
        PdfBook.get_current.generate
      when 'open', 'ouvre'
        require_module('open', :open_something)
      when 'tools', 'tool'
        require_module('tools', :play_tools)
      when 'manuel'
        require_module('help', :open_user_manuel)
      when 'essais', 'sandbox' # pour faire des essais
        require_module('sandbox', :play_sandbox)
      else
        require_module('help', :display_mini_help)
      end
    end
  end


end #/module Prawn4book
