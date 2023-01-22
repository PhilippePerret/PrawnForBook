=begin

  Nouveaux principes pour la version 2

    * la hiérarchie a changé, on a maintenant
      - les dispositions qui définissent leur nom, leurs pages et
        l'enête et le pied de page qu'elles utilisent.
    * les entête et les pieds de page sont définis indépendamment,
      pour pouvoir utiliser n'importe lequel avec n'importe quelle
      disposition et même plusieurs dispositions. Ils s'appellent
      des "HEADFOOTERS"
    * on peut utiliser indifféremment un entête pour l'entête ou un
      pied de page et inversement.

=end
require 'lib/modules/tty_facilitators'
module Prawn4book
class Assistant

  # --- Assistant pour les bibliographies ---

  def self.assistant_headers_footers(owner)
    AssistantHeadersFooters::new(owner).define_dispositions
  end


class AssistantHeadersFooters
  include TTYFacilitators

  attr_reader :owner
  def initialize(owner)
    @owner = owner
  end

  def save
    new_data = {
      dispositions: data_dispositions,
      headfooters:  data_headfooters
    }
    puts "Nouvelles données enregistrées : #{new_data.inspect}"
    owner.recipe.insert_bloc_data('headers_footers', **new_data)
  end

  def data_dispositions
    @data_dispositions ||= hfs_data[:dispositions]||{}
  end
  def data_headfooters
    @data_headfooters ||= hfs_data[:headfooters]||{}
  end
  def hfs_data
    @hfs_data ||= owner.recipe.headers_footers || {}
  end

  ##
  # Méthode principale pour définir les entêtes et pieds de pages
  # 
  # Le choix se fait hiérarchiquement :
  #   - on affiche d'abord la liste des dispositions déjà 
  #     enregistrées s'il y en a.
  # 
  def define_dispositions
    msg = nil
    while true
      clear unless debug?
      # 
      # Si un message est à écrire
      # 
      puts msg unless msg.nil?
      # 
      # Les menus
      # 
      choices = choices_for_dispositions
      # 
      # Pour choisir la disposition à créer ou à éditer
      # 
      case (foo = Q.select(nil, choices, {per_page:choices.count, show_help:false, echo:false}))
      when :finir then break
      when :new   then edit_disposition(nil)
      else             edit_disposition(foo)
      end
    end #/boucle jusqu'à fin
  end

  # @return [Array<Hash>] Les tty-choices pour le menu principal
  # 
  def choices_for_dispositions
    data_dispositions.map do |dispo_id, data_dispo|
      {name: data_dispo[:name], value: data_dispo}
    end + [
      {name: PROMPTS[:headfoot][:new_dispo].bleu, value: :new},
      CHOIX_FINIR
    ]
  end

  ##
  # Méthode principale pour définir ou éditer une disposition
  # 
  def edit_disposition(data_dispo)
    # 
    # Pour savoir s'il s'agit d'une nouvelle disposition
    # 
    is_new_dispo = data_dispo.nil?
    data_dispo = {} if data_dispo.nil?
    # 
    # On utilise le facilitateur
    # 
    if tty_define_object_with_data(DATA_DISPOSITION, data_dispo)
      # 
      # En cas de nouvelle disposition, on lui donne un identifiant
      # 
      if is_new_dispo
        data_dispo.merge!(id: "DP#{Time.now.to_i}") 
        #
        # On mémorise cette disposition
        # 
        @data_dispositions.merge!(data_dispo[:id] => data_dispo)
      end
      # 
      # On enregistre les nouvelles données
      # 
      save
    end
  end

#############       MÉTHODES POUR TTY-FACILITATOR      #############
  
  ##
  # 2 méthode appelées lorsqu'on choisir "Entête" ou "Pied de page"
  # pour la disposition choisie, afin, soit de choisir un header ou
  # un footer (plus exactement : un headfooter pour le pied de page
  # ou un headfooter pour l'entête), soit d'éditer l'header ou le
  # footer déjà défini
  # 
  def choose_or_edit_header(dispo_data)
    choose_or_edit_headfooter(:header_id, dispo_data)
  end
  def choose_or_edit_footer(dispo_data)
    choose_or_edit_headfooter(:footer_id, dispo_data)
  end

  def choose_or_edit_headfooter(section_type, dispo_data)
    thing = section_type == :footer_id ? 'le pied de page' : 'l’entête'
    section_id = dispo_data[section_type]
    if section_id
      case Q.select("Que voulez-vous faire ?".jaune) do |q|
          q.choice "Éditer #{thing} <<#{section_id}>>", :edit
          q.choice "Choisir un autre headfooter", :choose
          q.choice "Ne rien changer", :noop
        end
      when :noop    then section_id
      when :choose  then choose_headfoot_id(dispo_data) || section_id
      when :edit
        data_headfooter = data_headfooters[section_id.to_s]||data_headfooters[section_id.to_sym]
        data_headfooter || raise("Désolé, mais il est impossible de trouver les données du headfooter #{section_id.inspect}…")
        edit_headfoot(data_headfooter)
      end
    else
      choose_headfoot_id(dispo_data)
    end
  end

  ##
  # Méthode pour pouvoir choisir ou définir un headfoot
  # 
  # @param [Hash] dispo_data Les données de la disposition qui veut
  #     se choisir un headfoot (donc pour son header ou son footer)
  # 
  # @return [String] Identifiant du headfoot choisi
  # 
  def choose_headfoot_id(dispo_data)
    # 
    # Liste des headfoots + bouton pour en créer un nouveau
    # 
    choices = data_headfooters.map do |hf_id, hf_data|
      {name: hf_data[:name], value: hf_id}
    end + [
      CHOIX_NEW, CHOIX_CANCEL.merge(value: nil)
    ]
    # 
    # Permettre à l'utilisateur d'en choisir un
    # 
    case (choix = Q.select(PROMPTS[:headfoot][:headfoot_to_choose].jaune, choices, {per_page:choices.count, show_help:false, echo:false}))
    when :new   then edit_headfoot(nil)
    else return choix # identifiant du headfoot ou nil
    end
  end

  ##
  # Pour éditer un head-foot
  # 
  def edit_headfoot(hf_data)
    # 
    # Pour savoir s'il s'agit d'un nouvel headfoot
    # 
    is_new = hf_data.nil?
    hf_data = {} if is_new
    # 
    # On utilise le facilitateur
    # 
    if tty_define_object_with_data(DATA_HEADFOOT, hf_data)
      # 
      # ID si nouveau
      # 
      if is_new
        hf_data.merge!(id: "HF#{Time.now.to_i}")
        @data_headfooters.merge!(hf_data[:id] => hf_data)
      end
      # 
      # Enregistrer la nouvelle donnée
      # 
      save
      return hf_data[:id]
    else
      return nil
    end
  end

  ##
  # Pour choisir l'élément à placer dans l'head-foot, le numéro de
  # page ou le titre, la casse, 
  # Optionnellement : la police, la taille, le style, 
  # 
  # @note
  #   On n'utilise pas le facilitateur car la donnée est complexe
  #   et multiple.
  # 
  # @param [Hash] hf_data Les données complète du headfooter
  # @param [Symbol] page_tiers Le "page-tiers", par exemple :pg_left pour
  #     le tiers gauche de la page gauche (paire)
  # 
  def define_tiers_of_headfoot(hf_data, page_tiers)
    data_tiers = hf_data[page_tiers] || {}
    if tty_define_object_with_data(DATA_HEADFOOT_TIERS, data_tiers)
      hf_data.merge!(page_tiers => data_tiers)
      save
      return data_tiers
    else
      return nil
    end
  end

  ##
  # Pour choisir le contenu d'un tiers
  # 
  def choose_contenu_for_tiers(dd)
    while true
      cont = Q.select("Type de contenu : ".jaune, VALUES_NIVEAU_TITRE_OU_NUM_PAGE, **{per_page: VALUES_NIVEAU_TITRE_OU_NUM_PAGE.count, show_help: false})
      case cont
      when :texte_fixe
        return Q.ask("Contenu textuel fixe à écrire : ".jaune)
      else
        return cont
      end
    end  
  end

  ##
  # Retourne les polices pour un menu facilitator
  # 
  def police_names
    owner.recipe.fonts_data.keys + DEFAUT_FONTS.keys
  end

  def police_names_or_default
    [{name:'Par défaut', value: :default}] + police_names
  end

  def font_sizes_or_default
    [{name:'Par défaut', value: :default}] + (7..20).map do |n|
      {name: "#{n}pt", value: n}
    end   
  end

  def font_styles_or_default
    [{name:'Par défaut', value: :default}] + DATA_STYLES_FONTS
  end

#
# Données pour les DISPOSITIONS
# 
# Les "dispositions" définissent les entêtes et pieds de pages à 
# utiliser sur un rang de pages données.
# 
DATA_DISPOSITION = [
  {name: 'Titre pour mémoire', value: :name, required: true},
  {name: 'De la page' , value: :first_page, type: :int},
  {name: 'À la page'  , value: :last_page, type: :int},
  {name: 'Header'     , value: :header_id, type: :custom, meth: :choose_or_edit_header},
  {name: 'Footer'     , value: :footer_id, type: :custom, meth: :choose_or_edit_footer},
  {name: 'Header V-Ajustement', value: :header_vadjust, type: :int, default: 0, values:(-20..20)},
  {name: 'Footer V-Ajustement', value: :footer_vadjust, type: :int, default: 0, values:(-20..20)},
]


CHOIX_ALIGN_CONTENU_HEADFOOT = [
  {name: 'Aligné à gauche' , value: :left},
  {name: 'Aligné à droite' , value: :right},
  {name: 'Centré' , value: :center},
]

CHOIX_CASSE_TITRE = [
  {name:'Ne pas modifier' , value: :keep},
  {name:'Tout majuscule'  , value: :all_caps},
  {name:'Comme un titre'  , value: :title},
  {name:'Tout minuscule'  , value: :min}
]

VALUES_NIVEAU_TITRE_OU_NUM_PAGE = [
  {name:"Aucun"         , value: :none},
  {name:"Numérotation"  , value: :numero},
]
(1..3).each do |n|
  VALUES_NIVEAU_TITRE_OU_NUM_PAGE << {name:"Titre de niveau #{n}", value: "titre#{n}".to_sym}
end
VALUES_NIVEAU_TITRE_OU_NUM_PAGE << {name:'Texte fixe', value: :custom_text}


DATA_HEADFOOT = [
  {name: 'Nom du "headfoot"'    , value: :name, required: true},
  {name: 'Police'               , value: :font        , values: :police_names},
  {name: 'Taille'               , value: :size        , type: :int, default: 11, values: (7..30)},
  {name: 'Style'                , value: :style       , type: :sym, values: DATA_STYLES_FONTS, default: 2},
  {name: 'Page G | x |   |   |' , value: :pg_left     , type: :custom, meth: :define_tiers_of_headfoot },
  {name: '       |   | x |   |' , value: :pg_center   , type: :custom, meth: :define_tiers_of_headfoot },
  {name: '       |   |   | x |' , value: :pg_right    , type: :custom, meth: :define_tiers_of_headfoot },
  {name: 'Page D | x |   |   |' , value: :pd_left     , type: :custom, meth: :define_tiers_of_headfoot },
  {name: '       |   | x |   |' , value: :pd_center   , type: :custom, meth: :define_tiers_of_headfoot },
  {name: '       |   |   | x |' , value: :pd_right    , type: :custom, meth: :define_tiers_of_headfoot },
]

DATA_HEADFOOT_TIERS = [
  {name: 'Contenu'    , value: :content , type: :custom, meth: :choose_contenu_for_tiers},
  {name: 'Alignement' , value: :align   , values: CHOIX_ALIGN_CONTENU_HEADFOOT},
  {name: 'Casse'      , value: :casse   , values: CHOIX_CASSE_TITRE, default: 1},
  {name: 'Police'     , value: :font    , default: nil, values: :police_names_or_default},
  {name: 'Taille'     , value: :size    , default: nil, values: :font_sizes_or_default},
  {name: 'Style'      , value: :style   , default: nil, values: :font_styles_or_default},
]
end #/class AssistantHeadersFooters
end #/class Assistant
end #/module Prawn4book
