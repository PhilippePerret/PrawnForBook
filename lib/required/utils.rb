module Prawn4book

##
# Permet de charger un module +name+ en appelant éventuellement
# sa méthode +calling+
def self.require_module(name, calling = nil)
  require File.join(MODULES_FOLDER,name)
  self.send(calling) unless calling.nil?
end

end #/module Prawn4book

def erreur_fatale(msg, err_num = 1)
  puts "\n\n"
  puts msg.rouge
  puts "This issue must be fixed, sorry.".rouge
  puts "\n"
  exit err_num
end
alias :fatal_error :erreur_fatale
