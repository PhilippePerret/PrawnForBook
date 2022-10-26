module Prawn4book
class InitedThing

  attr_reader :template_data

  # Création de la recette (livre ou collection)
  # 
  # @return true en cas de succès, false otherwise
  # 
  def proceed_build_recipe

    if book? && in_collection?
      puts "
      Ce livre est dans une collection. Je ne dois mettre dans sa 
      recette que les propriétés propre à un livre.
      ".jaune
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
    puts "@template_data = #{@template_data.pretty_inspect}"

    #
    # Assembler le fichier recette 
    #
    assemble_recipe

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
    @template_data.merge!(ask_for_or_default(DATA_VALUES_MINIMALES))
    puts "
    (si vous ne définissez pas certaines valeurs maintenant, il 
     faudra le faire « à la main » dans le fichier recette
     directement, plus tard)
    ".bleu
    askit = Q.yes?("Voulez-vous définir tout de suite les autres valeurs ?".jaune)
    get_values_for_publisher(askit)
    get_values_for_format(askit)
    get_values_for_wanted_pages(askit)
    get_values_for_infos(askit) if book?
    get_values_for_options(askit)
    # 
    # Données plus complexes
    # 
    get_values_for_fontes
    get_values_for_titles
    get_values_for_headers_and_footers
    get_values_for_bibliographies
    return true
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
  #   @titles_data    : pour mettre dans <titles>..
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
        code = remplace_between_balises_with(code, 'titles', @data_titles.to_yaml)
      end
      #
      # Si les fontes sont définies
      # 
      if @data_fontes
        code = remplace_between_balises_with(code,'fontes', @data_fontes.to_yaml)
      end

    end

    return code
  end



  # --- Les méthodes plus complexes ---
  def get_values_for_bibliographies
    # Note : on doit supprimer de '# <biblio>' à </biblio> dans le
    # template recette et le remplacer par le code
  end

  def get_values_for_fontes
    Q.yes?(PROMPTS[:fonts][:wannado_choose_fonts].jaune) || return
    require "#{COMMANDS_FOLDER}/assistant/lib/assistant_fontes"
    @data_fontes = Prawn4book.get_name_fonts(main_folder: folder)
  end

  def get_values_for_headers_and_footers
    # Note : on doit supprimer de '# <headers>' à </headers> dans le
    # template recette et le remplacer par le code
    # Idem pour '# <footers>' et '</footers>'
    
  end

  def get_values_for_titles
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
  end

  # --- Toutes les méthodes pour demander les informations
  #     de la recette ---

  def get_values_for_publisher(askit)
    get_values_for(
      askit ? "Voulez-vous renseigner les données de l'éditeur ?" : nil, 
      RECIPE_VALUES_FOR_PUBLISHER
    )
  end
  def get_values_for_format(askit)
    get_values_for(
      askit ? "Voulez-vous renseigner les données de format (taille livre, marges, etc.) ?" : nil, 
      RECIPE_VALUES_FOR_FORMAT
    )
  end
  def get_values_for_wanted_pages(askit)
    get_values_for(
      askit ? "Voulez-vous définir les pages qui doivent être introduites ?" : nil,
      RECIPE_VALUES_FOR_WANTED_PAGES
    )
  end
  def get_values_for_infos(askit)
    get_values_for(
      askit ? "Voulez-vous définir les informations du livre (isbn, metteur en page, etc.) ?" : nil,
      RECIPE_VALUES_FOR_INFOS
    )
  end
  def get_values_for_options(askit)
    get_values_for(
      askit ? "Voulez-vous définir certaines options (pagination, etc.) ?" : nil,
      RECIPE_VALUES_FOR_OPTIONS
    )
  end

  # --- Generic Methods ---

  ##
  # Méthode générique permettant de remplacer du code entre balises
  # dans le fichier recette.
  # Explication : dans le fichier recette, les gros "blocs" comme la
  # définition des titres, les bibliographies ou les fontes sont 
  # délimitées par des balises du type '<fontes>....</fontes>' pour
  # pouvoir les modifier par l'assistant.
  # 
  def remplace_between_balises_with(str, tag_name, code)
    tag_in  = "# <#{tag_name}>"
    tag_out = "</#{tag_name}>"
    dec_in  = str.index(tag_in) || raise("La balise '# <titles>' est malheureusement introuvable.")
    dec_in += tag_in.length
    dec_out = str.index(tag_out) || raise("La balise '</titles>' est malheureusement introuvable.")
    dec_out -= 1
    code = str[0..dec_in] + code + str[dec_out..-1]    
  end

  ##
  # Méthode générique pour demander les valeurs définies par 
  # +data_values+ et les mettre dans @template_data
  # Si +question+ est nil, ce sont les valeurs par défaut qui seront
  # mise dans la table.
  def get_values_for(question, data_values)
    if question && Q.yes?(question.jaune)
      @template_data.merge!(ask_for_or_default(data_values))
    else
      # Valeurs par défaut
      data_values.each do |dvalue|
        @template_data.merge!(dvalue[:k] => dvalue[:df])
      end
    end
  end

  def ask_for_or_default(dvalues)
    tbl = {}
    dvalues.each do |dvalue|
      reponse = case dvalue[:t]
        when :text
          Q.multiline("#{dvalue[:q]} : ".jaune)
        when :yes
          Q.yes?(dvalue[:q].jaune, default: dvalue[:df])
        when :select
          Q.select("#{dvalue[:q]} : ".jaune, dvalue[:values], default: dvalue[:df])
        else
          Q.ask("#{dvalue[:q]} : ".jaune, default: dvalue[:df])
        end
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
