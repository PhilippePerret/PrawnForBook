module Prawn4book
  # --- Assistant pour les fontes ---

  def self.assistant_fontes(pdfbook)
    frecipe = File.join(cfolder,'recipe.yaml')
    unless File.exist?(frecipe)
      frecipe = File.join(cfolder,'recipe_collection.yaml')
    end
    unless File.exist?(frecipe)
      erreurs_fatale ERRORS[:require_a_book_or_collection]
    end

    new_fonts = get_name_fonts({main_folder: cfolder})

    # 
    # Ajout des fontes
    # 
    if Q.yes?(PROMPTS[:recipe][:should_i_add_code_to_recipe].jaune)
      fontes = pdfbook.recipe[:fonts] || {}
      fontes.merge!(new_fonts)
      pdfbook.update_recipe(fonts: fontes)
      puts MESSAGES[:recipe][:fonts_can_be_added].bleu
    end
    # 
    # Ouverture du fichier recette ?
    # 
    if Q.yes?(PROMPTS[:recipe][:should_i_open_recipe_file].jaune)
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
      main_name = Q.ask((PROMPTS[:fonts][:what_is_font_name] % font_name).jaune)
      styles_enabled = 
        if fonts_table.key?(main_name)
          DATA_STYLES_FONTS.reject do |dstyle|
            fonts_table[main_name].keys.include?(dstyle[:value])
          end
        else
          DATA_STYLES_FONTS
        end 
      style = Q.select(PROMPTS[:fonts][:which_style_for_font].jaune, styles_enabled, per_page: styles_enabled.count)
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
  {name: 'Light'          , value: :light},
  {name: 'Extra-light'    , value: :extra_light}
]

  ##
  # Pour choisir les fonts dans les dossiers
  # @return {Array/String} Liste des chemins d'accès aux fonts 
  # choisies
  # 
  def self.choose_fonts(cdata)
    book_fonts = File.join(cdata[:main_folder],'fonts')
    if File.exist?(book_fonts) && Dir["#{book_fonts}/*.ttf"].count > 0
      DATA_FONTS_FOLDERS.unshift({name:PROMPTS[:fonts][:book_fonts_folder], value: book_fonts})
    end
    if cdata[:collection]
      coll_fonts = File.join(cfolder, 'fonts')
      if File.exist?(coll_fonts) && Dir["#{coll_fonts}/*.ttf"].count > 0
        DATA_FONTS_FOLDERS.unshift({name:PROMPTS[:fonts][:collection_fonts_folder], value: coll_fonts})
      end
    end

    fontes_choisies = []
    while true
      fdossier = Q.select(PROMPTS[:Folder].jaune, DATA_FONTS_FOLDERS, per_page: DATA_FONTS_FOLDERS.count) || break
      fontes = Dir["#{fdossier}/*.ttf"].map do |fpath|
        nfont = File.basename(fpath)
        next if nfont.start_with?('Noto') # il y en a trop
        {name: nfont, value: fpath}
      end
      fontes_choisies += Q.multi_select(PROMPTS[:fonts][:choose_the_fonts].jaune, fontes, per_page: fontes.count)
    end #/while

    return fontes_choisies
  end

  DATA_FONTS_FOLDERS = [
    # {name: 'Dossiers fonts du livre', value: nil}, # peut être ajouté
    # {name: 'Dossiers fonts de la collection', value: nil}, # peut être ajouté
    {name: PROMPTS[:fonts][:system_fonts_folder], value: '/System/Library/Fonts'},
    {name: PROMPTS[:fonts][:system_fonts_sup_folder], value: '/System/Library/Fonts/Supplemental'},
    {name: PROMPTS[:fonts][:user_fonts_folder], value: File.join(Dir.home,'Library','Fonts')},
    {name: PROMPTS[:finir], value: nil}
  ]

end #/Prawn4book
