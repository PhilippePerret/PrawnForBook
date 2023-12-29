require_relative '../Divers/constants'

module Prawn4book

  NAME    = 'Prawn-For-Book'
  SUBNAME = 'Write and publish!'
  
  VERSION = begin
    File.read(File.join(APP_FOLDER,'VERSION')).strip
  end
      
  def self.run
    begin
      main_command = CLI.main_command || ask_for_pfb_command || return
      command = Prawn4book::Command.new(help? ? 'help' : (version? ? 'version' : main_command))
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


  # @stable
  # 
  # Quand l’utilisateur a juste écrit ’pfb’ dans la console, on passe
  # par ici pour lui demander ce qu’il veut faire
  # 
  def self.ask_for_pfb_command
    lescommandes = []

    if PdfBook.current
      lescommandes << [{name:PROMPTS[:Build_current_book], value: ['build', nil, 'pfb build']}]
      lescommandes << [{name:"#{PROMPTS[:Build_current_book]} (#{TERMS[:BAT_version]})", value: ['build', :bat, 'pfb build -bat']}]
      lescommandes << [{name:"#{PROMPTS[:Build_current_book]} #{PROMPTS[:and_open]}", value: ['build', :open, 'pfb build -open']}]
      lescommandes << [{name:"#{PROMPTS[:Build_current_book]} (#{PROMPTS[:show_grid]})", value: ['build', :grid, 'pfb build -grid']}]
      lescommandes << [{name:"#{PROMPTS[:Build_current_book]} (#{PROMPTS[:show_margins]})", value: ['build', :margins, 'pfb build -margins']}]
    end
    lescommandes += [
      {name:PROMPTS[:Open_something], value: ['open', nil, 'pfb open']},
      {name:PROMPTS[:cancel], value: [nil, nil, nil]}
    ]

    cmd, options, cmd_str = Q.select(PROMPTS[:Quoi_faire].jaune, lescommandes, **{per_page: lescommandes.count})
    case options
    when Symbol then CLI.options.merge!(options => true)
    when Hash   then options.each { |k, v| CLI.options.merge!(k => v) }
    when Array  then options.each { |option| CLI.options.merge!(option => true) }
    end

    if cmd_str
      clear
      puts PROMPTS[:Command_can_be_done_with].jaune
      puts cmd_str.bleu
      sleep 5
    end

    return cmd
  end

end #/module Prawn4book
