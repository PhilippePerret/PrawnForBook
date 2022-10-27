module Prawn4book
class << self

  # @return une table contenant :headers et :footers, la définition
  # des entêtes et pieds de page
  # 
  def define_headers_footers
    @datahf = {headers: {}, footers: {}}
    @datahf.merge!(headers: define_headers_or_footers(:header))
    @datahf.merge!(footers: define_headers_or_footers(:footer))
  end

  # @return la liste des +thing+ définis
  # 
  # @param {Symbol} thing   La chose symbolique (:header ou :footer)
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
        font:         'Arial', # TODO Mettre font par défaut
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
        default = defaut.call(thing) if defaut.is_a?(Proc)
        datah.merge!(name: (datah[:temp_name] % [human_thing, defaut]))
      end

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

      # 
      # On met en forme la donnée finale qui sera écrite
      # 
      dhf.merge!(disposition: ddispo_to_disposition(dhf[:disposition])[thing])

      liste << dhf

      Q.yes?("Voulez-vous créer un autre #{TERMS[thing]} ?".jaune) || break

    end#/ tant qu'on veut définir des headers/footers

    return liste
  end

  # --- Disposition Methods ---

  ##
  # La propriété :disposition étant complexe, on la traite dans une
  # méthode propre.
  # 
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
      puts mise_en_forme_disposition_headfoot(ddispo)
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
  def mise_en_forme_disposition_headfoot(ddispo)
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
    <<~TEXT  
     ----------------------------------------------------------------------
    | #{b[:hel]} #{b[:hec]} #{b[:her]} ||| #{b[:hol]} #{b[:hoc]} #{b[:hor]} |
    |                                  |||                                  |
    /                                  ///                                  /
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
  def disposition_headfoot_default
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

end #/<< self module


HEADFOOT_DISPO_PARTIES = [
  {name: '|xxx|   |   |||   |   |   | de %s', value: [:even, :left]},
  {name: '|   |xxx|   |||   |   |   | de %s', value: [:even, :center]},
  {name: '|   |   |xxx|||   |   |   | de %s', value: [:even, :right]},
  {name: '|   |   |   |||xxx|   |   | de %s', value: [:odd,  :left]},
  {name: '|   |   |   |||   |xxx|   | de %s', value: [:odd,  :center]},
  {name: '|   |   |   |||   |   |xxx| de %s', value: [:odd,  :right]},
  {name:"\n  Remettre valeurs par défaut", value: :default},
  {name:'Finir', value: :finir}
]

CHOIX_TYPE_FONT = [
  {name: 'Normal' , value: :normal},
  {name: 'Italic' , value: :italic},
  {name: 'Bold'   , value: :bold}
]

CHOIX_CONTENU_HEADFOOT = [
  {name: 'Aucun contenu'                          , value:  nil},
  {name: 'Numéro de page (ou de paragraphe)'      , value: 'numero'},
  {name: 'Titre 1 en capitales'                   , value: 'TITLE1'},
  {name: 'Titre 1 en majuscules et minuscules'    , value: 'title1'},
  {name: 'Titre 2 en capitales'                   , value: 'TITLE2'},
  {name: 'Titre 2 en majuscules et minuscules'    , value: 'Title2'},
  {name: 'Titre 3 en capitales'                   , value: 'TITLE3'},
  {name: 'Titre 3 en majuscules et minuscules'    , value: 'Title3'},
  {name: 'Autre…'                                 , value: :other}
]

CHOIX_ALIGN_CONTENU_HEADFOOT = [
  {name: 'centré', value: :center},
  {name: 'aligné à gauche', value: :left},
  {name: 'aligné à droite', value: :right},
]

DATA_HEADER_FOOTER = [
  {name: nil, temp_name: "Nom pour mémoire du %s (%s) :", value: :name, df:'Name'},
  {name: nil, temp_name: "Première page du %s (%s) :", value: :first_page, df:'0', treate_as: :integer},
  {name: nil, temp_name: "Dernière page du %s (%s) :", value: :last_page, df:'100', treate_as: :integer},
  {name: nil, temp_name: "Disposition du %s (%s) :", value: :disposition, df:->(thg){thg == :headers ? 'TITLE1 | | ||| | | title2' : '| | numero | ||| | numero | '}, treate_as: :disposition, t: :method, method: :define_disposition_headfoot},
  {name: nil, temp_name: "Police du %s (%s) :", value: :font, df:'Arial'},
  {name: nil, temp_name: "Taille de police du %s (%s) :", value: :size, df:'12', treate_as: :float},
  {name: nil, temp_name: "Style de police du %s (%s)", value: :style, df: 'Normal', treate_as: :symbol, t: :select, values: CHOIX_TYPE_FONT},
  {name: nil, temp_name: PROMPTS[:save], value: :save}
]
DATA_FH_VALUE_TO_INDEX = {}
DATA_HEADER_FOOTER.each_with_index do |dval, idx|
  DATA_FH_VALUE_TO_INDEX.merge!(dval[:value] => idx)
end
end #/module Prawn4book
