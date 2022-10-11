module Prawn4book


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
