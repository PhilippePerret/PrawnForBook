module Prawn4book
  
  # @runner
  class Command
    def proceed; end
    def proceed_assistant_fontes
      pdfbook = check_if_current_book_or_return || return
      Prawn4book.assistant_fontes(pdfbook)
    end
    def proceed_assistant_biblio
      pdfbook = check_if_current_book_or_return || return
      Prawn4book.assistant_biblio(pdfbook)
    end

    def check_if_current_book_or_return
      PdfBook.current? || begin
        puts MESSAGES[:assistant][:require_book_folder].orange
        return false
      end
      PdfBook.current
    end
  end #/Command


  # --- Assistant pour les bibliographies ---

  def self.assistant_biblio(pdfbook)
    clear 

    dMessages = MESSAGES[:assistant][:biblio]
    puts dMessages[:intro].bleu

    # 
    # Table des identifiants et table des titres, pour vérifier
    # de ne pas en créer deux identiques
    # 
    already_titles = {}
    already_tags   = {}
    
    dbiblios = pdfbook.recipe[:biblio] || {}

    if dbiblios.any?
      bibs = dbiblios.map do |dbib|
        already_tags.merge!(dbib[:tag] => true)
        already_titles.merge!(dbib[:title] => true)
        "'#{dbib[:tag]}' (#{dbib[:title]})" 
      end.pretty_join
      puts (dMessages[:has_already_biblio] % bibs).bleu
      Q.yes?(PROMPTS[:devons_nous_en_creer_dautres].jaune) || return
    end

    puts "\n\n"

    new_tags = []

    # Tant qu'on veut introduire des bibliographies
    while true
      # Tant qu'on n'a pas défini cette bibliographie
      dbiblio = {}
      while true
        # 
        # Le titre de la bibliographie
        # 
        while dbiblio[:title].nil?
          btitre ||= Q.ask(PROMPTS[:biblio][:title_of_new_biblio].jaune)
          btitre = btitre.strip
          if already_titles[btitre]
            puts ERRORS[:biblio][:title_already_exists].rouge
          else
            dbiblio.merge!(title: btitre)
          end
        end
        # 
        # L'identifiant unique de la bibliographie
        # 
        while dbiblio[:tag].nil?
          btag ||= Q.ask(PROMPTS[:biblio][:tag_uniq_and_simple_minuscules].jaune)
          if already_tags[btag]
            puts ERRORS[:biblio][:tag_already_exists].rouge
          else
            dbiblio.merge!(tag: btag)
          end
        end
        #
        # Le fichier ou dossier de données (le demander ou 
        # aider à le préparer)
        # 
        bdata ||= ask_for_bib_data(pdfbook, dbiblio)
        dbiblio.merge!(data: bdata)
        # 
        # Niveau du titre
        # 
        blevel ||= Q.slider(PROMPTS[:biblio][:title_level].jaune, min:1, max:5, default:1)
        dbiblio.merge!(title_level: blevel)
        #
        # Nouvelle page ?
        #
        bnewpage ||= Q.yes?(PROMPTS[:biblio][:show_on_new_page].jaune)
        dbiblio.merge!(new_page: bnewpage)
        #
        # L'aspect de la bibliographie
        # (par défaut ou personnalisé)
        # 
        baspect ||= Q.select(PROMPTS[:biblio][:aspect_of_new_biblio].jaune, MENU_BIB_ASPECT, per_page:MENU_BIB_ASPECT.count) 
        dbiblio.merge!(aspect: baspect)

        if btitre && btag && bdata && baspect && blevel
          break
        elsif btitre.nil? && btag.nil? && bdata.nil? && baspect.nil?
          dbiblio = nil
          break # renoncement
        end

      end #/while (définition de la bibliographie)

      # Renoncement (toutes les valeurs à nil)
      break if dbiblio.nil?

      # 
      # On ajoute la bibliographie
      # 
      baspect = dbiblio.delete(:aspect)
      dbiblios << dbiblio
      new_tags << dbiblio[:tag]
      
      #
      # Demande pour une autre, sinon on arrête
      # 
      break unless Q.yes?(PROMPTS[:biblio][:create_a_new_biblio].jaune)
      
      # 
      # Pour ne pas refaire le même
      # 
      already_titles.merge!(dbiblio[:title] => true)
      already_tags.merge!(dbiblio[:tag] => true)

    end #/while (tant qu'on veut des bibliographies)
    
    #
    # Enregistrement de la donnée :biblio avec les nouvelles données
    # 
    if pdfbook.collection?
      pdfbook.recipe.update_collection(biblio: dbiblios)
    else
      pdfbook.recipe.update(biblio: dbiblios)
    end

    #
    # Aide finale :
    # 
    bibun = new_tags.first # pour les exemples ci-dessous
    puts MESSAGES[:biblio][:bibs_created_with_success].vert
    method_list = new_tags.map {|t| "\t- biblio_#{t}" }.join("\n")
    puts (MESSAGES[:biblio][:explaination_after_create] % [method_list,bibun,bibun]).jaune

  end

  def self.ask_for_bib_data(pdfbook, dbiblio)
    pth = Q.ask(PROMPTS[:biblio][:folder_or_file_of_data_biblio].jaune)
    if pth && File.exist?(pth)
      return pth
    elsif pth && File.exist?(File.join(pdfbook.folder, pth))
      return File.join(pdfbook.folder, pth)
    elsif dbiblio[:id]
      puts ERRORS[:biblio][:not_an_existing_file].orange
      if Q.yes?((PROMPTS[:biblio][:should_i_create_file_in] % [File.join(pdfbook.folder,'biblio'), dbiblio[:tag] ]).jaune)
        relpath = File.join('biblio', "#{dbiblio[:tag]}.yaml")
        pth = File.join(pdfbook.folder, relpath)
        datadefault = {'uniqid' => {'title' => "Son titre", 'year' => 2022}}
        File.write(pth, datadefault.to_yaml)
        return relpath
      end
    end
    return nil
  end

MENU_BIB_ASPECT = [
  {name:PROMPTS[:By_default],   value: :default},
  {name:PROMPTS[:Personnalisé], value: :custom},
  {name:PROMPTS[:i_dont_know],  value: nil}
]


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
        {name: File.basename(fpath), value: fpath}
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


  def self.cfolder
    @@cfolder ||= File.expand_path('.')
  end
end #/Prawn4book
