require 'fileutils'

class File

##
# Quand le fichier recette existe déjà, la méthode demande ce qu'elle
# doit en faire (destruction, copie, garder, etc.)
# 
# @return [Boolean] true s'il faut poursuivre ou false s'il ne faut
# pas aller plus loin.
def self.ask_what_to_do_with_file(pth, what)
  case Q.select("Le #{what} existe déjà, que dois-je en faire ?".jaune, ACTIONS_ON_FILE_EXIST, per_page:ACTIONS_ON_FILE_EXIST.count)
  when :cancel  then return false
  when :copy
    FileUtils.mv(pth, "#{pth}.backup")
  when :destroy
    delete(pth)
  end
  return true
end
ACTIONS_ON_FILE_EXIST = [
  {name:'Le conserver'            , value: :keep},
  {name:'En faire une copie'      , value: :copy},
  {name:'Le refaire complètement' , value: :destroy},
  {name:'Renoncer'                , value: :cancel}
]

end #/class File
