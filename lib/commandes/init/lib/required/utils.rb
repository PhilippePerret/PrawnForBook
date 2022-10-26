require 'fileutils'

class File

def self.ask_what_to_do_with_file(pth, what)
  case Q.select("Le #{what} existe déjà, que dois-je en faire ?".jaune, ACTIONS_ON_FILE_EXIST, per_page:ACTIONS_ON_FILE_EXIST.count)
  when :cancel  then return :cancel
  when :keep    then return :keep
  when :copy
    FileUtils.mv(pth, "#{pth}.backup")
  when :destroy
    delete(pth)
  end
end
ACTIONS_ON_FILE_EXIST = [
  {name:'Le conserver'            , value: :keep},
  {name:'En faire une copie'      , value: :copy},
  {name:'Le refaire complètement' , value: :destroy},
  {name:'Renoncer'                , value: :cancel}
]

end #/class File
