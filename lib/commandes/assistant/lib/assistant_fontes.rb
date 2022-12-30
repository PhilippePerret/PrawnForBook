module Prawn4book
class Assistant

  # --- Assistant pour les fontes ---

  def self.assistant_fontes(owner)
    FontAssistant.new(owner).define_fonts
  end

class FontAssistant

  attr_reader :owner


  # @param [Prawn4book::PdfBook|Prawn4book::Collection] Le propriétaire du fichier recette.
  def initialize(owner)
    @owner = owner
  end

  def fonts_data
    @fonts_data ||= owner.recipe.fonts_data
  end

  def define_fonts
    # 
    # Définir ou redéfinir les polices
    # 
    if choose_fonts
      # 
      # Insertion des fontes dans le fichier recette
      # 
      owner.recipe.insert_bloc_data(:fonts, {fonts: fonts_data})
      message_fin = MESSAGES[:recipe][:fonts_can_be_added].bleu
    else
      # 
      # En cas d'abandon
      # 
      message_fin = MESSAGES[:cancel].orange
    end
    puts message_fin
  end


  ##
  # Pour choisir les fonts dans les dossiers
  # 
  # @return [True|False] suivant que la table doit être enregistrée
  # (true) ou pas (false).
  # 
  # Permet de définir la table des polices qui sera enregistrée dans
  # le fichier recette du livre ou de la collection. 
  # C'est une table avec en clé le nom donné à la police (pe "MonArial") 
  # et en valeur une table avec les paths suivant les différents styles.
  #     Par exemple :
  #     Table fontes = {
  #       'MonArial' => {
  #         normal: 'path/to/normal.ttf',
  #         italic: 'path/to/italique.ttf'
  #       }
  #     }
  # 
  def choose_fonts
    #
    # Définir la table qui permettra de connaitre les informations
    # des fontes actuelles
    # 
    fonts_table_by_path
    #
    # Ajouter le menu pour choisir les fonts du livre et/ou de la 
    # collection. Si c'est une collection, on met simplement le menu
    # fonts de la collection s'il existe et si c'est un livre, on met
    # les deux dossiers suivant qu'ils existent ou non.
    # 
    add_menus_book_and_collection_fonts

    #
    # On boucle pour déterminer les polices.
    # L'opération se passe en trois temps :
    #   Temps 1 : l'user choisit le dossier dans lequel chercher les polices
    #   Temps 2 : l'user choisit les polices à retenir dans ce dossier
    #   Temps 3 : l'user définit pour quelle police et style de police doit être utilisé chaque path retenu.
    while true
      # 
      # Temps 1 : choix du dossier de police à fouiller
      # 
      fonts_folder = choose_folder_fonts || break
      #
      # Temps 2 : choix des polices (path) dans ce dossier
      # 
      polices_path = choose_police_in_folder(fonts_folder)
      # 
      # Temps 3 : attribution de nom et de styles pour affectation
      #           et consignation.
      define_fonts_name_and_style(polices_path)

    end #/while

    return true
  end

  ##
  # Pour définir, à partir des paths des polices, les noms à utiliser
  # dans la recette ou le livre, ainsi que le style.
  # 
  # @return void
  #
  # @example (retour)
  # 
  #   data fontes = {
  #     "<nom de la fonte>" => {
  #         <style 1> => <path to font style 1>
  #         <style 2> => <path to font style 2>
  #         etc.
  #       }
  #   }
  # 
  # @param [Array<String>] paths_fonts Choosed fonts path list 
  # 
  def define_fonts_name_and_style(paths_fonts)
    # 
    # On boucle sur chaque path de fontes pour définir avec quel
    # nom et quel style elle sera utilisée.
    # 
    # Pour être clair : on manipule trois choses ici (et dans les
    # fontes en général)
    #   - le chemin d'accès à la police ttf     : font_path
    #   - le nom générique pour cette police    : font_name
    #   - le style exact correspondant au path  : font_style
    # 
    # Bien comprendre qu'un path correspond à un style. Par exemple,
    # pour une police qui s'appellera (font_name) "Arial", on pourra
    # avoir le fichier "Arial Bold.ttf" pour le style :bold, le 
    # fichier "Arial Italic.ttf" pour le style :italic et "Arial.ttf"
    # pour le style :normal
    # 
    paths_fonts.each do |font_path|
      # 
      # Pour savoir si c'est une fonte qu'on connait déjà 
      #
      is_known_font = fonts_table_by_path.key?(font_path)
      # 
      # Choisir le nom pour cette fonte (souvent l'affixe)
      # 
      default_name = if is_known_font
        fonts_table_by_path[font_path][:name]
      else
        File.basename(font_path, File.extname(font_path)).split(' ').first
      end
      # 
      # CHOISIR LE NOM
      # 
      font_name = Q.ask((PROMPTS[:fonts][:what_is_font_name] % File.basename(font_path)).jaune, {default: default_name})
      # 
      # Pour sélectionner le style choisi pour cette fonte si c'est
      # une fonte déjà définie et possédant ce style.
      # 
      default_selected = DATA_STYLES_FONTS.select.with_index do |dstyle, idx|
          is_known_font && dstyle[:value] == fonts_table_by_path[font_path][:style]
        end.first[:index]

      # 
      # CHOISIR LE STYLE
      # 
      font_style = Q.select(PROMPTS[:fonts][:which_style_for_font].jaune, DATA_STYLES_FONTS, {per_page: DATA_STYLES_FONTS.count, default: default_selected, show_help: false})
      
      # 
      # On ajoute cette donnée fonte aux données fontes courantes
      # 
      @fonts_data.merge!(font_name => {}) unless @fonts_data.key?(font_name)
      @fonts_data[font_name].merge!(font_style => font_path)
      # 
      # On l'ajoute aussi à la liste pour connaitre les fontes déjà
      # définies.
      # 
      @fonts_table_by_path.merge!(font_path => {name:font_name, style: font_style})
    end
    
  end

  ##
  # Pour choisir les polices dans le dossier retenu
  # 
  def choose_police_in_folder(fonts_folder)
    # 
    # On prépare la liste des fontes du dossier en sélectionnant 
    # les polices déjà retenues.
    #
    default = [] # pour mettre les index des fontes sélectionnées

    fontes = Dir["#{fonts_folder}/*.ttf"].map do |fpath|
      nfont = File.basename(fpath)
      next if nfont.start_with?('Noto') # il y en a trop
      {name: nfont, value: fpath}
    end.compact.sort_by do |dh|
      dh[:name]
    end.each_with_index do |dh, idx|
      default << (idx + 1) if fonts_table_by_path.key?(dh[:value])
    end

    # 
    # Nombre de police affichées (il peut y en avoir beaucoup)
    # 
    ppage = [fontes.count, console_height - 5].min
    # 
    # Choisir les fontes (cochées)
    # 
    clear unless debug?
    Q.multi_select(PROMPTS[:fonts][:choose_the_fonts].jaune, fontes, {per_page: ppage, default: default, show_help: false, echo:false})
    
  end

  ##
  # Méthode pour choisir le dossier fontes à fouiller.
  # @return [String] Le chemin d'accès au dossier choisi ou :finir
  #     pour terminer la relève.
  #
  def choose_folder_fonts
    # 
    # Préparation des menus, en indiquant, pour chaque dossier,
    # le nombre de fontes qui sont déjà retenues
    # 
    choices = prepare_folder_fonts_choices

    fonts_folder = Q.select(PROMPTS[:Folder].jaune, choices, {per_page: choices.count})
    if fonts_folder == :finir
      return nil
    else
      return fonts_folder
    end
  end

  ##
  # Pour simplifier le travail, on fait à partir des données courantes
  # du livre ou de la collection une table qui contient en clé le
  # path vers la fonte, et en valeur une table contenant le style et
  # le nom donné à la fonte.
  def fonts_table_by_path
    @fonts_table_by_path ||= begin
      tbl = {}
      fonts_data.each do |fontname, fontdata|
        fontdata.each do |style, path|
          tbl.merge!(path => {name: fontname, style: style})
        end
      end
      tbl
    end
  end

  def prepare_folder_fonts_choices
    # Toute première préparation, pour mettre le nom original de côté
    if DATA_FONTS_FOLDERS.first[:raw_name].nil?
      DATA_FONTS_FOLDERS.each { |dchoix| dchoix.merge!(raw_name: dchoix[:name].dup)}
    end
    # 
    # On ajoute le nombre de fontes pour chaque dossier
    # 
    DATA_FONTS_FOLDERS.each do |dchoix|
      nombre = fonts_table_by_path.keys.select do |pth|
        File.dirname(pth) == dchoix[:value]
      end.count
      dchoix.merge!(name: "#{dchoix[:raw_name]} (#{nombre})")
    end

    return DATA_FONTS_FOLDERS + [CHOIX_FINIR]
  end

  ##
  # Méthode qui ajoute aux choices des dossiers les dossiers des fonts
  # du livre et/ou de la collection.
  # 
  def add_menus_book_and_collection_fonts
    dos_fonts = owner.folder_fonts
    if File.exist?(dos_fonts) && Dir["#{dos_fonts}/*.ttf"].count > 0
      DATA_FONTS_FOLDERS.unshift({name:PROMPTS[:fonts][:book_fonts_folder], value: dos_fonts})
    end
    if owner.collection?
      dos_fonts = owner.collection.folder_fonts
      if File.exist?(dos_fonts) && Dir["#{dos_fonts}/*.ttf"].count > 0
        DATA_FONTS_FOLDERS.unshift({name:PROMPTS[:fonts][:collection_fonts_folder], value: dos_fonts})
      end
    end        
  end

  DATA_FONTS_FOLDERS = [
    # {name: 'Dossiers fonts du livre', value: nil}, # peut être ajouté
    # {name: 'Dossiers fonts de la collection', value: nil}, # peut être ajouté
    {name: PROMPTS[:fonts][:system_fonts_folder], value: '/System/Library/Fonts'},
    {name: PROMPTS[:fonts][:system_fonts_sup_folder], value: '/System/Library/Fonts/Supplemental'},
    {name: PROMPTS[:fonts][:user_fonts_folder], value: File.join(Dir.home,'Library','Fonts')},
  ]

end #/class FontAssistant
end #/class Assistant
end #/module Prawn4book
