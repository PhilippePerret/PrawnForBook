module Prawn4book
class Assistant

  # --- Assistant pour les bibliographies ---

  def self.assistant_biblios(owner)
    new(owner).define_biblios
  end

  attr_reader :owner
  def initialize(owner)
    @owner = owner
  end

  ##
  # Méthode principale pour définir les données bibliographiques
  # (en fait, les bibliographies)
  # 
  def define_biblios
    # 
    # Un message de présentation pour rappeler ce qu'est une 
    # bibliographie dans Prawn-for-book
    # 
    puts MESSAGES[:biblio][:intro_assistant].bleu
    # 
    # Pour savoir s'il y a eu des modifications
    # 
    has_changements = false
    # 
    # Boucle tant qu'on veut définir les données
    # 
    while true
      clear unless debug?
      # 
      # Les choix
      #
      choices = choices_biblios(has_changements)
      # 
      # Un menu contenant les bibliographies déjà définies ainsi qu'un
      # bouton pour en créer une nouvelle
      # 
      case (bib_id = Q.select("#{PROMPTS[:Edit]} : ".jaune, choices, {per_page:choices.count, show_help: false}))
      when :finir
        if has_changements
          no = Q.no?("Voulez-vous perdre vraiment tous les changements ?".jaune)
          break unless no
        else
          break
        end
      when :save
        # Enregistrer les données
        owner.recipe.insert_bloc_data('biblios', biblios_data)
        break
      when :new
        # Pour créer une nouvelle bibliographie
        has_changements = true if edit_biblio(nil)
      else
        # Pour éditer une bibliographie
        has_changements = true if edit_biblio(biblios_data[bib_id])
      end
    end
    clear unless debug?
  end

  ##
  # Méthode principale pour éditer une bibliographie, ou la
  # créer si c'est nécessaire.
  # 
  # @return [Boolean] true si tout s'est bien passé
  # 
  def edit_biblio(data_biblio)
    is_new_biblio = data_biblio.nil?
    data_biblio ||= {}
    erreur = nil
    while true
      clear unless debug?
      # 
      # S'il y a une erreur à afficher
      # 
      puts "\n  #{erreur}\n".rouge unless erreur.nil?
      # 
      # Les choix
      # 
      default_index = nil
      choices = [{name:PROMPTS[:save].bleu, value: :save}
      ] + DATA_BIBLIO.map.with_index do |dchoix, idx|
        prop  = dchoix[:value]
        value = data_biblio[prop]
        color_meth = value.nil? ? :blanc : :vert
        default_index = idx + 2 if default_index.nil? && value.nil?
        {name: "#{dchoix[:name]} : #{value || '---'}".send(color_meth), value: prop}
      end + [
        {name:PROMPTS[:end_without_save].rouge, value: :cancel}
      ]
      # 
      # Pour choisir la propriété à définir
      # 
      case (prop = Q.select(nil, choices, {per_page: choices.count, default: default_index, show_help:false, echo: false}))
      when :save
        erreur = tag_valid?(data_biblio[:tag], is_new_biblio)
        break if erreur.nil?
      when :cancel  then return false # annuler les changements
      else 
        erreur = edit_property(prop, data_biblio, is_new_biblio)
      end
    end #/fin de boucle
    if is_new_biblio
      @biblios_data.merge!(data_biblio[:tag] => data_biblio)
    end
    return true
  end

DATA_BIBLIO = [
  {name: 'Titre (tel qu’affiché dans le livre)' , value: :title},
  {name: "ID (aka \"tag\", au singulier)"       , value: :tag, type: :sym},
  {name: "Niveau de titre"                      , value: :title_level, type: :int},
  {name: "Bibliographie sur nouvelle page ?"    , value: :new_page, type: :bool},
  {name: 'Accès aux données (si autre que ./biblios/<tag>)', value: :data}
]
TABLE_VALUE_TO_CHOIX = {}
DATA_BIBLIO.each do |dchoix|
  TABLE_VALUE_TO_CHOIX.merge!(dchoix[:value] => dchoix)
end

  def edit_property(prop, data_biblio, is_new)
    data_choix = TABLE_VALUE_TO_CHOIX[prop]
    value = case data_choix[:type]
      when :bool
        Q.yes?(data_choix[:name].jaune)
      else
        value = Q.ask(data_choix[:name].jaune)
      end
    case data_choix[:type]
    when :int then value = value.to_i
    when :sym then value = value.to_sym
    end
    erreur = nil
    if prop == :tag
      erreur = tag_valid?(value, is_new)
    end
    data_biblio.merge!(prop => value) if erreur.nil?
    return erreur
  end

  def tag_valid?(tag, is_new)
    # 
    # Ce tag doit être unique
    # 
    if is_new 
      raise ERRORS[:biblio][:tag_already_exists] if biblios_data.key?(tag)
    end
    tag.to_s.gsub(/[a-z]/,'') == '' || raise(ERRORS[:biblio][:bad_tag])
    if tag.to_s[-1] == 's'
      puts "Ce tag finit par 's'. En général, les tags sont au singulier.\nMais si vous êtes sûr de vous, pas de problème.".orange
      sleep 5
    end
  rescue Exception => e
    return e.message
  else
    return nil # OK
  end

  def choices_biblios(has_changements)
    pre_menus = []
    pre_menus << {name:PROMPTS[:save].bleu, value: :save} if has_changements
    pre_menus << {name:PROMPTS[:biblio][:new_one].bleu, value: :new}
    pre_menus + 
    biblios_data.map do |biblio_id, biblio_data|
      {name: biblio_data[:title].upcase, value: biblio_id}
    end + [
      {name:PROMPTS[:finir].bleu, value: :finir}
    ]
  end

  # @return [Hash<Hash>] Table des bibliographies définies
  def biblios_data
    @biblios_data ||= owner.recipe.biblios_data
  end

  def self.old_assistant

    # 
    # Table des identifiants de bibliographie et table des titres de
    # bibliographie, pour vérifier de ne pas en créer deux identiques
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
      puts (MESSAGES[:biblio][:has_already_biblio] % bibs).bleu
      Q.yes?(PROMPTS[:devons_nous_en_creer_dautres].jaune) || return
    end

    puts "\n\n"

    dbiblios = define_bibliographies(
      pdfbook, 
      dbiblios, 
      {already_titles: already_titles, already_tags: already_tags}
    )
    
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
    clear
    bibun = new_tags.first # pour les exemples ci-dessous
    puts MESSAGES[:biblio][:bibs_created_with_success].vert
    method_list = new_tags.map {|t| "\t- biblio_#{t}" }.join("\n")
    puts (MESSAGES[:biblio][:explaination_after_create] % [method_list,bibun,bibun]).bleu

  end

  ##
  # Pour définir les bibliographies
  # 
  # @param pdfbook  {PdfBook} Instance du livre à construire
  # @param dbiblios {Array} Liste actuelles des bibliographies
  #                 Liste vide par défaut.
  # @param options  {Hash} Options, comme par exemple les titres ou
  #                 les biblio-tags qui existent déjà.
  #                 Table vide par défaut.
  # 
  # @return {Hash} dbiblios avec les nouvelles bibliographies
  # 
  # Note :  c'est méthode est faite pour être appelée de l'extérieur,
  #         par exemple lorsque l'on init un nouveau livre.
  # 
  def self.define_bibliographies(pdfbook, dbiblios = nil, options = nil)
    options   ||= {}
    dbiblios  ||= []

    already_titles  = options[:already_titles]  || {}
    already_tags    = options[:already_tags]    || {}

    new_tags = [] # pour les messages finaux

    # Tant qu'on veut introduire des bibliographies
    while true
      # Tant qu'on n'a pas défini cette bibliographie
      dbiblio = {}
      while true
        # 
        # Le titre de la bibliographie
        # 
        while dbiblio[:title].nil?
          btitre = Q.ask(PROMPTS[:biblio][:title_of_new_biblio].jaune).to_s.strip
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
          btag = Q.ask(PROMPTS[:biblio][:tag_uniq_and_simple_minuscules].jaune).to_s.strip
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
      puts MESSAGES[:biblio][:consigned].vert
      
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

    # return dbiblios
  end #/define_bibliographies


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
  {name:PROMPTS[:By_default]  , value: :default},
  {name:PROMPTS[:Customised]  , value: :custom},
  {name:PROMPTS[:i_dont_know] , value:  nil}
]

end #/class Assistant
end #/module Prawn4book
