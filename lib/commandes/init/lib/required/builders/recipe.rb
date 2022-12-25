module Prawn4book
class InitedThing

  require 'lib/required/utils'
  include UtilsMethods

  attr_reader :template_data

  # Création de la recette (livre ou collection)
  # 
  # @return true en cas de succès, false otherwise
  # 
  def proceed_build_recipe

    if book? && in_collection?
      puts PROMPTS[:recipe][:warning_book_in_collection].jaune
    end

    #
    # Que faut-il faire si un fichier recette existe déjà ?
    # 
    case keep_recipe_file_if_exist?
    when :keep    then return true
    when :cancel  then return false
    else
      # on continue
    end

    #
    # Demander les informations minimale
    # 
    get_template_data || return
    # puts "@template_data = #{@template_data.pretty_inspect}"

    #
    # Assembler le fichier recette 
    #
    assemble_recipe

    #
    # Image de logo
    # Si elle est définie, mais qu'elle n'existe pas, on utilise
    # le logo type (dans ressources/templates/logo.jpg) qu'on met
    # à l'endroit voulu avec le nom voulu
    # 
    traite_logo

    #
    # Confirmation création
    # 
    return confirm_create_recipe
  end

  ##
  # Méthode pour demander toutes les informations que l'utilisateur
  # veut entrer.
  # 
  def get_template_data
    @template_data = {}
    @template_data.merge!(main_folder: folder)
    clear unless debug?
    @template_data.merge!(ask_for_or_default(DATA_VALUES_MINIMALES))
    puts PROMPTS[:recipe][:init_intro_define_values].bleu
    askit = Q.yes?(PROMPTS[:recipe][:wannado_define_all_values].jaune)

    clear unless debug?

    # 
    # Toutes les choses à pouvoir définir
    # Chaque fois qu'un élément est défini, on l'exclut de
    # la liste
    # 
    data2define = [
      :publisher, :format, :wanted_pages, :infos, :options,
      :fontes, :titles, :headers_and_footers, :biblios
    ]

    if askit
      # 
      # On boucle sur toutes les choses à pouvoir définir
      # 
      while data2define.any?
        clear unless debug?
        case (choix = Q.select(PROMPTS[:recipe][:which_data_recipe_to_define].jaune, CHOIX_DATA2DEFINE, per_page:CHOIX_DATA2DEFINE.count))
        when :finir then break
        else
          meth = "get_values_for_#{choix}".to_sym
          if send(meth, true) # true ≠ par défaut
            # 
            # Les valeurs ont été données, on peut retirer cet
            # élément de la liste des valeurs à définir et empêcher
            # ce menu de pouvoir être rechoisi (surtout pour marquer
            # ce qui est fait)
            # 
            data2define.delete(choix)
            idx = DATA2DEFINE_VALUE_TO_INDEX[choix]
            CHOIX_DATA2DEFINE[idx].merge!(disabled: '(OK)')
          end
        end

      end #/while data2define.any?
    
    end # S'il fallait définir les valeurs tout de suite

    # 
    # AUTRES VALEURS -> PAR DÉFAUT
    # ----------------------------
    # 
    # On a fini de définir les valeurs choisie
    # Il faut définir les valeurs qui restent en mettant leur
    # valeur par défaut
    # 
    data2define.each do |kwhat|
      puts (MESSAGES[:define_default_values_for] % kwhat.to_s).bleu
      meth = "get_values_for_#{kwhat}".to_sym
      send(meth, false)
    end

    #
    # La première font, qui servira de font par défaut
    # 
    @template_data.merge!(first_font_name: (@data_fontes ? @data_fontes.keys.first : 'Arial' ))

    return true
  end

  ##
  # Traitement du logo
  # 
  def traite_logo
    if @template_data[:publisher_logo]
      logo_path = File.join(folder, @template_data[:publisher_logo])
      if not File.exist?(logo_path)
        mkdir(File.dirname(logo_path))
        FileUtils.cp( File.join(Prawn4book::templates_folder,'logo.jpg') , logo_path)
      end
    else
      puts "Le logo n'est pas défini".jaune
      sleep 5
    end
  end


  ##
  # Méthode qui construit le code final de la recette
  # et l'inscrit dans le fichier
  # 
  # (en remplaçant les données par celles fournies ou les données
  #  par défaut)
  # 
  def assemble_recipe
    code_final = assemble_code
    File.open(recipe_path,'wb') { |f| f.puts code_final }
  end

  ##
  # Assemblage du code pour former le code complet
  # 
  # Sont nécessaires pour cette opération :
  #   @template_data (pour remplacer les %{...})
  #   @titles_data    : pour mettre dans <titles>.
  # 
  def assemble_code
    # Copie du code propre au livre ou à la collection 
    code = File.read(template_for(recipe_name))
    # 
    # On remplace les variables %{…}
    # 
    code = code % template_data
    # 
    # Ajout du code commun (sauf si c'est un livre dans un collection)
    # 
    if not(in_collection?)
      ccommun = File.read(template_for('recipe_communs.yaml'))
      code = code + (ccommun % template_data)
      # 
      # Si les titres sont redéfinis
      # 
      if @data_titles
        code = remplace_between_balises_with(code, 'titles', {titles: @data_titles}.to_yaml)
      end
      #
      # Si les fontes sont définies
      # 
      if @data_fontes
        code = remplace_between_balises_with(code,'fontes', {fonts: @data_fontes}.to_yaml)
      end
      # 
      # Si les bibliographies sont définies
      # 
      if @data_biblio
        code = remplace_between_balises_with(code,'biblios', {biblios: @data_biblio}.to_yaml)      
      end
      # 
      # Si les headers et footers sont définis, on les
      # inscrit
      # 
      if @data_headers_footers
        code = remplace_between_balises_with(code,'headers', @data_headers_footers[:headers].to_yaml)
        code = remplace_between_balises_with(code,'footers', @data_headers_footers[:footers].to_yaml)
      end
    end

    return code
  end


  # --- Les méthodes plus complexes ---
  def get_values_for_biblios(askit)
    return unless askit
    require "#{COMMANDS_FOLDER}/assistant/lib/assistant_biblios"
    @data_biblio = Prawn4book.define_bibliographies(pdfbook)
    return true
  end

  def get_values_for_fontes(askit)
    return unless askit
    require "#{COMMANDS_FOLDER}/assistant/lib/assistant_fontes"
    @data_fontes = Prawn4book.get_name_fonts(main_folder: folder)
    return true
  end

  def get_values_for_headers_and_footers(askit)
    return unless askit
    require "#{COMMANDS_FOLDER}/assistant/lib/assistant_headers_footers"
    @data_headers_footers = Prawn4book.define_headers_footers
    return true
  end

  def get_values_for_titles(askit)
    return unless askit
    Q.yes?(PROMPTS[:recipe][:wannado_define_titles].jaune) || return
    # Note : on doit supprimer de '# <titles>' à </titles> dans le
    # template recette et le remplacer par le code
    level = 1
    @data_titles = {}
    while level < 7
      @data_titles.merge!( level => {level: level} )
      belle_page = Q.no?("Faut-il mettre le titre de niveau #{level} sur une belle page (droite) ?".jaune)
      if belle_page
        next_page = false
      else
        next_page = Q.yes?("Faut-il passer à la page suivante pour le titre de niveau #{level} ?".jaune)
      end
      @data_titles[level].merge!(
        next_page: next_page, belle_page: belle_page
      )
      TITLES_DATAS.each do |question, property, default|
        question  = question % @data_titles[level]
        default   = default.call(level) if default.is_a?(Proc)
        reponse   = Q.ask(question.jaune, default: default)
        reponse   = reponse.to_i unless property == :font
        @data_titles[level].merge!(property => reponse)
      end
      level += 1
      break if level > 6
      Q.yes?("Faut-il régler le titre de niveau #{level} ?".jaune) || break
    end
    # 
    # Mettre les valeurs restantes par défaut
    # 
    while level < 7
      @data_titles.merge!( level => {belle_page:false, next_page: false})
      TITLES_DATAS.each do |question, property, default|
        default = default.call(level) if default.is_a?(Proc)
        @data_titles[level].merge!(property => default)
      end
      level += 1
    end
    return true
  end

  # --- Toutes les méthodes pour demander les informations
  #     de la recette ---

  def get_values_for_publisher(askit)
    get_values_for(askit, RECIPE_VALUES_FOR_PUBLISHER)
  end
  def get_values_for_format(askit)
    get_values_for(askit, RECIPE_VALUES_FOR_FORMAT)
  end
  def get_values_for_wanted_pages(askit)
    get_values_for(askit, RECIPE_VALUES_FOR_WANTED_PAGES)
  end
  def get_values_for_infos(askit)
    get_values_for(askit, RECIPE_VALUES_FOR_INFOS)
  end
  def get_values_for_options(askit)
    get_values_for(askit, RECIPE_VALUES_FOR_OPTIONS)
  end

  # --- Generic Methods ---


  ##
  # Méthode générique pour demander les valeurs définies par 
  # +data_values+ et les mettre dans @template_data
  # Si +question+ est nil, ce sont les valeurs par défaut qui seront
  # mise dans la table.
  def get_values_for(askit, data_values)
    if askit
      # Mode interactif
      @template_data.merge!(ask_for_or_default(data_values))
    else
      # Valeurs par défaut
      data_values.each do |dvalue|
        @template_data.merge!(dvalue[:k] => dvalue[:df])
      end
    end
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
    return nil unless File.exist?(recipe_path)
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
