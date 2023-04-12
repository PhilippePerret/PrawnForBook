=begin
  Bac à sable de l'application, pour faire des essais

  Il suffit de :
  * si nécessaire, se placer dans le dossier voulu
  * écrire le code ci-dessous dans la méthode play_sandbox
  * jouer la commande 'pfb sandbox'

=end
require 'lib/commandes/build/lib/PrawnView'
module Prawn4book
class Command
  def proceed; Prawn4book.run_script end
end #/Command

##
# Commande pour exécuter un script du livre ou de la collection
# Cf. manuel
#
def self.run_script
  @current_book = PdfBook.ensure_current || return
  script_name = CLI.components[0] || ask_for_script() || return
  
  puts "script_name = #{script_name.inspect}"

  #
  # On cherche le script exact (si c'est un nom approchant qui 
  # a été donné) ou/et ses données
  #
  script_data = nil
  script_list.each do |dscript|
    if dscript[:name].match(/#{script_name}/i)
      script_data = dscript
      break
    end
  end

  puts "script_data = #{script_data.inspect}"

  script_data || begin
    puts "Le script est introuvable…".rouge
    return
  end

  ARGV[0] = @current_book.folder
  ARGV[1..4] = CLI.components[1..4]
  load script_data[:value]

end

def self.ask_for_script
  script_list || return
  choix = precedencize(script_list,File.join(__dir__,'scripts.precedences')) do |q|
    q.question "Script à jouer"
  end
  File.basename(choix, File.extname(choix))
end

def self.script_list
  @@script_list ||= begin
    ary = []
    ary += get_scripts_in(File.join(@current_book.folder,'scripts'))
    ary += get_scripts_in(File.join(@current_book.folder,'..','scripts'))
    ary
  end
end

def self.get_scripts_in(folder)
  folder = File.expand_path(folder)
  Dir["#{folder}/**/*.rb"].map do |fpath|
    {name: File.basename(fpath, File.extname(fpath)), value: fpath}
  end
end

def self.folders_script
  @@folders_script ||= begin
    ary = []
    if File.exist?(File.join(current_book.folder,'scripts'))
      ary << File.join(current_book.folder,'scripts')
    end
    collection_scripts_folder = File.expand_path(File.join(current_book.folder,'..','scripts'))
    puts "collection_scripts_folder : #{collection_scripts_folder.inspect}"
    if File.exist?(collection_scripts_folder)
      ary << collection_scripts_folder
    end    
    ary
  end
end

end #/module Prawn4book
