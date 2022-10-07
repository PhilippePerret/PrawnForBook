module Prawn4book

##
# Permet de charger un module +name+ en appelant éventuellement
# sa méthode +calling+
def self.require_module(name, calling = nil)
  require File.join(MODULES_FOLDER,name)
  self.send(calling) unless calling.nil?
end

end #/module Prawn4book
