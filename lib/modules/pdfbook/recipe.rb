module Prawn4book
class PdfBook

  quest_book_id     = "Identifiant (seulement lettres et '_')".freeze
  quest_collection  = "Appartient-il à une collection ? (si oui, laquelle)".freeze
  quest_book_folder = "Dossier où placer le dossier du livre".freeze
  quest_text_path   = "Chemin d'accès au texte initial".freeze

  DATA_RECIPE = [
    {q: 'Numéroter les pages avec : ' , id:'num_page'     , v: nil , values: 'NUMPAGES_VALUES'},

  ]

  def self.is_defined_or_define(prop, cdata)
    if not(cdata.key?(prop)) || cdata[prop] === nil
      return send("define_#{prop}".to_sym, cdata)
    else
      return true
    end
  end

  ##
  # = main =
  # 
  # Méthode principale pour définir la recette du livre
  # 
  # @param cdata {Hash|Nil} Les données qui peuvent permettre de
  # définir des premières chose sur le livre dont il faut définir ou
  # redéfinir la recette.
  # 
  def self.define_book_recipe(cdata = nil, force = false)
    cdata ||= {}

    # --- POUR L'ESSAI ---
    cdata = {
      book_title:     "Mon livre",
      collection:     true,
      book_id:        'mon_livre',
      auteurs:        ['Marion MICHEL', 'Philippe PERRET'],
      main_folder:    "/Users/philippeperret/Programmes/Prawn4book/tests/essais/books/une_collection/mon_livre",
      text_path:      true,
      dimensions:     :collection,
      marges:         :collection,
      interligne:     :collection,
      opt_num_parag:  :collection,
      fonts:          nil, # :collection 
    }

    if cdata[:collection] === true
      cdata.merge!(instance_collection: Collection.new(cfolder))
    end


    clear
    [
      #
      # LISTE DES PROPRIÉTÉS À DÉFINIR
      # -------------------------------
      # 
      # [1] False si le livre n'appartient pas à une collection,
      #     True s'il appartient à la collection dans le dossier de
      #     laquelle il se trouve. 
      #     Ou le string du chemin d'accès au dossier de la collec-
      #     tion
      # 
      # [C] Les propriétés marquées de [C] seront pris de la recette
      #     de la collection si définies


      :book_title,      # {String} Le titre du livre
      :collection,      # {False|True|String} [1] False si le livre n'appartient
                        # pas à un
      :book_id,         # {String} Identifiant du livre
      :auteurs,         # {Array} Auteurs du livre. Array "Prénom NOM"
      :main_folder,     # {String} Dossier principal du livre
      :text_path,       # {String} Chemin d'accès au fichier du texte original
      :dimensions,      # [C] {Array} [width, height]
      :marges,          # [C] {Hash} {:top, :int, :ext, :bot} 
      :interligne,      # [C] {Number}
      :opt_num_parag,   # [C] {Bool} Numéroter les paragraphes
      :fonts,           # [C] {Hash} Les fonts utilisées
      :num_page_style,  # [C] {String|Bool} Le type de numérotation pour la page
      # :header,
      # :footer,

    ].each do |prop|
      if force
        send("define_#{prop}".to_sym, cdata)
      else
        is_defined_or_define(prop, cdata) || return # pour interrompre
      end
    end

    # 
    # On retire l'instance de collection
    cdata.delete(:instance_collection)

    puts cdata.inspect

    # 
    # On crée le fichier de recette du livre
    # 
    create_recipe(cdata)

    puts "(jouer '#{COMMAND_NAME} manuel' pour ouvrir le manuel de l'application et voir notamment comment définir l'entête et le pied de page.)".gris
    puts "\n\n"
  end


  # ---- MÉTHODES GÉNÉRIQUES ----

  # --- Méthode générique pour demander une propriété ---
  def self.ask_for(cdata, question, prop, vdefaut = nil, aide = nil)
    if aide
      question = question + "\n#{"(#{aide})".gris}"
    end
    cdata.merge!(prop => Q.ask(question.jaune, default:(vdefaut||cdata[prop])))
    return true
  end

  # --- Méthode générique pour demander un nombre ---
  def self.ask_for_number(question, min, max, default)
    while true
      begin
        v = Q.ask("#{question} (entre #{min} et #{max}) : ".jaune, default: default).to_i
        v.between?(min, max) || raise("Valeur invalide ! (doit être entre #{min} et #{max}")
      rescue Exception => e
        puts e.message.rouge
      else
        return v
      end
    end
  end


  # ---- MÉTHODES DE DEMANDES DES DONNÉES ----


  # --- Toutes les méthodes de définition ---
  def self.define_book_title(cdata)
    ask_for(cdata, "Titre du livre", :book_title)
  end

  def self.define_book_id(cdata)
    vdefaut = cdata[:book_id] || cdata[:book_title].downcase.gsub(/ /,'_').gsub(/[^a-z_]/,'')
    ask_for(cdata, 'ID du livre', :book_id, vdefaut, 'servira pour plein de choses')
  end

  def self.define_auteurs(cdata)
    aide = 'sous forme "Prénom NOM, Prénom DE NOM, ..."'
    ask_for(cdata, 'Auteurs du livre', :auteurs, nil, aide)
    cdata[:auteurs] = cdata[:auteurs].split(',').map{|n|n.strip}
    return true
  end

  def self.define_main_folder(cdata)
    aide = 'tous les fichiers seront enregistrés dans ce dossier'
    vdefaut = 
      if cdata[:collection] === true
        mkdir(File.join(cfolder, cdata[:book_id]))
      else
        cfolder
      end
    while true
      ask_for(cdata,'Dossier du livre', :main_folder, vdefaut, aide)
      return true if File.exist?(cdata[:main_folder])
      puts "Impossible de trouver le dossier '#{cdata[:main_folder]}'…".rouge
    end
    return true
  end

  def self.define_text_path(cdata)
    tpath_txt = File.join(cdata[:main_folder],'texte.txt')
    tpath_md  = File.join(cdata[:main_folder],'texte.md')
    tpath = 
      if File.exist?(tpath_txt)
        tpath_txt
      elsif File.exist?(tpath_md)
        tpath_md
      else
        nil
      end

    while true # tant que le fichier n'est pas bon
      if tpath.nil?
        aide = "ce fichier sera copié dans le dossier du livre"
        ask_for(cdata,'Fichier contenant le texte original', :text_path, nil, aide)
        if File.exist?(cdata[:text_path])
          return true
        else
          puts "Le fichier '#{cdata[:text_path]}' est introuvable…".rouge
          cdata.merge!(text_path: nil)
        end
      else
        if Q.yes?("Le fichier texte est-il bien le fichier '#{tpath}' ?".jaune)
          cdata.merge!(text_path: true)
          return true
        else
          tpath = nil
        end
      end
    end #/while
  end #/define_text_path

  def self.define_dimensions(cdata)
    paire = 
      if cdata[:instance_collection] && cdata[:instance_collection].book_dimensions
        :collection
      else
        Q.select("Dimensions du livre", DIM_VALUES) || begin
          # Quand on choisit "autre"
          w = ask_for_number('Largeur en millimètres', 101.6, 215.9)
          h = ask_for_number('Hauteur en millimètres', 152.4, 296.9)
          [w, h]
        end
      end
    cdata.merge!(dimensions: paire)
    return true
  end

  def self.define_marges(cdata)
    quatro = 
      if cdata[:instance_collection] && cdata[:instance_collection].book_marges
        :collection
      else
        mtop = ask_for_number('Marge en haut en millimètres', 5, 80, 20)
        mbot = ask_for_number('Marge basse en millimètres', 5, 80, 25)
        mint = ask_for_number('Marge intérieure en millimètres', 10, 60, 25)
        mext = ask_for_number('Marge extérieure en millimètres', 5, 80, 20)
        {top: mtop, ext: mext, bot: mbot, int: mint}
      end
    cdata.merge!(marges: quatro)
  end

  def self.define_interligne(cdata)
    inter =
      if cdata[:instance_collection] && cdata[:instance_collection].interligne
        :collection
      else
        ask_for_number('Interligne', 0, 100, 1)
      end
    cdata.merge!(interligne: inter)
  end

  def self.define_opt_num_parag(cdata)
    numpar = 
      if cdata[:instance_collection] && not(cdata[:instance_collection].opt_num_parag === nil)
        :collection
      else
        Q.yes?('Faut-il numéroter les paragraphes ?'.jaune)
      end
    cdata.merge!(opt_num_parag: numpar)
  end

  ##
  # Définition complexe des fontes utilisées dans le livre ou
  # la collection
  # 
  def self.define_fonts(cdata)
    fonts =
      if cdata[:instance_collection] && cdata[:instance_collection].fonts
        :collection
      else
        name_fonts(choose_fonts(cdata))
      end
    cdata.merge!(fonts: fonts)
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
      main_name = Q.ask("Nom de police principal pour la fonte '#{font_name}'".jaune)
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

  # Pour définir le style de la numérotation des pages
  def self.define_num_page_style(cdata)
    pagestyle =
      if cdata[:instance_collection] && cdata[:instance_collection].num_page_style
        :collection
      else
        Q.select('Style de la numérotation des pages'.jaune, NUMPAGES_VALUES, per_page:NUMPAGES_VALUES.count)
      end
    cdata.merge!(num_page_style: pagestyle)
  end

NUMPAGES_VALUES = [
  {name: 'Numéro page courante seule'           , value: 'num_page'       },
  {name: 'Numéro page courante / nombre total de pages'  , value: 'num_et_nombre'  },
  {name: 'Ne pas numéroter les pages'             , value: false            },
  {name: 'Numéro de paragraphes'                  , value: 'num_parags'     }
  {name: 'Numéro de page et de paragraphes'       , value: 'num_page_et_parags'     }
]


  ##
  # Définition de la collection à laquelle appartient (ou pas) le
  # livre courant
  # 
  # False, True ou Path vers le dossier
  def self.define_collection(cdata)
    coll = nil # la valeur finale pour la propriété :collection
    # 
    # Est-ce que le dossier courant est le dossier d'une collection ?
    # 
    recipe_collection = File.join(cfolder, 'recipe_collection.yaml')
    if File.exist?(recipe_collection)
      collection = Collection.new(cfolder)
      if Q.yes?("Ce livre appartient-il à la collection « #{collection.name} » ?".jaune)
        cdata.merge!(instance_collection: collection)
        coll = true
      end
    end
    coll ||= begin
      if Q.yes?("Ce livre appartient-il à une collection ?".jaune)
        rep = Q.ask("Chemin d'accès à cette collection (laisser vide si on doit la créer ici)".jaune)
        coll = rep || 'CREATE_COLL_HERE'
      else
        coll = false
      end
    end
    cdata.merge!(collection: coll)
    return true
  end

  def OLD_enfiniravec_lelivre
    # 
    # On peut enregitrer le livre
    # 
    PdfBook.new.create_recipe(cdata)

  end

  def self.cfolder
    @@cfolder ||= File.expand_path('.')
  end


  # --- INSTANCE ---

  def create_recipe(data)

    # 
    # Création du dossier
    # 
    @folder = File.join(data[:main_folder], data[:id])
    mkdir(@folder)
    
    # 
    # Création du fichier recette
    # 
    @recipe_path = File.join(folder, 'recipe.yaml')
    File.write(recipe_path, data.to_yaml)

    #
    # On dépose le texte dans le dossier si nécessaire
    # 
    unless data[:text_path] === true
      FileUtils.cp(data[:text_path], text_path)
    end

    puts "Dossier du livre créé avec succès.".vert
    puts "Placez-vous dans ce dossier puis jouer ".jaune
    puts "la commande 'prawn-for-book build' pour ".jaune
    puts "produire la première version du livre.".jaune
  end

  def text_path
    @text_path ||= File.join(folder, "texte#{File.extname(original_text_path)}")
  end

  def original_text_path
    @original_text_path ||= data[:text_path]
  end

DIM_VALUES = [
  {name:'12,7 cm x 20,32 cm (5 x 8 po)' , value:[127, 203.2]   },
  {name:'A4 (21 x 29.7)'                , value:[210, 297]     },
  {name:'15,24 x 22,86 (6 x 9 po)'      , value:[152.4, 228.6] },
  {name:'A5 (14.85 x 21)'               , value:[148.5, 210]   },
  {name:'Autre dimension…'              , value: nil }

]

end #/class PdfBook
end #/module Prawn4book
