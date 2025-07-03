=begin
  Bac à sable de l'application, pour faire des essais

  Il suffit de :
  * si nécessaire, se placer dans le dossier voulu
  * écrire le code ci-dessous dans la méthode play_sandbox
  * jouer la commande 'pfb sandbox'

=end
# require './lib/commandes/build/lib/PrawnView'
module Prawn4book
class Command
  def proceed; Prawn4book::Script.run_script end
end #/Command

class Script
class << self
##
# Commande pour exécuter un script du livre ou de la collection
# Cf. manuel
#
def run_script
  # clear
  # 
  # Il faut s'assurer qu'il y ait un livre/collection actif
  # 
  @current_book = PdfBook.ensure_current || return
  # 
  # Le script à jouer
  # 
  script.exist? || begin
    puts "Script introuvable…".rouge
    return
  end
  
  puts "Nom du script à jouer : #{script.name.inspect}".bleu


  ARGV[0] = @current_book.folder
  ARGV[1..4] = CLI.components[1..4]


  script.run
  

end

# @return [Prawn4Book::Script] Instance du script à jouer (ou nil)
def script
  @script ||= new(CLI.components[0])
end

def script_list
  @script_list ||= begin
    ary = []
    ary += get_scripts_in(File.join(COMMAND_FOLDER,'scripts'))
    ary += get_scripts_in(File.join(@current_book.folder,'scripts'))
    ary += get_scripts_in(File.join(@current_book.folder,'..','scripts'))
    ary
  end
end

def get_scripts_in(folder)
  folder = File.expand_path(folder)
  Dir["#{folder}/**/*.rb"].map do |fpath|
    {name: File.basename(fpath, File.extname(fpath)), value: fpath}
  end
end


end # << self Script

###################       INSTANCE      ###################
  
  def initialize(prox_name)
    @prox_name = prox_name
  end

  def exist?
    path && File.exist?(path)
  end

  def run
    load path
  end

  def path
    @path ||= get_script_path
  end
  def name
    @name ||= File.basename(path)
  end

  private

    # @return [String] Le chemin d'accès au script
    def get_script_path
      if @prox_name
        #
        # <= Un nom a été fourni, peut-être le bon, ou approchant
        # => On le cherche dans la liste des scripts
        #
        search_script_path_in_script_list
      else
        # 
        # <= Aucun nom n'a été fourni
        # => On propose la liste des scripts pour en choisir un
        #
        choose_a_script
      end

    end

    def search_script_path_in_script_list
      regexp = /#{@prox_name}/i.freeze
      script_list.each do |dscript|
        return dscript[:value] if dscript[:name].match?(regexp)
      end        
    end

    # @return [String] Chemin d'accès complet du script
    # 
    # Permet de choisir un script dans la liste de tous les
    # scripts, natifs comme propre au livre ou la collection
    # 
    def choose_a_script
      precedencize(script_list, File.join(__dir__,'script.prec')) do |q|
        q.question "Quel script jouer ?"
      end
    end

    # Raccourci
    def script_list; self.class.script_list end

end #/class Script
end #/module Prawn4book
