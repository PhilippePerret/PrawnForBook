module Prawn4book
class Command

  attr_reader :ini_name, :name

  def initialize(ini_name)
    ini_name ||= 'help'
    @ini_name = ini_name
    @name = COMMAND_NAMES_TO_COMMAND_REAL_NAME[ini_name.downcase]||ini_name
  end

  def run
    Object.const_set('COMMAND_FOLDER', folder)
    self.load&.proceed
  rescue PrawnFatalError => e
    puts "\n#{e.message}".rouge
    if debug?
      puts e.backtrace.join("\n").rouge 
    else
      puts "(ajouter --debug pour voir le détail)".gris
    end
    puts "\n\n"
    exit 1
  rescue FatalError => e
    puts e.message.rouge
    exit
  end

  def load
    File.exist?(script_path) || 
    begin
      # Serait-ce un outil (dans tools)
      _name = "tools"
      _folder       = File.join(COMMANDS_FOLDER,_name)
      _lib_folder   = File.join(_folder,'lib')
      _script_path  = File.join(_folder,"#{_name}.rb")
      Dir["#{_lib_folder}/**/*.rb"].each{|m|require(m)}
      require _script_path
      if tool_exist?(name)
        Object.send(:remove_const, :COMMAND_FOLDER)
        CLI.components[0] = name
        return Command.new("tools").run
      end
    end ||
    begin
      puts "Je ne connais pas la commande #{ini_name.inspect}".rouge
      puts "(jouer 'pfb -h' pour obtenir de l'aide)".bleu
      return
    end
    Dir["#{lib_folder}/**/*.rb"].each{|m|require(m)}
    require script_path
    return self
  end

  def script_path
    @script_path ||= File.join(folder,"#{name}.rb")
  end

  def lib_folder
    @lib_folder ||= File.join(folder,'lib')
  end

  def folder
    @folder ||= File.join(COMMANDS_FOLDER,name)
  end
#
# Les commandes peuvent être données avec différents noms
# 
COMMAND_NAMES_TO_COMMAND_REAL_NAME = {
  'create'    => 'init',
  'essai'     => 'sandbox',
  'essais'    => 'sandbox',
  'generate'  => 'build',
  'outils'    => 'tools',
  'ouvre'     => 'open',
  'choisir'   => 'choose',
  'cibles'    => 'targets',
  'tool'      => 'tools',
}
def self.add_commands_substitutes(real_command, substitutes)
  substitutes.each do |cmd|
    COMMAND_NAMES_TO_COMMAND_REAL_NAME.merge!(cmd => real_command)
  end
end
# - Substituts à la commande 'help' -
add_commands_substitutes('help', [nil, 'aide', 'manual', 'manuel', 'prawn-manual', 'prawn-manuel','manuel-prawn'])
# - Substituts à la commande 'biblio' -
add_commands_substitutes('biblio', ['bib','bibliography','bibliographies'])

end #/class Command
end #/module Prawn4book
