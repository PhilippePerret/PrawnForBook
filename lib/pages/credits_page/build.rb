module Prawn4book
class Pages
class PageInfos

  # = main =
  #
  # Méthode principale construisant la page
  # 
  def build( pdf )
    spy "-> Construction de la page d'informations".bleu

    # Exposer pdf
    @pdf = pdf

    # On définit le delimiteur linéaire en fonction de la disposition
    # des informations (un retour chariot en mode distribué, une 
    # espace dans les autres modes)
    # 
    define_linear_delimitor

    # S'assurer que les informations requises sont bien fournies
    # par la recette du livre ou de la collection
    # 
    infos_valides_or_raises

    # Définition de la hauteur des éléments (libellé et valeur)
    # 
    define_heights

    # Liste des crédits à imprimer
    # 
    # C’est une liste qui contient le nom d’éléments à imprimer, en
    # sachant que certains tiennent sur plusieurs lignes et d’autres
    # sur une seule.
    @credits = get_infos_to_print

    # On commence par se placer sur la bonne page
    # (une belle page seule)
    # 
    pdf.update do
      2.times { start_new_page }
      start_new_page while page_number.even?
      go_to_page(page_number + 1)
    end

    book.page(pdf.page_number).pagination = false

    # == Construction en fonction de la disposition ==
    # 
    print_per_disposition

  end

  # Impression de la page des crédits en fonction de la disposition
  # voulue
  def print_per_disposition
    # Calcul de la hauteur du bloc des crédits
    calc_block_credits_height
    # = Calcul du top =
    top =
      case disposition
      when 'distribute', 'distributed', 'middle'
        pdf.bounds.height - (pdf.bounds.height - credits_height) / 2
      when 'bottom'
        credits_height + 40
      when 'top'
        pdf.bounds.height
      else 
        raise PFBFatalError.new(203, {dispo: disposition})
      end
    # Impression des crédits
    print_credits_at(pdf, top)  
  end


  # = IMPRESSION DES CRÉDITS =
  # 
  # Block qui écrit vraiment les crédits, à partir du +top+ fourni
  # 
  def print_credits_at(pdf, top)
    # pdf.move_cursor_to(top)
    puts "\n"
    mycursor = top
    credits.each_with_index do |dcredit, idx|
      if dcredit == :delimitor
        mycursor -= value_height
      else
        if dcredit[:label]
          pdf.fill_color(label_color) if label_color
          pdf.font(label_fonte)
          pdf.text_box(dcredit[:label], **label_options.merge(at:[0, mycursor]))
          mycursor -= label_height
        end
        if dcredit[:value]
          pdf.fill_color(value_color) if value_color
          pdf.font(value_fonte)
          pdf.text_box(dcredit[:value], **value_options.merge(at:[0, mycursor]))
          mycursor -= (dcredit[:lines] + 1) * value_height
        end
        # break if idx == 4
      end
    end
  end

  def label_options
    @label_options ||= {
      align:    :center, 
      width:    pdf.bounds.width,
      leading:  4
    }.freeze
  end

  def value_options
    @value_options ||= {
      size: value_fonte.size,
      color: value_fonte.color,
      align: :center,
      width: pdf.bounds.width,
      leading: 0
    }.freeze
  end

  def pdf; @pdf end
  def credits; @credits end


  # @return [Array] La liste des informations à afficher
  def get_infos_to_print
    ary = []
    [:pub_name, :pub_url, :pub_address, :pub_mail].each do |prop|
      value = send(prop) || next
      value = value.split("\\n").join(LINEAR_DELIMITOR) if prop == :pub_address
      ary << {value: value}
    end
    ary << {value: "SIRET : #{pub_siret}"}              if pub_siret
    ary << {label: 'Contact', value:pub_contact}        if pub_contact
    ary << :delimitor
    ary << {value:"URL : #{book_url}"}                  if book_url
    ary << {value:"ISBN : #{isbn}"}                     if isbn
    ary << {value: "Dépôt légal : #{depot_legal}"}      if depot_legal
    ary << :delimitor
    ary << {label:'Conception', value: conception}      if conception
    ary << {label:'Rédaction', value: redaction}        if redaction
    ary << {label:'Mise en page', value: page_design}   if page_design
    ary << {label: 'Couverture', value: cover_design}
    ary << {label: 'Correction & relecture', value:correction} if correction
    ary << :delimitor
    ary << {value: "Imprimé par #{imprimerie}"}

    return ary
  end

  def pub_name
    @pub_name ||= publisher[:name]
  end
  def pub_mail
    @pub_mail ||= publisher[:mail]
  end
  def pub_url
    @pub_url ||= publisher[:url]
  end
  def pub_address
    @pub_address ||= publisher[:address]||publisher[:adresse]
  end
  def pub_contact
    @pub_contact ||= publisher[:contact]
  end
  def pub_siret
    @pub_siret = publisher[:siret]
  end

  def book_url
    @book_url ||= book_data[:url]
  end
  def depot_legal
    @depot_legal ||= credits_page[:depot_legal]||credits_page[:legal_deposit]
  end

  # --- Données crédits --- #

  def conception
    @conception ||= begin
      if book_making[:conception] && book_making[:conception][:patro]
        traite_people_in(book_making[:conception])
      end
    end
  end
  def redaction
    @redaction ||= begin
      if book_making[:writing] && book_making[:writing][:patro]
        traite_people_in(book_making[:writing])
      end
    end
  end

  def page_design
    @page_design ||= begin
      if book_making[:page_design] && book_making[:page_design][:patro]
        traite_people_in(book_making[:page_design])
      end
    end
  end

  def cover_design
    @cover_design ||= begin
      if book_making[:cover] && book_making[:cover][:patro]
        traite_people_in(book_making[:cover])
      end
    end
  end

  def correction
    @correction ||= begin
      if book_making[:correction] && book_making[:correction][:patro]
        traite_people_in(book_making[:correction])
      end
    end
  end

  def imprimerie
    @imprimerie ||= begin
      dimp = book_making[:printing]
      if dimp
        d = dimp[:name]
        d = "#{d} (#{dimp[:lieu]})" if dimp[:lieu]
        d
      else
        nil
      end
    end
  end

  def isbn
    @isbn ||= book_data[:isbn]
  end

  def credits_height; @credits_height end 
  
  # # -- Fonts Volatile Infos --

  def label_height; @label_height end
  def value_height; @value_height end

  # Fontes pour le libellé et la valeur
  def label_fonte
    @label_fonte ||= Prawn4book.fnss2Fonte(credits_page[:libelle][:font])||Fonte.default
  end
  def label_color
    @label_color ||= label_fonte.color
  end
  def value_fonte
    @value_fonte ||= Prawn4book.fnss2Fonte(credits_page[:value][:font])||Fonte.default
  end
  def value_color
    @value_color ||= value_fonte.color
  end

  # --- General Data ---

  def book_data
    @book_data ||= recipe.book_data
  end

  def book_making
    @book_making ||= recipe.book_making
  end

  def credits_page
    @credits_page ||= recipe.credits_page
  end

  def publisher
    @publisher ||= recipe.publisher
  end

  def book
    @book ||= PdfBook.ensure_current
  end


  private

    # En mode distribué, les labels et informations sont les unes
    # au-dessus des autres, les mails sont sous les noms, les 
    # adresses sont en lignes. Dans les autres modes, tout est sur
    # la même ligne. C'est la constante LINEAR_DELIMITOR, définie ici,
    # qui détermine ce comportement
    # 
    # OBSOLÈTE : maintenant, on met toujours un retour chariot, mais
    # je laisse comme ça, pour avoir peut-être la possibilité de le 
    # changer en cas de problème de "fit" dans la page
    def define_linear_delimitor
      unless defined?(LINEAR_DELIMITOR)
        # Object.const_set('LINEAR_DELIMITOR', distributed? ? "\n" : " ")
        Object.const_set('LINEAR_DELIMITOR', "\n")
      end
    end

    # Définir les hauteurs des éléments de base (fontes, line)
    def define_heights
      define_value_height
      define_label_height
      define_line_height
    end

    # Calcul des hauteurs des labels et des valeurs en fonction de
    # la fonte utilisée
    # 
    def define_label_height
      pdf.font(label_fonte) do
        @label_height = pdf.height_of("Label", **label_options) - 4
      end
      @label_height.is_a?(Float) || raise(PFBFatalError.new(610))
    end
    def define_value_height
      pdf.font(value_fonte) do
        @value_height = pdf.height_of("Une valeur", **value_options) + 2
      end
      @value_height.is_a?(Float) || raise(PFBFatalError.new(610))
    end

    # On définit la hauteur de ligne
    # (ne sert plus vraiment, à part pour les valeurs sur plusieurs
    #  lignes comme les adresses physiques)
    def define_line_height
      pdf.line_height = value_fonte.size + 2      
    end

    # Calcul de la hauteur du bloc de crédits
    # 
    def calc_block_credits_height
      h = 0
      @credits.each do |dcredit|
        if dcredit == :delimitor
          h += value_height
        else
          h += label_height if dcredit[:label]
          # On ajoute le nombre de lignes
          dcredit.merge!(lines: dcredit[:value].count("\n") + 1)
          h += value_height * (dcredit[:lines] + 1)
        end
      end

      # Si la hauteur est trop importante, on réduit la taille des
      # police pour arriver à une taille acceptable
      if h > pdf.bounds.height - 40
        if label_fonte.size < 5
          raise PFBFatalError.new(202)
        end
        if not(@error_dont_fit_already_done)
          add_erreur(PFBError[201])
          @error_dont_fit_already_done = true
        end
        label_fonte.size = 10
        value_fonte.size = value_fonte.size - 2
        define_heights
        calc_block_credits_height
        return
      end

      @credits_height = h
    end

  # Reçoit une donnée "people", avec un ou des patronymes (:patro) et
  # un ou des mails et compose la donnée en ajoutant les mails aux
  # noms
  # @return [String] Les données des noms et mails
  # 
  # @api private
  def traite_people_in(dpeople)
    people = dpeople[:patro] || return
    people = people.match?(',') ?
                people.split(',').map{|n|n.strip} : [people]
    mails  = dpeople[:mail]
    mails  = mails.to_s.match?(',') ?
                mails.split(',').map{|n|n.strip} : [mails]
    people.map.with_index do |patro, idx|
      patro = human_for_patro(patro)
      patro = "#{patro}#{LINEAR_DELIMITOR}(#{mails[idx]})" unless mails[idx].nil?
      patro
    end.pretty_join    
  end

  # Méthode qui transforme "Philippe PERRET" en "Philippe Perret"
  # (sauf si +patro+ commence par un signe égal, ce qui signifie 
  #  qu’il faut le garder tel quel)
  def human_for_patro(patro)
    if patro.start_with?('=')
      patro[1..-1]
    else
      patro.titleize
    end
  end

  ##
  # Méthode qui s'assure que les informations ont bien été fournies
  # pour les informations.
  # 
  def infos_valides_or_raises
    boma = book_making
    publ = publisher

    # Les données qu'on doit trouver pour pouvoir établir la 
    # page d'informations
    missing_data_type = []
    making_book_missing_keys  = []
    publisher_missing_keys    = []

    # Dans book_making
    [
      [ conception||redaction ,'le concepteur (ou le rédacteur)', ["conception","patro"]],
      [ redaction||conception ,'le rédacteur',  ["writing","patro"]],
      [ cover_design  ,'le graphiste couverture', ["cover","patro"]],
      [ correction    ,'la correctrice', ["correction","patro"]],
      [ page_design   ,'le metteur en page', ["page_design","patro"]],
      [ imprimerie    ,'l’imprimerie', ["printing","name"]],
    ].each do |value, dtype, keys|
      value || begin
        missing_data_type << dtype
        making_book_missing_keys << keys
      end
    end

    # Dans publisher
    [
      [ publ[:name],'la maison d’édition', ["name"]],
    ].each do |value, dtype, keys|
      value || begin
        missing_data_type << dtype
        publisher_missing_keys << keys
      end
    end

    return true if missing_data_type.empty?
    err = []
    if making_book_missing_keys.any?
      err << "#<book_making>"
      err << "book_making:"
      making_book_missing_keys.each do |info_keys|
        inject_missing_key(err, info_keys)
      end
      err << ""
    end

    if publisher_missing_keys.any?
      err << "#<publisher>"
      err << "publisher:"
      publisher_missing_keys.each do |info_keys|
        inject_missing_key(err, info_keys)
        # err = inject_missing_key(err, info_keys)
      end
      err << ""
    end

    raise PFBFatalError.new(500, {missing_infos: missing_data_type.pretty_join, missing_keys: err.join("\n")})

  end

  def inject_missing_key(err, info_keys)
    last_key = info_keys.count - 1
    info_keys.each_with_index do |key, idx|
      v = "#{'  ' * (idx + 1)}#{key}:"
      v = "#{v} '<valeur manquante>'" if idx == last_key
      err << v
    end    
    return err
  end


  # -- Predicate Methods --

  def distributed?
    disposition == 'distribute' || disposition == 'distributed' || disposition == 'middle'
  end

  # -- Données pour l’aspect de la page de crédits --

  def disposition
    @disposition ||= credits_page[:disposition]
  end


end #/class PageInfos
end #/class Pages
end #/module Prawn4book
