module Prawn4book
class Command

  attr_reader :ini_name, :name

  def initialize(ini_name)
    @ini_name = ini_name
    @name = COMMAND_NAMES_TO_COMMAND_REAL_NAME[ini_name]||ini_name
  end

  def run
    self.load.proceed
  end

  def load
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
  nil         => 'help',
  'aide'      => 'help',
  'create'    => 'init',
  'essai'     => 'sandbox',
  'essais'    => 'sandbox',
  'generate'  => 'build',
  'manual'    => 'help',
  'manuel'    => 'help',
  'outils'    => 'tools',
  'ouvre'     => 'open',
}

end #/class Command
end #/module Prawn4book
