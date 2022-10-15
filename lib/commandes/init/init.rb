module Prawn4book

# ::runner
class Command
  def proceed
    PdfBook.define_book_recipe
  end
end #/Command

class PdfBook

  ##
  # = main =
  # 
  # Méthode principale pour définir la recette du livre
  # Soit on demande simplement un template, soit on utilise
  # l'assistant, mais il n'est pas tout à fait à jour.
  # 
  # @param cdata {Hash|Nil} Les données qui peuvent permettre de
  # définir des premières chose sur le livre dont il faut définir ou
  # redéfinir la recette.
  # 
  def self.define_book_recipe(cdata = nil, force = false)
    clear
    case Q.select("Comment voulez-vous initier le livre ?".jaune, DEFINE_RECIPE_WAYS, per_page: DEFINE_RECIPE_WAYS.count)
    when NilClass
      return false
    when :assistant
      assistant_recipe(cdata, force)
    when :template
      templates_recipe
    end
  end

  #
  # --- PAR TEMPLATE ---
  # 
  def self.templates_recipe
    # 
    # Quoi initier ? (livre ou collection)
    # 
    case Q.select("Initier… ".jaune, TYPE_INITIED, per_page: TYPE_INITIED.count) || return
    when :book
      template_recipe_for_book
    when :collection
      template_recipe_for_collection
    end
  end

  def self.template_recipe_for_collection
    # 
    # Dossier dans lequel initier la collection
    # 
    puts "#{cfolder}".bleu
    unless Q.yes?("Le dossier ci-dessus est-il le dossier de la collection ?".jaune)
      @@cfolder = Q.ask("Dossier de la collection : ".jaune) || return
    end
    # 
    # Le chemin d'accès au fichier recette
    # 
    frecipe = File.join(cfolder, 'recipe_collection.yaml')
    # 
    # Traitement en cas d'existence du fichier recette
    # 
    traitement_si_fichier_recette_existe(frecipe) || return

    # 
    # Copie du fichier original
    # 
    fsource = File.join(templates_folder,'recipe_collection.yaml')
    FileUtils.cp(fsource, frecipe)
    # 
    # Ajout du code commun
    # 
    fcommun = File.join(templates_folder,'recipe_communs.yaml')
    File.open(frecipe,'a') do |f| f.puts File.read(fcommun) end

    #
    # Confirmation et demande d'ouverture
    # 
    confirme_create_of(frecipe)

  end

  def self.template_recipe_for_book
    # 
    # Se trouve-t-on dans le dossier d'une collection ?
    # 
    coll_folder = nil
    if File.exist?(File.join(cfolder,'recipe_collection.yaml'))
      # Si on se trouve dans le dossier de la collection
      coll_folder = cfolder
    else
      # Si on se trouve dans le dossier du nouveau livre
      coll_folder = File.dirname(cfolder)
      coll_folder = nil unless File.exist?(File.join(coll_folder,'recipe_collection.yaml'))
    end
    if coll_folder
      collection = Collection.new(coll_folder)
      if Q.yes?("Est-ce un livre pour la collection « #{collection.name} » ?".jaune)
        create_template_book_in_collection(coll_folder)
      else
        create_template_book_hors_collection
      end
    else
      create_template_book_hors_collection
    end
  end

  def self.create_template_book_in_collection(coll_folder)
    # 
    # Déterminer (et créer) le dossier du livre
    # 
    if cfolder == coll_folder
      # 
      # Quand on se trouve dans le dossier de la collection
      #
      book_folder = File.join(coll_folder, Q.ask("Nom du dossier du livre : ".jaune))
      mkdir(book_folder)
    else
      #
      # Quand on se trouve dans le dossier du livre
      # 
      book_folder = cfolder
    end
    puts "Dossier du livre : #{book_folder}".bleu
    frecipe = File.join(book_folder,'recipe.yaml')
    # 
    # Traitement en cas d'existence du fichier recette (copie, 
    # destruction ou renoncement)
    # 
    traitement_si_fichier_recette_existe(frecipe) || return
    # 
    # Faire le fichier initial
    # 
    fsource = File.join(templates_folder,'recipe.yaml')
    FileUtils.cp(fsource, frecipe)
    # 
    # Ajouter les informations commune
    # 
    fcommun = File.join(templates_folder,'recipe_communs.yaml')
    File.open(frecipe,'a') do |f|
      if Q.yes?("La plupart des informations viendront-elles de la recette de la collection ?".jaune)
        YAML.load_file(fcommun, aliases: true).each do |k, v|
          f.puts ":#{k}: :collection"
        end
      else
         f.puts File.read(fcommun)
      end
    end
    # 
    # Confirmation création
    # 
    confirme_create_of(frecipe)
  end

  def self.create_template_book_hors_collection

    puts "#{cfolder}".bleu
    unless Q.yes?("Le dossier ci-dessus est-il bien le dossier du livre ?".jaune)
      @@cfolder = mkdir(File.join(cfolder, Q.ask('Nom du dossier : '.jaune)))
    end
    puts "Dossier du livre : #{cfolder}".bleu
    # 
    # Chemin d'accès au fichier recette
    # 
    frecipe = File.join(cfolder,'recipe.yaml')
    # 
    # Traitement en cas d'existence du fichier recette (copie, 
    # destruction ou renoncement)
    # 
    traitement_si_fichier_recette_existe(frecipe) || return
    # 
    # Faire le fichier initial
    # 
    fsource = File.join(templates_folder,'recipe.yaml')
    FileUtils.cp(fsource, frecipe)
    # 
    # Ajouter les informations commune
    # 
    fcommun = File.join(templates_folder,'recipe_communs.yaml')
    File.open(frecipe,'a') do |f|
      f.puts File.read(fcommun)
    end
    # 
    # Confirmation création
    # 
    confirme_create_of(frecipe)
  end

  def self.traitement_si_fichier_recette_existe(frecipe)
    if File.exist?(frecipe)
      puts "\nATTENTION ! Un fichier recette existe déjà dans ce dossier !".rouge
      case Q.select("Que dois-je faire ?".jaune, ACTIONS_ON_COLLECTION_EXIST, per_page: ACTIONS_ON_COLLECTION_EXIST.count)
      when :cancel
        return
      when :keep
        FileUtils.mv(frecipe, "#{frecipe}.copie")
      when :destroy
        File.delete(frecipe)
      end
    end    
    return true
  end

  def self.confirme_create_of(frecipe)
    if File.exist?(frecipe)
      puts "Fichier recette produit avec succès.".vert
      if Q.yes?('Dois-je créer un fichier texte ?'.jaune)
        ext = Q.select("Quel format ?".jaune) do |q|
          q.choice 'Markdown', 'md'
          q.choice 'Simple texte', 'txt'
        end
        fname = "texte.p4b.#{ext}"
        fpath = File.join(File.dirname(frecipe),fname)
        File.write(fpath, "<!-- Fichier texte -->")
      end
      if Q.yes?("Dois-je ouvrir le dossier dans l’éditeur ?".jaune)
        `subl -n "#{File.dirname(frecipe)}"`
      end
    else
      puts "\nBizarrement, je ne trouve pas la recette du livre…".rouge
    end
  end


  def self.templates_folder
    @templates_folder ||= File.join(APP_FOLDER,'resources','templates')
  end

  #
  # --- PAR ASSISTANT ---
  # 
  # Assistant qui permet de définir la recette du livre ou de la
  # collection
  # 
  def self.assistant_recipe(cdata = nil, force = false)

    clear

    # Avertissement préliminaire
    puts "Attention, cet assistant n'est pas à jour, des informations
    importantes ne sont pas prises en comptes. Utiliser plutôt les 
    modèles.".bleu
    sleep 5

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
    # 
    cdata.delete(:instance_collection)

    #
    # On ajout des propriétés qui devront être définies de façon
    # plus complexe
    # 
    cdata.merge!(
      header: {
        from_page: 10, to_page: 200,
        disposition: '| -%titre1- |',
        style: {font: "ArialNarrow", size:8, style: :bold}
      },
      footer: {
        from_page: 1, to_page: 220,
        disposition: '| | -%num',
        style: {font:'ArialNarrow', size:9}
      },
      titles: {
        level1: { font: 'Nunito', size: 30 },
        level2: { font: 'Nunito', size: 26 },
        level3: { font: 'Nunito', size: 20 },
        level4: { font: 'Nunito', size: 16 },
      }

    )

    # puts cdata.inspect

    # 
    # L'instance du book
    # 
    book = PdfBook.new(cdata[:main_folder])

    # 
    # On crée le fichier de recette du livre
    # 
    book.create_recipe(cdata)

    puts "(jouer '#{COMMAND_NAME} open recipe' pour ouvrir le fichier recette du livre et régler d'autres valeurs comme le pied de page ou les titres)".gris
    puts "(jouer '#{COMMAND_NAME} manuel' pour ouvrir le manuel de l'application et voir notamment comment définir l'entête et le pied de page.)".gris
    puts "\n\n"
  end


  # ---- MÉTHODES GÉNÉRIQUES ----

  def self.is_defined_or_define(prop, cdata)
    if not(cdata.key?(prop)) || cdata[prop] === nil
      return send("define_#{prop}".to_sym, cdata)
    else
      return true
    end
  end

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
      if cdata[:instance_collection] && cdata[:instance_collection].dimensions
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
      if cdata[:instance_collection] && cdata[:instance_collection].marges
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
        require_module('assistant')
        Prawn4book.get_name_fonts(cdata)
      end
    cdata.merge!(fonts: fonts)
  end

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
  {name: 'Numéro de paragraphes'                  , value: 'num_parags'     },
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

  def self.cfolder
    @@cfolder ||= File.expand_path('.')
  end


  # --- INSTANCE ---

  def create_recipe(data)

    # puts "data = #{data.pretty_inspect}"

    # 
    # Création du dossier
    # 
    @folder = File.join(data[:main_folder])
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

DEFINE_RECIPE_WAYS = [
  {name:'En copiant un modèle de recette dans le dossier', value: :template},
  {name:'Avec un assistant pour définir la recette', value: :assistant},
  {name:'Renoncer', value: nil}
]

TYPE_INITIED = [
  {name:'Un livre',       value: :book}, 
  {name:'Une collection', value: :collection},
  {name:'Renoncer',       value: nil}
]

ACTIONS_ON_COLLECTION_EXIST = [
  {name:'Le garder (en faire une copie)', value: :keep},
  {name:'Le détruire définitivement',     value: :destroy},
  {name:'Renoncer',                       value: :cancel}
]

end #/class PdfBook
end #/module Prawn4book
