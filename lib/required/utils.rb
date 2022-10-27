module Prawn4book

##
# Permet de charger un module +name+ en appelant éventuellement
# sa méthode +calling+
def self.require_module(name, calling = nil)
  require File.join(MODULES_FOLDER,name)
  self.send(calling) unless calling.nil?
end

##
# Méthode générique permettant de remplacer du code entre balises
# dans le fichier recette (ou dans du code YAML en général.
# 
# Explication : dans le fichier recette, les gros "blocs" comme la
# définition des titres, les bibliographies ou les fontes sont 
# délimitées par des balises du type '<fontes>....</fontes>' pour
# pouvoir les modifier par l'assistant.
# 
# La balise doit ressembler exactement à ça :
#   Balise d'entrée  : '# <tag_name>'
#   Balise de sortie : '# </tag_name>'
# 
def remplace_between_balises_with(str, tag_name, code)
  code = code[4..-1] if code.start_with?("---")
  tag_in  = "# <#{tag_name}>"
  tag_out = "# </#{tag_name}>"
  dec_in  = str.index(tag_in) || raise("La balise '# <#{tag_name}>' est malheureusement introuvable.")
  dec_in += tag_in.length
  dec_out = str.index(tag_out) || raise("La balise '</#{tag_name}>' est malheureusement introuvable.")
  dec_out -= 1
  code = str[0..dec_in] + code + str[dec_out..-1]    
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


