module Prawn4book
  
  # @runner
  class Command
    def proceed; end
    def proceed_assistant_fontes
      Prawn4book.assistant_fontes
    end
    def proceed_assistant_biblio
      Prawn4book.assistant_biblio
    end
  end #/Command

  def self.assistant_biblio
    puts "Je dois apprendre à assister à la fabrication des bibliographies.".jaune
  end

  def self.assistant_fontes
    frecipe = File.join(cfolder,'recipe.yaml')
    unless File.exist?(frecipe)
      frecipe = File.join(cfolder,'recipe_collection.yaml')
    end
    unless File.exist?(frecipe)
      puts "Il faut se trouver dans un dossier de livre ou de collection.\n\n".rouge
      return
    end

    fonts = { fonts: get_name_fonts({main_folder: cfolder}) }

    clear
    code_yaml = "\n\n" + fonts.to_yaml.split("\n")[1..-1].join("\n")
    puts "CODE À AJOUTER :\n\n#{code_yaml}\n".bleu
    Q.yes?('Dois-je ajouter le code ci-dessus au fichier recette ?'.jaune) || return
    File.open(frecipe,'a') do |f| f.puts code_yaml end
    puts 'Ces fontes peuvent être ajoutées aux fontes déjà présentes.'.bleu
    if Q.yes?('Dois-je ouvrir le fichier recette ?'.jaune)
      `subl -n "#{frecipe}"`
    end

  end

  def self.get_name_fonts(cdata = nil)
    name_fonts(choose_fonts(cdata))
  end

  # Méthode qui reçoit les paths des fonts choisies et retourne une
  # table qui permettra d'enregistrer les polices.
  # 
  # @return {Hash} Table avec en clé le nom de la police (qui sera
  # utilisé avec la méthode 'font' dans Prawn) et en valeur une
  # table indiquant le style (:normal, :bold, etc.)
  def self.name_fonts(paths_fonts)
    fonts_table = {}
    paths_fonts.each do |fontpath|
      font_name = File.basename(fontpath)
      main_name = Q.ask("Nom de police principal pour la fonte '#{font_name}' : ".jaune)
      styles_enabled = 
        if fonts_table.key?(main_name)
          DATA_STYLES_FONTS.reject do |dstyle|
            fonts_table[main_name].keys.include?(dstyle[:value])
          end
        else
          DATA_STYLES_FONTS
        end 
      style = Q.select("Quel style donner à cette fonte ?".jaune, styles_enabled, per_page: styles_enabled.count)
      fonts_table.merge!(main_name => {}) unless fonts_table.key?(main_name)
      fonts_table[main_name].merge!(style => fontpath)
    end
    return fonts_table
  end

DATA_STYLES_FONTS = [
  {name: 'Normal'         , value: :normal},
  {name: 'Italic'         , value: :italic},
  {name: 'Bold'           , value: :bold},
  {name: 'Extra-bold'     , value: :extra_bold},
  {name: 'Léger (light)'  , value: :light},
  {name: 'Extra-léger'    , value: :extra_light}
]

  ##
  # Pour choisir les fonts dans les dossiers
  # @return {Array/String} Liste des chemins d'accès aux fonts 
  # choisies
  # 
  def self.choose_fonts(cdata)
    book_fonts = File.join(cdata[:main_folder],'fonts')
    if File.exist?(book_fonts) && Dir["#{book_fonts}/*.ttf"].count > 0
      DATA_FONTS_FOLDERS.unshift({name:'Dossier fonts du livre', value: book_fonts})
    end
    if cdata[:collection]
      coll_fonts = File.join(cfolder, 'fonts')
      if File.exist?(coll_fonts) && Dir["#{coll_fonts}/*.ttf"].count > 0
        DATA_FONTS_FOLDERS.unshift({name:'Dossier fonts de la collection', value: coll_fonts})
      end
    end

    fontes_choisies = []
    while true
      fdossier = Q.select("Dossier : ".jaune, DATA_FONTS_FOLDERS, per_page: DATA_FONTS_FOLDERS.count) || break
      fontes = Dir["#{fdossier}/*.ttf"].map do |fpath|
        {name: File.basename(fpath), value: fpath}
      end
      fontes_choisies += Q.multi_select("Choisir les fonts…", fontes, per_page: fontes.count)
    end #/while

    return fontes_choisies
  end

  DATA_FONTS_FOLDERS = [
    # {name: 'Dossiers fonts du livre', value: nil}, # peut être ajouté
    # {name: 'Dossiers fonts de la collection', value: nil}, # peut être ajouté
    {name: 'Dossier fonts système'  , value: '/System/Library/Fonts'},
    {name: 'Dossier fonts système supplémentaires' , value: '/System/Library/Fonts/Supplemental'},
    {name: 'Dossier fonts user'     , value: File.join(Dir.home,'Library','Fonts')},
    {name: 'Finir', value: nil}
  ]


  def self.cfolder
    @@cfolder ||= File.expand_path('.')
  end
end #/Prawn4book
