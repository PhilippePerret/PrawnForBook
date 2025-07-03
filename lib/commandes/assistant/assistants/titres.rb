require './lib/modules/tty_facilitators'
module Prawn4book
class Assistant

  def self.assistant_titres(owner)
    # 
    # Définir les données des titres
    # 
    titles_data = AssistantTitres.new(owner).define_titles
    # 
    # Enregistrer les données des titres
    # 
    owner.recipe.insert_bloc_data('titles', titles_data)
  end

class AssistantTitres
  include TTYFacilitators

  attr_reader :owner
  def initialize(owner)
    @owner = owner
  end

  ##
  # Méthode permettant de définir les données de titres
  # @return [Hash] Les données des titres par niveau, avec en 
  # clé :"level<niveau titre>" et en valeur un hash
  # 
  # @note
  #   La méthode fonctionne en deux temps :
  #   1. Un panneau permettant de choisir le niveau de titre à définir
  #   2. Un panneau permettant de définir les valeur du niveau de titre choisi
  # 
  def define_titles
    #
    # Les données actuelles pour le livre
    # 
    @data_titres = owner.recipe.titles_data
    while true
      # 
      # On prépare les choix en indiquant les données déjà
      # définies (à chaque tour)
      # 
      choices_titres = prepare_choices_titres
      clear unless debug?
      case (niveau = Q.select("\n  Niveau de titre à définir :".jaune, choices_titres, {per_page: CHOICES_TITRES.count, show_help:false, echo:false}))
      when :save
        return @data_titres
      else
        define_title_level(niveau)
      end
    end #/while
  end

  ##
  # Méthode qui prépare les menus pour choisir les titres en 
  # indiquant les données déjà définies.
  # 
  def prepare_choices_titres
    CHOICES_TITRES.map.with_index do |dchoix, idx|
      next dchoix if idx < 2
      curdata = []
      niveau = dchoix[:value]
      dtitre = @data_titres[:"level#{niveau}"]
      if dtitre
        curdata << "#{dtitre[:font]||'-'}/#{dtitre[:style]||'-'}/#{dtitre[:size]||'-'}"
        curdata << "#{dtitre[:lines_before]||'-'}/#{dtitre[:lines_after]||'-'}"
        curdata << "#{dtitre[:leading]||'-'}"
      end
      curdata = curdata.join(' - ')
      color_meth = (dtitre && dtitre[:font] && dtitre[:size] && dtitre[:lines_before]) ? :vert : :blanc
      {name: "#{dchoix[:name]} : #{curdata}".send(color_meth), value: niveau}
    end
  end

  def define_title_level(niveau)
    key_niveau = "level#{niveau}".to_sym
    @data_titres[key_niveau] || @data_titres.merge!(key_niveau => {level: niveau})
    # 
    # Les données actuelles du titre
    # 
    dtitre = @data_titres[key_niveau]
    # 
    # On aura besoin du niveau de titre pour déterminer ses données
    # 
    dtitre.merge!(level: niveau)
    # 
    # On utilise le facilitateur pour éditer le titre
    # 
    tty_define_object_with_data(TITRES_PROPERTIES, dtitre)

  end

CHOICES_TITRES = [
    CHOIX_SAVE,
    {name: "#{(' ' * 10)}( Police/taille - Nombre de lignes avant/après - leading".gris, disabled:')'}
  ] + (1..7).map do |niv|
  {name: "Titre de niveau #{niv}", value: niv}
end


TITRES_PROPERTIES = [
  {name: "Fonte et style"                               , value: :font_n_style, type: :string, values: Fonte.method(:as_choices)},
  {name: "Taille police"                                , value: :size, type: :float},
  {name: "Nombre de lignes passées avant"               , value: :lines_before, type: :int},
  {name: 'Nombre de lignes passées après'               , value: :lines_after, type: :int},
  {name: 'Interlignage'                                 , value: :leading, type: :float},
  {name: 'Placer ce titre sur une nouvelle page'        , value: :new_page     , type: :bool, if: ->(dd){ puts "dd = #{dd.inspect}"; dd[:level] < 2 }, default: true },
  {name: 'Placer toujours ce titre sur une belle page'  , value: :belle_page   , type: :bool, if: ->(dd){ dd[:level] < 2 } },
]
MAIN_TITRES_PROPERTIES = TITRES_PROPERTIES + []

TABLE_TITRES_PROPERTIES = {}
MAIN_TITRES_PROPERTIES.each_with_index do |dchoix, idx|
  TABLE_TITRES_PROPERTIES.merge!(dchoix[:value] => dchoix.merge(index: idx))
end

end #/class AssistantTitres
end #/class Assistant
end #/module Prawn4book
