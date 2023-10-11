module Prawn4book
class InitedThing

  require 'lib/required/utils/methods'
  include UtilsMethods

  #
  # Les variables qu'on peut trouver dans les fichiers templates et
  # qu'on doit remplacer (en demandant si nécessaire leur valeur)
  # 
  BOOK_DATA = {
    book_title: {
      value: nil, hname: "#{TERMS[:Title]} #{TERMS[:book_data]}", type: String
    },
    book_author: {
      value: nil, hname: "#{TERMS[:Authors]} #{TERMS[:book_data]}", type: String
    },
    book_subtitle:{
      value:nil, hname: "#{TERMS[:Subtitle]} #{TERMS[:book_data]}", type:String
    },
    book_isbn: {
      value:nil, hname: "#{TERMS[:ISBN]} #{TERMS[:book_data]}", type:String, default:'null'
    },
    collection_name: {
      value: nil
    },
    collection_editor: {
      value: nil
    }
  }

  # 
  # Les data minimales quand on ne veut pas passer par les assistants
  # 
  DATA_MINI_COLLECTION = [
    {q:'Titre de la collection',  k: :collection_name,    t: :string, required: true},
    {q:'Directeur de collection', k: :collection_editor,  t: :string, required: true},
  ]

  DATA_MINI_BOOK = [
    {q: 'Titre du livre', k: :book_title,  t: :string, required: true},
    {q:'Auteur du livre', k: :book_author, t: :string, required: true},
  ]

  # = main =
  # 
  # CRÉATION DE LA RECETTE (livre ou collection)
  # 
  # @return true en cas de succès, false otherwise ou en cas de 
  # renoncement.
  # 
  def build_recipe
    if book? && in_collection?
      puts PROMPTS[:recipe][:warning_book_in_collection].jaune
    end

    #
    # Initialisation du fichier recette
    # 
    init_recipe_file || return

    #
    # Demander les informations sur le livre
    # 
    define_all_data || return

    #
    # Confirmation création
    # 
    return confirm_create_recipe
  end

  ##
  # Méthode pour demander toutes les informations que l'utilisateur
  # veut entrer.
  # 
  def define_all_data
    clear unless debug?

    # 
    # Préparation de la liste des choix
    # 
    @table_choix2index = {}
    choices = CHOIX_DATA2DEFINE.map.with_index { |dchoix, idx| 
      @table_choix2index.merge!(dchoix[:value] => idx)
      dchoix.merge(defined: false)
    }
    choices.unshift({name: Prawn4book::PROMPTS[:DefineLater].bleu , value: :later})
    choices.unshift(CHOIX_FINIR)
    choices.push(CHOIX_ABANDON)

    while true
      clear unless debug?
      # 
      # Titre de la page
      # 
      puts "\n  #{MESSAGES[:recipe][:title_data_to_define]}".bleu

      # 
      # On demande à l'utilisateur ce qu'il veut définir
      # 
      begin
        thing2define = Q.select(nil, choices, {per_page:choices.count, show_help:false, echo:false})
      rescue TTY::Reader::InputInterrupt
        return nil
      end
      case thing2define
      when :cancel
        # 
        # Pour renoncer à la suite
        # (mais noter que la recette aura pu être déjà enregistrée
        #  puisqu'elle l'est petit à petit)
        # 
        return false
      when :later
        #
        # L'utilisateur veut définir les valeurs plus tard. Il faut
        # quand même lui demander les données minimales pour faire
        # le fichier recette
        # 
        define_data_mini
        return true
      when :finir
        # 
        # Pour en finir avec la définition du livre/de la collection
        # @note
        #   Maintenant, la recette est enregistrée au fur et à mesure
        return true

      when :book_data, :book_format, :page_infos
        # 
        # Ici passent toutes les choses qu'on peut définir par le biais
        # du système des "pages spéciales"
        # 
        if edit_with_special_pages(thing2define)
          mark_choix_ok(thing2define, choices)
        end
      else
        # 
        # Ici passent toutes les choses définies par des méthodes
        # de ce fichier.
        # 
        if send(:"define_and_set_values_for_#{thing2define}")
          mark_choix_ok(thing2define, choices)
        end
      end
    end

    return true
  end

  ##
  # Pour indiquer que les données ont été fournies
  # 
  def mark_choix_ok(what, choices)
    dchoix = choices[@table_choix2index[what]]
    dchoix.merge!({
      defined: true,
      name: "#{dchoix[:name]} (OK)".vert
    })
  end
  
  ##
  # Pour éditer les données +balise+ avec le module des Pages Spéciales
  # 
  # @param [String|Symbol] balise La chose à éditer, par exemple :book_data ou :page_de_titre
  def edit_with_special_pages(balise)
    balise = balise.to_s
    require "lib/pages/#{balise}"
    klass = Prawn4book::Pages.const_get(balise.camelize)
    return klass.define(owner.folder)
  end

  # --- Méthodes de définition des données ---

  def define_and_set_values_for_fonts
    require_assistant('fontes')
    Prawn4book::Assistant.assistant_fontes(owner)
    return true
  end

  def define_and_set_values_for_titles
    require_assistant('titres')
    Prawn4book::Assistant.assistant_titres(owner)
  end

  # --- Les méthodes plus complexes ---

  def define_and_set_values_for_biblios
    require_assistant('biblios')
    Prawn4book::Assistant.assistant_biblios(owner)
  end

  def define_and_set_values_for_publisher
    require_assistant('publisher')
    Prawn4book::Assistant.assistant_publisher(owner)
  end

  def define_and_set_values_for_headers_and_footers
    require_assistant('headers_footers')
    Prawn4book::Assistant.assistant_headers_footers(owner)
  end

  def require_assistant(name)
    require "#{COMMANDS_FOLDER}/assistant/assistants/#{name}"
  end

  ##
  # Pour définir les pages à afficher dans le livre
  # 
  PAGES = [
    {name:'Page de garde', value: :page_de_garde, default: true},
    {name:'Page de faux titre (seulement titre)', value: :faux_titre, default: false},
    {name:'Page de titre (titre avec auteurs et édition)', value: :page_de_titre, default: true},
    {name:'Page d’information (fin du livre)', value: :page_infos, default: true}
  ]
  def define_and_set_values_for_inserted_pages
    cur_data = recipe.inserted_pages
    while true
      choices = PAGES.map.with_index do |dchoix, idx|
        dd = dchoix.dup
        curval = cur_data[dd[:value]]
        curval_real = curval.nil? ? dd[:default] : curval
        color_meth  = curval_real ? :bleu : :orange
        curval_str  = curval_real ? TERMS[:yes] : TERMS[:no]
        dd[:name]   = "#{dd[:name]} : #{curval_str}".send(color_meth)
        dd
      end.unshift({name: PROMPTS[:save].vert, value: :save})
      clear unless debug?
      puts "PAGES À INSÉRER DANS LE LIVRE".bleu
      type_page = Q.select(nil, choices, {per_page: choices.count, show_help:false})
      break if type_page == :save
      oui = Q.yes?("Afficher la page : #{type_page.to_s.gsub(/_/,' ')} ?".jaune)
      cur_data.merge!(type_page => oui)
    end
    # Enregistrement des informations
    recipe.insert_bloc_data('inserted_pages', cur_data)
  end


  def define_data_mini
    clear
    puts "Il nous faut quand même des informations minimales".bleu
    values = ask_for_or_default(book? ? DATA_MINI_BOOK : DATA_MINI_COLLECTION)
    values.merge!(app_data)
    values.merge!({
      main_folder: folder
    })
    template_path = File.join(Prawn4book::templates_folder, "recipe_#{'collection_' unless book?}mini.yaml") 
    File.write(recipe_path, File.read(template_path) % values)
    # 
    # On met les valeurs aussi dans BOOK_DATA, pour la suite
    # 
    [
      :book_title, :book_author, 
      :collection_name, :collection_editor,
    ].each do |key|
      BOOK_DATA[key][:value]  = values[key]
    end

  end

  # --- Generic Methods ---

  ##
  # @return [Recipe] La recette actuelle du livre
  def recipe
    owner.recipe
  end

  ##
  # Méthode générique pour demander les valeurs définies par 
  # +data_values+ et les mettre dans @template_data
  # Si +question+ est nil, ce sont les valeurs par défaut qui seront
  # mise dans la table.
  def define_and_set_values_for(data_values)
    @template_data.merge!(ask_for_or_default(data_values))
    return true
  end

  def ask_for_or_default(dvalues)
    tbl = {}
    dvalues.each do |dvalue|
      # 
      # On demande la valeur à l'utilisateur
      # 
      reponse = case dvalue[:t]
        when :text
          Q.multiline("#{dvalue[:q]} : ".jaune).join("\n")
        when :yes
          Q.yes?(dvalue[:q].jaune, default: dvalue[:df])
        when :select
          values = dvalue[:values]
          # 
          # Si une valeur par défaut est définie, il faut la chercher
          # 
          if dvalue[:df]
            default_value = nil
            values.each_with_index do |dval, idx|
              default_value = (idx + 1) and break if dval[:value] == dvalue[:df]
            end
          end
          Q.select("#{dvalue[:q]} : ".jaune, values, {per_page: values.count, default: default_value})
        else
          Q.ask("#{dvalue[:q]} : ".jaune, default: dvalue[:df])
        end
      # 
      # Y a-t-il une méthode de traitement de la donnée ?
      # 
      case dvalue[:treate_as]
      when :names_list 
        reponse = reponse.split(',').map{|e|e.strip}
      when :multiline_text
        indent = dvalue[:indent]||'  '
        # reponse = reponse.strip.split("\n").map{|e|e.strip}.join("\n#{indent}").gsub(/\n\n+/,"\n")
        reponse = reponse.strip.gsub(/\n\n+/,"\n").split("\n").map { |e| e.strip }.join("\n#{indent}")
      end

      # 
      # Consignation de la donnée
      # 
      tbl.merge!(dvalue[:k] => reponse)
    end
    return tbl
  end

  ##
  # Initialisation du fichier recette
  # @note
  #   S'il existe déjà (réinitialisation) on demande ce qu'il faut
  #   en faire.
  def init_recipe_file
    if File.exist?(recipe_path)
      reponse = File.ask_what_to_do_with_file(recipe_path, 'fichier recette')
      return false if reponse == false
    end
    unless File.exist?(recipe_path)
      File.write(recipe_path, app_data.to_yaml)
    end
    return true
  end

  def app_data
    @app_data ||= {
      app_name:     Prawn4book::NAME, 
      app_version:  Prawn4book::VERSION,
      created_at:   Time.now.strftime('%Y-%m-%d')
    }
  end

  def confirm_create_recipe
    if File.exist?(recipe_path)
      puts "Fichier recette créé avec succès.".vert
      return true
    else
      puts "Fichier recette introuvable, bizarrement…".rouge
      return false
    end
  end

  def recipe_path
    @recipe_path ||= File.join(folder,recipe_name)  
  end
end #/class InitedThing
end #/module Prawn4book
