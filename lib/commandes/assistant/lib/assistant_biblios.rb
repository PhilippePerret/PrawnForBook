module Prawn4book
  
  # --- Assistant pour les bibliographies ---

  def self.assistant_biblios(pdfbook)
    clear 

    puts MESSAGES[:biblio][:intro_assistant].bleu

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

end #/Prawn4book
