=begin

  Nouveaux principes pour la version 2

    * la hiérarchie a changé, on a maintenant
      - les dispositions qui définissent leur nom, leurs pages et
        l'enête et le pied de page qu'elles utilisent.
    * les entête et les pieds de page sont définis indépendamment,
      pour pouvoir utiliser n'importe lequel avec n'importe quelle
      disposition et même plusieurs dispositions
    * on peut utiliser indifféremment un entête pour l'entête ou un
      pied de page et inversement.

  Comme les entête et pieds de paes sont interchangeables, ici, on 
  les appelle des HEADFOOTERS

=end
require 'lib/modules/tty_facilitators'
module Prawn4book
class Assistant

  # --- Assistant pour les bibliographies ---

  def self.assistant_headers_footers(owner)
    AssistantHeadersFooters::new(owner).define_headers_and_footers
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
    @hfs_data ||= owner.recipe.headers_footers_data
  end

  ##
  # Méthode principale pour définir les entêtes et pieds de pages
  # 
  # Le choix se fait hiérarchiquement :
  #   - on affiche d'abord la liste des dispositions déjà 
  #     enregistrées s'il y en a.
  # 
  def define_headers_and_footers
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
    tty_define_object_with_data(DATA_HEADFOOT, hf_data)
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
  end

#############       MÉTHODES POUR TTY-FACILITATOR      #############
  

  ##
  # Méthode pour pouvoir choisir ou définir un headfoot
  # 
  # @param [Hash] dispo_data Les données de la disposition qui veut
  #     se choisir un headfoot (donc pour son header ou son footer)
  # 
  # @return [String] Identifiant du headfoot choisi
  def choose_headfoot_id(dispo_data)
    # 
    # Liste des headfoots + bouton pour en créer un nouveau
    # 
    choices = data_headfooters.map do |hf_id, hf_data|
      {name: hf_data[:name], value: hf_id}
    end + [
      CHOIX_NEW
    ]
    # 
    # Permettre à l'utilisateur d'en choisir un
    # 
    case (choix = Q.select(PROMPTS[:headfoot][:headfoot_to_choose].jaune, choices, {per_page:choices.count, show_help:false, echo:false}))
    when :new   then edit_headfoot(nil)
    else return choix # identifiant du headfoot
    end
  end

  ##
  # Retourne les polices pour un menu facilitator
  # 
  def police_names
    owner.recipe.fonts_data.keys + DEFAUT_FONTS.keys
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
  {name: 'Entête'     , value: :header_id, type: :custom, meth: :choose_headfoot_id},
  {name: 'Footer'     , value: :footer_id, type: :custom, meth: :choose_headfoot_id}
]


CHOIX_ALIGN_CONTENU_HEADFOOT = [
  {name: 'Centré dans la page' , value: :center},
  {name: 'À gauche de la page' , value: :left},
  {name: 'À droite de la page' , value: :right},
]

CHOIX_CASSE_TITRE = [
  {name:'Tout majuscule', value: :all_caps},
  {name:'Comme un titre', value: :title},
  {name:'Tout minuscule', value: :min}
]

VALUES_NIVEAU_TITRE_OU_NUM_PAGE = [
  {name:"Numéro de page", value: 0}
]
(1..7).each do |n|
  VALUES_NIVEAU_TITRE_OU_NUM_PAGE << {name:"Titre de niveau #{n}", value: n}

DATA_HEADFOOT = [
  {name: 'Nom du "headfoot"'  , value: :name, required: true},
  {name: 'Police'             , value: :font        , values: :police_names},
  {name: 'Taille'             , value: :size        , type: :int, default: 11, values: (7..30)},
  {name: 'Style'              , value: :style       , type: :sym, values: DATA_STYLES_FONTS, default: 2},
  {name: 'Dispo page gauche'  , value: :left_dispo  , values: CHOIX_ALIGN_CONTENU_HEADFOOT},
  {name: 'Dispo page droite'  , value: :right_dispo , values: CHOIX_ALIGN_CONTENU_HEADFOOT},
  {name: 'Niveau de titre'    , value: :title_level , values: (1..7), default: 0},
  {name: 'Casse du titre'     , value: :title_casse , values: CHOIX_CASSE_TITRE, default: 1},
]

end #/class AssistantHeadersFooters
end #/class Assistant
end #/module Prawn4book
