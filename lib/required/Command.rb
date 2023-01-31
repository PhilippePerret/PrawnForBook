module Prawn4book
class Command

  attr_reader :ini_name, :name

  def initialize(ini_name)
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
    File.exist?(script_path) || begin
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
