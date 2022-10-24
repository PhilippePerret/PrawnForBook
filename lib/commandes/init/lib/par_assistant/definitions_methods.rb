module Prawn4book
class PdfBook
class << self


  # ---- MÉTHODES DE DEMANDES DES DONNÉES ----


  # --- Méthode générique pour demander une propriété ---
  def ask_for(cdata, question, prop, vdefaut = nil, aide = nil)
    if aide
      question = question + "\n#{"(#{aide})".gris}"
    end
    cdata.merge!(prop => Q.ask(question.jaune, default:(vdefaut||cdata[prop])))
    return true
  end

  # --- Méthode générique pour demander un nombre ---
  def ask_for_number(question, min, max, default)
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


  # --- Toutes les méthodes de définition ---
  def define_book_title(cdata)
    ask_for(cdata, "Titre du livre", :book_title)
  end

  def define_book_id(cdata)
    vdefaut = cdata[:book_id] || cdata[:book_title].downcase.gsub(/ /,'_').gsub(/[^a-z_]/,'')
    ask_for(cdata, 'ID du livre', :book_id, vdefaut, 'servira pour plein de choses')
  end

  def define_auteurs(cdata)
    aide = 'sous forme "Prénom NOM, Prénom DE NOM, ..."'
    ask_for(cdata, 'Auteurs du livre', :auteurs, nil, aide)
    cdata[:auteurs] = cdata[:auteurs].split(',').map{|n|n.strip}
    return true
  end

  def define_main_folder(cdata)
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

  def define_text_path(cdata)
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

  def define_dimensions(cdata)
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

  def define_marges(cdata)
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

  def define_interligne(cdata)
    inter =
      if cdata[:instance_collection] && cdata[:instance_collection].interligne
        :collection
      else
        ask_for_number('Interligne', 0, 100, 1)
      end
    cdata.merge!(interligne: inter)
  end

  def define_opt_num_parag(cdata)
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
  def define_fonts(cdata)
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
  def define_num_page_style(cdata)
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
  def define_collection(cdata)
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

end #/<< self
end #/class PdfBook
end #/module Prawn4book
