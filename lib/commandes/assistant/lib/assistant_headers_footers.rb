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
    owner.recipe.insert_bloc_data('headers_footers', {
      dispositions: data_dispositions,
      headfooters:  data_headfooters
    })
  end

  def data_dispositions
    @data_dispositions ||= hf_data[:dispositions]||{}
  end
  def data_headfooters
    @data_headfooters ||= hf_data[:headfooters]||{}
  end
  def hf_data
    @hf_data ||= owner.recipe.headers_footers_data
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
    tty_define_object_with_data(DATA_DISPOSITION, data_dispo)

    puts "data_dispo à la fin : #{data_dispo.inspect}"
    sleep 10
    # 
    # On enregistre les nouvelles données
    # 
    save
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
    end

    puts "hf_data : #{hf_data.inspect}"
    sleep 10

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
  {name: 'Titre pour mémoire', value: :title, required: true},
  {name: 'De la page' , value: :first_page, type: :int},
  {name: 'À la page'  , value: :last_page, type: :int},
  {name: 'Entête'     , value: :header_name, type: :custom, meth: :choose_headfoot_id},
  {name: 'Footer'     , value: :footer_name}
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

DATA_HEADFOOT = [
  {name: 'Nom du "headfoot"'  , value: :name, required: true},
  {name: 'Police'             , value: :font, values: :police_names},
  {name: 'Taille'             , value: :int, default: 11},
  {name: 'Style'              , value: :sym, values: DATA_STYLES_FONTS, default: 2},
  {name: 'Dispo page gauche'  , value: :left_dispo  , values: CHOIX_ALIGN_CONTENU_HEADFOOT},
  {name: 'Dispo page droite'  , value: :right_dispo , values: CHOIX_ALIGN_CONTENU_HEADFOOT},
  {name: 'Niveau de titre'    , value: :title_level , values: (1..7), default: 1},
  {name: 'Casse du titre'     , value: :title_casse , values: CHOIX_CASSE_TITRE, default: 1},
]

###################       ANCIENNES MÉTHODES      ###################
  
class << self


  ##
  # Méthode permettant de choisir le footer ou le header à éditer
  # et/ou en créer un nouveau.
  # 
  def choose_and_edit_header_or_footer(pdfbook, whats)
    # 
    # Choisir la chose à éditer (l'entête parmi les entêtes ou
    # le pied de page parmi les pieds de page)
    # 
    # TODO : ne pas oublier le choix : en créer un nouveau
    # TODO : ne pas oublier le choix : en supprimer un
    puts "Je dois apprendre à relever les headers/footers et proposer d'en choisir un".jaune
    data_ini = pdfbook.recipe.get(whats)
    # puts "Données initiales : #{data_ini.inspect}"
    choices = make_choices_from_headfoot(data_ini)
    case datael = Q.select("Quel élément voulez-vous modifier ?".jaune, choices, per_page:choices.count)
    when :cancel then return
    when :newone
      puts "Je dois apprendre à initier un nouvel élément #{whats}.".jaune
      datael = nil
    else

    end
    # 
    # Mettre la chose choisie en édition et relever la valeur
    # renvoyer pour l'enregistrer
    # 
    puts "Je dois apprendre à envoyer la chose à l'édition et recevoir les nouvelles données".jaune
    # 
    # Enregistrement des nouveaux headers ou footers
    # 
    puts "Je dois apprendre à enregistrer les #{whats}".jaune
    # pdfbook.recipe.insert_bloc_data(whats, new_whats)
  end

  # Reçoit les données headers ou footers et retourne une liste
  # pour Tty-prompt, pour en choisir un
  def make_choices_from_headfoot(elements)
    elements.map do |delement|
      nom = delement[:name] || begin
        if delement[:first_page] && delement[:last_page]
          "De page #{delement[:first_page]} à page #{delement[:last_page]}"
        else
          dispo = delement[:disposition]
          "#{dispo[:even]} ||| #{dispo[:odd]}"
        end
      end
      {name: nom, value: delement}
    end + [
      {name: "\n  En créer un nouveau", value: :newone},
      {name: 'Renoncer', value: :cancel}
    ]
  end

  # 
  # @return une table contenant :headers et :footers, la définition
  # des entêtes et pieds de page
  # 
  # Note : Cette méthode est appelée directement lors de l'init d'un
  # dossier livre ou collection.
  # 
  def define_headers_footers
    @datahf = {headers: {}, footers: {}}
    @datahf.merge!(headers: define_headers_or_footers(:header))
    @datahf.merge!(footers: define_headers_or_footers(:footer))
  end

  #
  # @return la liste des +thing+ définis
  # 
  # @param thing  {Symbol} La chose symbolique (:header ou :footer)
  # @param cdata  {Hash} Données du livre/collection dont on doit 
  #               modifier les headers et/ou footers.
  # 
  def define_headers_or_footers(thing, cdata = nil)
    
    liste = []

    while true # tant qu'on veut définir des headers ou des footers

      #
      # Valeurs de disposition par défaut pour l'élément de type
      # +thing+
      # 
      dispo = disposition_headfoot_default
      if cdata
        puts "Il faut que j'apprenne à prendre les valeurs de disposition".orange
      end

      # 
      # Table pour définir l'header ou le footers
      dhf = {
        name:         "Name of the #{thing}",
        first_page:   4,
        last_page:    200,
        font:         :"F1.0",
        size:         11,
        style:        :normal,
        disposition:  dispo,
      }

      human_thing = thing.to_s

      # 
      # On commence par afficher les valeurs par défaut qui sont
      # dans les questions
      # 
      DATA_HEADER_FOOTER.each do |datah|
        defaut = datah[:df]
        defaut = defaut.call(thing) if defaut.is_a?(Proc)
        datah.merge!(name: (datah[:temp_name] % [human_thing, defaut]))
      end

      dhf = edit_header_footer(datah, thing)

      # 
      # On met en forme la donnée finale qui sera écrite
      # 
      dhf.merge!(disposition: ddispo_to_disposition(dhf[:disposition])[thing])

      liste << dhf

      Q.yes?("Voulez-vous créer un autre #{TERMS[thing]} ?".jaune) || break

    end#/ tant qu'on veut définir des headers/footers

    return liste
  end

  ##
  # Pour éditer l'élément en question
  # 
  # @param datah {Hash} Données simples pour le header ou le footer
  #               Seule la propriété :disposition est différente de
  #               la propriété enregistrée et devra être traitée en
  #               aval et en amont (cf. [1] ci-dessous)
  # @param thing  {Symbol} Soit :header soit :footer
  # 
  # [1] La propriété :disposition contient l'header aussi bien que
  #     le footer, pour avoir un aperçu des deux. Chercher la marque
  #     « [REPERE 001] » pour voir à quoi ressemble la donnée.
  # 
  # [2] Il faut utiliser la méthode `disposition_headfoot_default'
  #     pour obtenir une valeur par défaut et y injecter les valeurs
  #     courant si c'est un header/footer précis qui est édité.
  # [3] Il faut utiliser la méthode :
  #     ddispo_to_disposition(dhf[:disposition])[thing] pour 
  #     recomposer la donnée :odd et :even simple.
  # 
  def edit_header_footer(datah, thing)
    while true
      clear unless debug?
      # 
      # L'user doit choisir la donnée à définir
      # 
      case choix = Q.select("Définir :".jaune, DATA_HEADER_FOOTER, per_page:DATA_HEADER_FOOTER.count)
      when :save then break
      else
        #
        # Pour définir une valeur
        # 
        idx     = DATA_FH_VALUE_TO_INDEX[choix]
        datah   = DATA_HEADER_FOOTER[idx]
        defaut  = dhf[:choix] || datah[:df]
        defaut = defaut.call(thing) if defaut.is_a?(Proc)
        # 
        # Demande de la réponse à l'user
        # 
        reponse = case datah[:t]
        when :method
          send(datah[:method], thing, dhf[choix])
        when :select
          Q.select(datah[:name].jaune, datah[:values], per_page:datah[:values].count, default:defaut)
        else
          Q.ask(datah[:name].jaune, default: defaut)
        end
        # 
        # Traitement de la réponse
        # 
        case datah[:treate_as]
        when :integer
          reponse = reponse.to_i unless reponse.nil?
        when :float
          reponse = reponse.to_f unless reponse.nil?
        when :symbol
          reponse = reponse.to_sym unless reponse.nil?
        end
        # 
        # Consignation de la réponse
        # 
        # puts "Pour #{choix.inspect}, je mets la réponse :\n#{reponse.inspect}"
        # Q.yes?("Poursuivre ?")
        dhf.merge!(choix => reponse)
        # 
        # Affichage de la réponse dans les menus
        # 
        rep_aff = 
          case choix
          when :disposition then valeur_defaut_for(reponse, thing)
          else reponse
          end
        datah.merge!(name: (datah[:temp_name] % [human_thing, rep_aff]))
      end
    end #/tant qu'on veut définir LE header ou LE footer
    
    return dhf
  end

  # --- Disposition Methods ---

  ##
  # La propriété :disposition étant complexe, on la traite dans une
  # méthode propre.
  # 
  # [REPERE 001]
  # @param ddispo  {Hash} Table des données de header et footer 
  #             complète décomposée en :
  #             {
  #               header: {
  #                 even: {
  #                   left:   {content: '...', align: :left|:center|:right}
  #                   center: {content: '...', align: ...}
  #                   left:   {content: '...', align: ...}
  #                 }
  #                 odd: {<idem>}
  #               }
  #               footer: {
  #                 even: {}
  #                 odd: {<idem>}
  #               }
  #             }
  def define_disposition_headfoot(thing, ddispo)
    # 
    # Préparation de la table des choix
    # 
    table_choix_parties = HEADFOOT_DISPO_PARTIES.dup
    table_choix_parties = (table_choix_parties.each {|e| e[:name] = e[:name] % TERMS[thing]}).freeze
    table_choix_parties_count = table_choix_parties.count.freeze
    # 
    # Boucle tant qu'on veut définir des choses de l'entête ou 
    # du pied de page (thing = respectivement :header ou :footer)
    # 
    while true
      # 
      # Pour visualiser l'état
      # 
      clear
      puts mise_en_forme_disposition_headfoot(ddispo, thing)
      # 
      # Pour choisir l'élément à modifier
      # 
      case choix = Q.select("Quelle partie définir pour #{thing.to_s.upcase} ?".jaune, table_choix_parties, per_page: table_choix_parties_count)
      when :default then ddispo = disposition_headfoot_default
      when :finir then break
      else headfoot_define_value(choix, thing, ddispo)
      end
    end #/while

    return ddispo
  end

  # Pour obtenir une valeur à afficher en valeur par défaut
  # pour la disposition courante
  def valeur_defaut_for(dispo, thing)
    d = ddispo_to_disposition(dispo)[thing]
    "#{d[:even]} ||| #{d[:odd]}"
  end

  # Pour régler :disposition telle qu'elle doit être dans la recette
  # 
  def ddispo_to_disposition(dispo)
    tbl = {header: {even: nil, odd: nil}, footer: {even: nil, odd: nil}}
    [:header, :footer].each do |bkey|
      [:even, :odd].each do |skey|
        troissections = ['','','']
        [:left, :center, :right].each_with_index do |akey, idx|
          d = dispo[bkey][skey][akey]
          val = d[:content]
          unless val.nil?
            val = "%#{val}" if val.match?(/^(numero|title)/i)
            case d[:align]
            when :left    then val = "#{val}-"
            when :center  then val = "-#{val}-"
            when :right   then val = "-#{val}"
            end
          end
          troissections[idx] = val.to_s
        end
        tbl[bkey][skey] = troissections.join(' | ')
      end
    end

    return tbl
  end

  # Pour choisir la valeur
  def headfoot_define_value(choix, thing, ddispo)
    curval = ddispo[thing][choix[0]][choix[1]]
    # 
    # Pour choisir la valeur par défaut
    # 
    defaut = Q.default_name_for_value(CHOIX_CONTENU_HEADFOOT, curval[:content])
    content = Q.select("Contenu".jaune, CHOIX_CONTENU_HEADFOOT, per_page:CHOIX_CONTENU_HEADFOOT.count, default: defaut)
    if content == :other
      content = Q.ask("Contenu fixe (ou pas…) : ".jaune)
    end
    align =
    unless content.nil?
      defaut = Q.default_name_for_value(CHOIX_ALIGN_CONTENU_HEADFOOT, curval[:align])
      Q.select("Alignement : ".jaune, CHOIX_ALIGN_CONTENU_HEADFOOT, per_page:CHOIX_ALIGN_CONTENU_HEADFOOT.count, default: defaut)
    else
      :left
    end
    curval.merge!(content: content, align: align)
  end

  # Construit un affichage des entêtes et pieds de page, pour voir
  # ce qui sera affiché.
  # Cf. la composition de +dhf+ ci-dessus
  def mise_en_forme_disposition_headfoot(ddispo, thing)
    # Pour le nom des variables :
    #   h(ead)/f(oot) e(ven)/o(dd) l(eft)/c(enter)/r(ight)
    b = {}
    {h: :header, f: :footer}.each do |smin, splain|
      {e: :even, o: :odd}.each do |min, plain|
        {l: :left, c: :center, r: :right}.each do |amin, aplain|
          k = "#{smin}#{min}#{amin}".to_sym
          h = ddispo[splain][plain][aplain]
          b.merge!(k => content_headfoot_aligned(h[:content], h[:align], 10))
        end
      end
    end

    color_header = thing == :header ? :blanc : :gris
    color_footer = thing == :footer ? :blanc : :gris
    <<-TEXT.send(color_header) + 
     ----------------------------------------------------------------------
    | #{b[:hel]} #{b[:hec]} #{b[:her]} ||| #{b[:hol]} #{b[:hoc]} #{b[:hor]} |
    |                                  |||                                  |
    TEXT
    <<-TEXT.send(:gris) +
    /                                  ///                                  /
    TEXT
    <<-TEXT.send(color_footer)
    |                                  |||                                  |
    | #{b[:fel]} #{b[:fec]} #{b[:fer]} ||| #{b[:fol]} #{b[:foc]} #{b[:for]} |
     ----------------------------------------------------------------------
    TEXT
  end

  def content_headfoot_aligned(content, align, length)
    return ''.ljust(length) if content == '' || content.nil?
    case align
    when :left  then content.to_s.ljust(length)
    when :right then content.to_s.rjust(length)
    when :center
      cote = (length -  content.to_s.length) / 2
      content = (' ' * cote) + content.to_s
      content = content + ' ' while content.length < length
      content
    end
  end

  # 
  # Pour mettre les valeurs par défaut pour les dispositions
  # 
  # Noter que même si seul l'entête ou le pied de page est traité,
  # les deux valeurs sont nécessaires pour en définir un des deux.
  # 
  def disposition_headfoot_default(empty_one = false)
    dispo = {}
    [:header, :footer].each do |bkey| # pour "block key"
      dispo.merge!(bkey => {})
      [:even, :odd].each do |skey| # pour "side key"
        dispo[bkey].merge!(skey => {})
        [:left, :center, :right].each do |akey| # pour "align key"
          dispo[bkey][skey].merge!(akey => { content: nil, align: :left })
        end
      end
    end
    return dispo if empty_one
    dispo[:footer][:even][:center][:content]  = 'numero'
    dispo[:footer][:even][:center][:align]    = :center
    dispo[:footer][:odd][:center][:content]   = 'numero'
    dispo[:footer][:odd][:center][:align]     = :center
    dispo[:header][:even][:left][:content]    = 'TITLE1'
    dispo[:header][:even][:left][:align]      = :left
    dispo[:header][:odd][:right][:content]    = 'title2'
    dispo[:header][:odd][:right][:align]      = :right
    return dispo
  end

end #/<< self class Assistant




DATA_DISPOSITION_TO_INDEX = {}
DATA_DISPOSITION.each_with_index do |dval, idx|
  DATA_DISPOSITION_TO_INDEX.merge!(dval[:value] => idx)
end


end #/class AssistantHeadersFooters
end #/class Assistant
end #/module Prawn4book
