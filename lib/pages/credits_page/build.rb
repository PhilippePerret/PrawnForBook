module Prawn4book
class Pages
class PageInfos

  # = main =
  #
  # Méthode principale construisant la page
  # 
  def build(pdf)
    spy "-> Construction de la page d'informations".bleu

    # pour exposer à pdf
    my = me = self

    # On définit le delimiteur linéaire en fonction de la disposition
    # des informations (un retour chariot en mode distribué, une 
    # espace dans les autres modes)
    # 
    define_linear_delimitor

    # S'assurer que les informations requises sont bien fournies
    # par la recette du livre ou de la collection
    # 
    infos_valides_or_raises

    # Liste des informations à imprimer
    # 
    # C’est une liste qui contient le nom d’éléments à imprimer, en
    # sachant que certains tiennent sur plusieurs lignes et d’autres
    # sur une seule.
    @infos_to_print = get_infos_to_print


    # On compte le nombre de lignes pour savoir la taille qu’on va
    # devoir donner aux informations
    @nombre_lignes = 0
    @infos_to_print.each do |dline|
      @nombre_lignes += 1
      next if dline == :delimitor
      @nombre_lignes += dline[:value].count("\n") + 1 if dline.key?(:label)
    end

    # 
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
    case disposition
    when "distribute"   then print_distributed(pdf)
    when "botttom"      then print_at_the_bottom(pdf)
    when "top"          then print_at_the_top(pdf)
    else raise "Credits page, disposition #{disposition.inspect} unknown"
    end

    spy "<- /Construction de la page d'informations".bleu
  end

  def print_distributed(pdf)

    # Pour s’exposer à pdf
    my = self

    dispose_element_on_surface(pdf)

    # Boucle sur toutes les informations à imprimer
    @infos_to_print.each do |dinfo|

      pdf.update do 
        case dinfo
        when :delimitor
          move_down(my.interstice_height)
        else
          if dinfo[:label]
            # - Le label -
            font(my.label_fonte)
            fill_color(my.label_color)
            text(dinfo[:label], **{align: :center, leading: 2})
          end
          # - La valeur -
          font(my.value_fonte)
          fill_color(my.value_color)
          text(dinfo[:value], **{align: :center, inline_format: true})
          # - Descendre encore -
          pdf.move_down(my.interstice_height)
        end
      end
    end    
  end

  def print_at_the_bottom(pdf)

    pdf.font(value_fonte)

    # On doit se placer assez haut pour tout écrire
    # 
    hauteur_ligne = pdf.height_of(@infos_to_print.first[:value])
    top_cursor    = @nombre_lignes * hauteur_ligne
    pdf.move_cursor_to(top_cursor)

    # = Imprimer toutes les infos =
    @infos_to_print.each do |dinfo|
      case dinfo
      when :delimitor then next
      else print_line(pdf, dinfo)
      end
    end
  end

  def print_at_the_top(pdf)

    pdf.font(value_fonte)

    # = Imprimer toutes les infos =
    @infos_to_print.each do |dinfo|
      case dinfo
      when :delimitor then next
      else print_line(pdf, dinfo)
      end
    end
  end

  def print_line(pdf, dinfo)
    line = dinfo[:value]
    line = "#{dinfo[:label]} : #{line}" if dinfo[:label]
    pdf.text(line, **{align: :left, leading:0})
  end

  def interstice_height
    @interstice_height
  end

  # Méthode qui réparti les informations de la page sur la page en
  # mode "distribué"
  # 
  def dispose_element_on_surface(pdf)

    # = Surface sur laquelle pourront se mettre les informations si
    #   on doit les répartir. =
    surface_height = pdf.bounds.height

    # = Hauteur prise par un label =
    height_for_label = get_label_height(pdf)
    height_for_label.is_a?(Float) || raise(PFBFatalError.new(610))

    # = Hauteur prise par une valeur =
    height_for_value = get_value_height(pdf)
    height_for_value.is_a?(Float) || raise(PFBFatalError.new(610))

    # On passe en revue toutes les infos pour voir l'espace total
    # qui restera et le répartir dans les interstices
    texte_height = 0
    nombre_interstices = 0
    @infos_to_print.each do |dinfo|
      if dinfo == :delimitor
        nombre_interstices += 1
      else
        texte_height += height_for_label unless dinfo[:label].nil?
        nombre_lignes = dinfo[:value].count("\n") + 1
        texte_height += height_for_value * nombre_lignes
      end
    end

    # = Hauteur des interstices
    @interstice_height = ((surface_height - texte_height) / nombre_interstices).round(3)
    # - Jamais plus que la hauteur de ligne
    @interstice_height = pdf.line_height * 2 if @interstice_height > pdf.line_height * 2

    spy "Calcul des hauteurs".jaune
    spy "Surface utilisable         : #{surface_height}".bleu
    spy "Hauteur d'un label         : #{height_for_label}".bleu
    spy "Hauteur d'une valeur       : #{height_for_value}".bleu
    spy "Hauteur prise par le texte : #{texte_height}".bleu
    spy "Nombre d'interstices       : #{nombre_interstices}".bleu
    spy "=> Hauteur interstices     : #{@interstice_height}".bleu

  end

  ##
  # Pour calculer les hauteurs des labels et des valeurs
  # 
  def get_label_height(pdf)
    pdf.font(label_fonte) do
      return pdf.height_of("Label")
    end
  end
  def get_value_height(pdf)
    pdf.font(value_fonte) do
      return pdf.height_of("Une valeur")
    end
  end

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

  # --- Helpers --- #

  def render_as_label(pdf, label)
    # Pour exposer
    my = self

    if label_color
      original_color = pdf.fill_color
      pdf.fill_color(label_color)
    end
    # 
    # Écriture du label
    # 
    pdf.font(label_fonte)
    pdf.text(label, **{align: :center, leading: 2})
    # 
    # Remettre la couleur originale
    # 
    pdf.fill_color(original_color) if label_color
  end

  def render_as_value(pdf, info)
    pdf.font(value_fonte) do
      pdf.text(info, **{align: :center, leading: 0})
    end
  end

  # --- Données mises en forme --- #

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

  # -- Fonts Volatile Infos --

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
    def define_linear_delimitor
      unless defined?(LINEAR_DELIMITOR)
        Object.const_set('LINEAR_DELIMITOR', distributed? ? "\n" : " ")
      end
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
  #
  def human_for_patro(patro)
    patro.titleize
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
    disposition == 'distribute'
  end

  # -- Données pour l’aspect de la page de crédits --

  def disposition
    @disposition ||= credits_page[:disposition]
  end


end #/class PageInfos
end #/class Pages
end #/module Prawn4book
