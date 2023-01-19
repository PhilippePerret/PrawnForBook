module UtilsMethods

##
# Permet de charger un module +name+ en appelant éventuellement
# sa méthode +calling+
def self.require_module(name, calling = nil)
  require File.join(MODULES_FOLDER,name)
  self.send(calling) unless calling.nil?
end

end #/module UtilsMethods

def erreur_fatale(msg, err_num = 1)
  puts "\n\n"
  puts msg.rouge
  puts "This issue must be fixed, sorry.".rouge
  puts "\n"
  exit err_num
end
alias :fatal_error :erreur_fatale

# Affiche l'erreur en la formatant : on garde toujours le message
# ainsi que la première ligne, où est localisé l'erreur. En mode
# debug (-x/--debug), on affiche tout le backtrace, mais la ligne
# où a vraiment lieu l'erreur est en rouge tandis que les autres sont
# en orange (pour une visualisation claire de où se passe l'erreur)
# 
def formated_error(err)
  if debug?
    trace = err.backtrace[0..-4].map.with_index do |line, idx|
      color = idx == 0 ? :rouge : :orange
      prefix = idx == 0 ? '🧨 ' : '   '
      (" #{prefix}" + line.gsub(/#{APP_FOLDER}/,'')).send(color)
    end.join("\n")
  else
    trace = '🧨 ' + err.backtrace.first.gsub(/#{APP_FOLDER}/,'')
  end
  err_msg = "#ERR: #{err.message}\n#{trace}"
  puts err_msg.rouge
  spy "#{err_msg}\n#{err.backtrace.join("\n")}".rouge
end

