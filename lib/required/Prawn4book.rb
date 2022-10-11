module Prawn4book
  
  def self.run
    # puts "Je dois apprendre à jouer la commande #{CLI.main_command.inspect} de Prawn4book".jaune
    if help?
      require_module('help', :display_help)
    else
      case CLI.main_command
      when 'init', 'create'
        require_module('pdfbook/init')
        PdfBook.define_book_recipe
      when 'generate', 'build'
        PdfBook.get_current.generate
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
