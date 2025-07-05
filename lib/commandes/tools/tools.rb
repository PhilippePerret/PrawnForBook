require "open3"
module Prawn4book

  # @runner
  class Command
    def proceed
      tool = (CLI.components[0] || raise("Il faut définir l'outil à utiliser")).to_sym.freeze
      if Tool.respond_to?(tool)
        Tool.send(tool, {just_info: false})
      else
        puts "Je ne connais pas l’outil #{tool.inspect}".rouge
        puts "Liste des outils".rouge
        Tool.singleton_methods(false).each do |tool|
          puts "#{tool}".bleu
          puts "  #{Tool.send(tool, {just_info: true})}".bleu
        end
      end
    end
  end #/Command

  class Tool
    class << self

      # === OUTIL pictophil ====
      # 
      # Permet de montrer la liste des caractères spéciaux de la 
      # police PictoPhil spéciales pour Prawn-4-book. Soit l'user
      # possède le paquet qui permet d'actualiser le fichier de
      # démo, soit on ouvre le fichier PDF montrant les caractères
      # (note : c'est cette même méthode qui permet de produire ce
      #  fichier)
      # 
      def pictophil(just_info: false)
        if just_info
          return "Outil permettant de lister les caractères (glyphes) utilisables de la police PictoPhil."
        end
        require './lib/modules/glyphes_pictophil'
        PictoPhil.show_glyph_list
      end

    end
  end


  # Les outils ci-dessous étaient là avant que je fasse de ce module
  # une "commande" normale en ajoutant Command::proceed
  def self.play_tools
    tool_name = CLI.components[0]
    
    if tool_name.nil?
      tool = choose_a_tool
    elsif File.exist?(pth = File.join(tools_folder,"#{tool_name}.rb"))
      require pth
    else
      puts "Je ne sais pas comment jouer l'outil #{tool_name.inspect}"
    end
  end


  def self.choose_a_tool
    tool_name = Q.select("Quel outil utiliser ?".jaune) do |q|
      q.choice "Listing des titres (contrôle de hiérarchie)", :listing_titres
      q.choice "Renoncer", :nil
      q.per_page 4
    end || return

    require_module("tools/#{tool_name}", :run_tool)
  
  end


  def self.tools_folder
    @@tools_folder ||= mkdir(File.join(LIB_FOLDER,'modules','tools'))
  end

end #/ module Prawn4book
