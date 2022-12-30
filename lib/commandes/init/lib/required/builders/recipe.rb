module Prawn4book
class InitedThing

  require 'lib/required/utils'
  include UtilsMethods

  # = main =
  # 
  # CRÉATION DE LA RECETTE (livre ou collection)
  # 
  # @return true en cas de succès, false otherwise
  # 
  def build_recipe

    if book? && in_collection?
      puts PROMPTS[:recipe][:warning_book_in_collection].jaune
    end

    #
    # Que faut-il faire si un fichier recette existe déjà ?
    # 
    return unless keep_recipe_file_if_exist?

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
    } + [CHOIX_FINIR]

    while true
      clear unless debug?
      # 
      # On demande à l'utilisateur ce qu'il veut définir
      # 
      thing2define = Q.select(PROMPTS[:recipe][:which_data_recipe_to_define].jaune, choices, {per_page:choices.count})
      case thing2define
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
    data_titres = Prawn4book.define_titles(owner)
    owner.recipe.insert_bloc_data(:titles, {titles: data_titres})
    return true
  end

  def require_assistant(name)
    require "#{COMMANDS_FOLDER}/assistant/lib/assistant_#{name}"
  end

  # --- Les méthodes plus complexes ---
  def define_and_set_values_for_biblios(askit)
    return unless askit
    require "#{COMMANDS_FOLDER}/assistant/lib/assistant_biblios"
    @data_biblio = Prawn4book::Assistant.define_bibliographies(pdfbook)
    return true
  end


  def define_and_set_values_for_headers_and_footers(askit)
    return unless askit
    require "#{COMMANDS_FOLDER}/assistant/lib/assistant_headers_footers"
    @data_headers_footers = Prawn4book::Assistant.define_headers_footers
    return true
  end

  # --- Toutes les méthodes pour demander les informations
  #     de la recette ---

  ##
  # Pour définir les pages à afficher dans le livre
  # 
  PAGES = [
    {name:'Page de garde', value: :page_de_garde, default: true},
    {name:'Page de faux titre (seulement titre)', value: :faux_titre, default: false},
    {name:'Page de titre (titre avec auteurs et édition)', value: :page_de_titre, default: true},
    {name:'Page d’information (fin du livre)', value: :page_infos, default: true}
  ]
  def define_and_set_values_for_wanted_pages
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

  def keep_recipe_file_if_exist?
    return true unless File.exist?(recipe_path)
    File.ask_what_to_do_with_file(recipe_path, 'fichier recette')
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
