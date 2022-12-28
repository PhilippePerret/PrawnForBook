module Prawn4book
    def self.cfolder
    File.expand_path('.')
  end

  def self.assistant_titres(pdfbook)
    # 
    # Définir les données des titres
    # 
    titles_data = define_titles(pdfbook)
    # 
    # Enregistrer les données des titres
    # 
    pdfbook.recipe.insert_bloc_data('titles', titles_data)
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
  def self.define_titles(pdfbook)
    #
    # Les données actuelles pour le livre
    # 
    @data_titres = pdfbook.recipe.titles_data
    while true
      # 
      # On prépare les choix en indiquant les données déjà
      # définies (à chaque tour)
      # 
      choices_titres = prepare_choices_titres
      clear unless debug?
      case (niveau = Q.select("Niveau de titre à définir :".jaune, choices_titres, {per_page: CHOICES_TITRES.count}))
      when :save
        return @data_titres
      else
        define_title_level(pdfbook, niveau)
      end
    end #/while
  end

  ##
  # Méthode qui prépare les menus pour choisir les titres en 
  # indiquant les données déjà définies.
  # 
  def self.prepare_choices_titres
    CHOICES_TITRES.map.with_index do |dchoix, idx|
      next dchoix if idx < 2
      curdata = []
      niveau = dchoix[:value]
      dtitre = @data_titres[:"level#{niveau}"]
      if dtitre
        curdata << "#{dtitre[:font]||'-'}/#{dtitre[:size]||'-'}"
        curdata << "#{dtitre[:mtop]||'-'}/#{dtitre[:mbot]||'-'}"
        curdata << "#{dtitre[:leading]||'-'}"
      end
      curdata = curdata.join(' - ')
      color_meth = (dtitre && dtitre[:font] && dtitre[:size] && dtitre[:mtop]) ? :vert : :blanc
      {name: "#{dchoix[:name]} : #{curdata}".send(color_meth), value: niveau}
    end
  end

  def self.define_title_level(pdfbook, niveau)
    key_niveau = "level#{niveau}".to_sym
    @data_titres[key_niveau] || @data_titres.merge!(key_niveau => {})
    # 
    # Les données actuelles du titre
    # 
    dtitre = @data_titres[key_niveau]
    # 
    # Préparation des choix (en mettant la valeur actuelle)
    # 
    choices = (niveau > 2 ? TITRES_PROPERTIES : MAIN_TITRES_PROPERTIES).map.with_index do |c, idx| 
      nc    = c.dup
      prop  = nc[:value]
      next nc if prop == :save
      value = dtitre[prop]
      color_meth = value.nil? ? :jaune : :vert
      nc.merge!(name: "#{c[:name]} : #{value||'-'}".send(color_meth))
    end
    while true
      clear unless debug?
      # 
      # Premier menu sélectionné
      # 
      first_undefined = nil
      choices[1..-1].each_with_index do |dchoix, idx|
        value = @data_titres[key_niveau][dchoix[:value]]
        first_undefined = (idx + 2) and break if value.nil?
      end
      # 
      # Choisir la propriété à définir
      # 
      puts "\n  DÉFINITION DU TITRE DE NIVEAU #{niveau}".bleu
      case (choix = Q.select(nil, choices, {per_page: choices.count, default:first_undefined, show_help:false}))
      when :save then return
      else
        @data_titres[key_niveau].merge!(
          choix => define_prop_title(pdfbook, niveau, choix)
        )
        index_choix = TABLE_TITRES_PROPERTIES[choix][:index]
        choices[index_choix][:name] = "#{MAIN_TITRES_PROPERTIES[index_choix][:name]} : #{@data_titres[key_niveau][choix]}".vert
      end
    end
  end

  def self.define_prop_title(pdfbook, niveau, prop)
    data_choix = TABLE_TITRES_PROPERTIES[prop]
    question   = "#{data_choix[:name]} pour le titre de niveau #{niveau}"
    data_titre = @data_titres[:"level#{niveau}"]
    default    = data_titre ? data_titre[prop] : nil
    value = 
      case data_choix[:type]
      when :bool
        Q.yes?("#{question} ?".jaune)
      when :font
        choices = choices_fonts(pdfbook)
        Q.select("Choisir la police : ".jaune, choices, {per_page:choices.count})
      else
        Q.ask("#{question} : ".jaune, {default: default})
      end
    case data_choix[:type]
    when :int   then return value.to_i
    when :float then return value.to_f
    else return value
    end
  end

  def self.choices_fonts(pdfbook)
    fontes = DEFAULT_FONTS.dup
    fontes += pdfbook.recipe.fonts_data.keys unless pdfbook.recipe.fonts_data.empty?
    cs = []
    fontes.each do |fontname|
      cs << {name:fontname, value:fontname}
    end
    return cs
  end

DEFAULT_FONTS = ['Times','Helvetica','Courier']
CHOIX_SAVE    = {name: PROMPTS[:save].vert, value: :save}

CHOICES_TITRES = [
    CHOIX_SAVE,
    {name: "#{(' ' * 10)}( Police/taille - Nombre de lignes avant/après - leading".gris, disabled:')'}
  ] + (1..7).map do |niv|
  {name: "Titre de niveau #{niv}", value: niv}
end


TITRES_PROPERTIES = [
  CHOIX_SAVE,
  {name: "Fonte"                          , value: :font, type: :font},
  {name: "Taille police"                  , value: :size, type: :float},
  {name: "Nombre de lignes passées avant" , value: :mtop, type: :int},
  {name: 'Nombre de lignes passées après' , value: :mbot, type: :int},
  {name: 'Interlignage'                   , value: :leading, type: :float},
]
MAIN_TITRES_PROPERTIES = TITRES_PROPERTIES + [
  {name: 'Placer ce titre sur une nouvelle page'        , value: :newpage     , type: :bool},
  {name: 'Placer toujours ce titre sur une belle page'  , value: :bellepage   , type: :bool},
]

TABLE_TITRES_PROPERTIES = {}
MAIN_TITRES_PROPERTIES.each_with_index do |dchoix, idx|
  TABLE_TITRES_PROPERTIES.merge!(dchoix[:value] => dchoix.merge(index: idx))
end

end #/module Prawn4book
