module Prawn4book
class Pages
class PageInfos

  # = main =
  #
  # Méthode principale construisant la page
  # 
  def build(pdf)
    spy "-> Construction de la page d'informations".bleu
    # 
    # S'assurer que les informations requises sont bien fournies
    # par la recette du livre ou de la collection
    # 
    infos_valides_or_raises
    # 
    # On définit le delimiteur linéaire en fonction de la disposition
    # des informations (un retour chariot en mode distribué, une 
    # espace dans les autres modes)
    # 
    define_linear_delimitor
    # 
    # Liste des informations à imprimer
    # 
    @infos_to_print = get_infos_to_print
    # 
    # On commence par se placer sur la bonne page
    # 
    pdf.update do
      start_new_page
      start_new_page if page_number.even?
    end
    # 
    # Pour appel dans pdf
    # 
    me = self
    #
    # Si on est en mode "réparti" (toutes les informations réparties
    # sur la page) alors il faut calculer les choses
    # 
    if mode_distributed?
      spy "Mode distribué".jaune
      dispose_element_on_surface(pdf)
      pdf.move_down(40)
    end
    # 
    # On peut construire la page en fonction des informations
    # 
    if mode_distributed?
      print_distributed(pdf)
    elsif mode_at_the_bottom?
      print_at_the_bottom(pdf)
    elsif mode_at_the_top?
      print_at_the_top(pdf)
    end

    spy "<- /Construction de la page d'informations".bleu
  end

  def print_distributed(pdf)
    # 
    # Boucle sur toutes les informations à imprimer
    # 
    @infos_to_print.each do |dinfo|
      case dinfo
      when :delimitor
        pdf.move_down(interstice_height)
      else
        if dinfo[:label]
          render_as_label(pdf, dinfo[:label])
        end
        render_as_value(pdf, dinfo[:value])
        pdf.move_down(interstice_height) unless dinfo[:no_space]
      end
    end    
  end

  def print_at_the_bottom(pdf)
    # 
    # Application de la font voulue
    # 
    # pdf.font(info_font, **{size: info_size, style: info_style})
    pdf.font(info_font, **{size: 9, style: info_style, leading: 0})
    #
    # On doit se placer assez haut pour tout écrire
    # 
    nombre_lignes = @infos_to_print.count + 4
    original_default_leading = pdf.default_leading
    pdf.default_leading = 0
    hauteur_ligne = pdf.height_of(@infos_to_print.first[:value])
    pdf.default_leading = original_default_leading
    top_cursor    = nombre_lignes * hauteur_ligne
    spy "Calcul du positionnement du début des informations…".jaune
    spy "(default_leading initial : #{original_default_leading})".gris
    spy "Hauteur ligne d'information   : #{hauteur_ligne}".bleu
    spy "Nombre de lignes (4 ajoutées) : #{nombre_lignes}".bleu
    spy "Placement du curseur          : #{top_cursor}".bleu
    pdf.move_cursor_to(top_cursor)
    # 
    # Boucle sur toutes les informations à imprimer, depuis l'endroit
    # où on s'est placé
    # 
    @infos_to_print.each do |dinfo|
      case dinfo
      when :delimitor then next
      else print_line(pdf, dinfo)
      end
    end
  end

  def print_at_the_top(pdf)
    # 
    # Application de la font voulue
    # 
    # pdf.font(info_font, **{size: info_size, style: info_style})
    pdf.font(info_font, **{size: 9, style: info_style})
    # 
    # Boucle sur toutes les informations à imprimer
    # 
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

  def dispose_element_on_surface(pdf)
    #
    # Surface sur laquelle pourront se mettre les informations si
    # on doit les répartir.
    # 
    surface_height = recipe.book_format[:book][:height]
    surface_height -= 40    # pour laisser encore de l'air au-dessus
    # 
    # Hauteur prise par un label
    # 
    height_for_label = get_label_height(pdf)
    # 
    # Hauteur prise par une valeur
    # 
    height_for_value = get_value_height(pdf)
    # 
    # On passe en revue toutes les infos pour voir l'espace total
    # qui restera et le répartir dans les interstices
    # 
    texte_height = 0
    nombre_interstices = 0
    @infos_to_print.each do |dinfo|
      if dinfo == :delimitor
        nombre_interstices += 1
      else
        texte_height += height_for_label unless dinfo[:label].nil?
        nombre_lignes = dinfo[:value].split("\n").count
        texte_height += height_for_value
        nombre_interstices += 1 unless dinfo[:no_space]
      end
    end
    # 
    # On calcule la hauteur des interstices
    # 
    @interstice_height = ((surface_height - texte_height) / nombre_interstices).round(3)

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
    pdf.font(label_font, **{size: label_size, style: label_style}) do
      return pdf.height_of("Label")
    end
  end
  def get_value_height(pdf)
    pdf.font(info_font, **{size: info_size, style: info_style}) do
      return pdf.height_of("Une valeur")
    end
  end

  # @return [Array] La liste des informations à afficher
  def get_infos_to_print
    ary = []
    [:name, :url, :adresse, :mail].each do |prop|
      if publisher[prop]
        value = if prop == :adresse
            publisher[prop].split("\\n").join(LINEAR_DELIMITOR)
          else
            publisher[prop]
          end
        ary << {label:nil, value: value, no_space: true}
      end
    end
    if publisher[:siret]
      ary << {label:nil, value: "SIRET : #{publisher[:siret]}", no_space: true}
    end
    ary[-1].merge!(no_space: false)
    ary << {label: 'Contact', value:publisher[:contact]} if publisher[:contact]
    ary << {value: "Dépôt légal : #{page_infos[:depot_legal]}"} if page_infos[:depot_legal]
    ary << {value:"ISBN : #{isbn}"} if isbn
    ary << :delimitor
    if conception_redaction
      ary << {label:'Conception & rédaction', value: conception_redaction}
    end
    if mise_en_page
      ary << {label:'Mise en page', value: mise_en_page}
    end
    ary << {label: 'Couverture', value: cover_conception}
    if relectures_et_corrections
      ary << {label: 'Correction & relecture', value:relectures_et_corrections}
    end
    ary << :delimitor
    ary << {label: 'Imprimé par', value: imprimerie}

    return ary
  end

  # --- Helpers --- #


  def render_as_label(pdf, label)
    if label_color
      original_color = pdf.fill_color
      pdf.fill_color label_color 
    end
    # 
    # Écriture du label
    # 
    pdf.font(label_font, **{size: label_size, style: label_style}) do
      pdf.text(label, **{align: :center, leading: 2})
    end
    # 
    # Remettre la couleur originale
    # 
    pdf.fill_color = original_color if label_color
  end

  def render_as_value(pdf, info)
    pdf.font(info_font, **{size: info_size, style: info_style}) do
      pdf.text(info, **{align: :center, leading: 0})
    end
  end

  # --- Données mises en forme --- #

  def conception_redaction
    @conception_redaction ||= begin
      if page_infos[:conception][:patro]
        traite_people_in(page_infos[:conception])
      end
    end
  end

  def mise_en_page
    @mise_en_page ||= begin
      if page_infos[:mise_en_page][:patro]
        traite_people_in(page_infos[:mise_en_page])
      end
    end
  end

  def cover_conception
    @cover_conception ||= begin
      if page_infos[:cover][:patro]
        traite_people_in(page_infos[:cover])
      end
    end
  end

  def relectures_et_corrections
    @relectures_et_corrections ||= begin
      if page_infos[:correction][:patro]
        traite_people_in(page_infos[:correction])
      end
    end
  end

  def imprimerie
    @imprimerie ||= begin
      dimp = page_infos[:printing]
      d = dimp[:name]
      d = "#{d} (#{dimp[:lieu]})" if dimp[:lieu]
      d
    end
  end

  def isbn
    @isbn ||= recipe.book_data[:isbn]
  end

  # --- General Data ---

  def page_infos
    @page_infos ||= recipe.page_infos
  end

  def publisher
    @publisher ||= recipe.publishing
  end


  private

    # En mode distribué, les labels et informations sont les unes
    # au-dessus des autres, les mails sont sous les noms, les 
    # adresses sont en lignes. Dans les autres modes, tout est sur
    # la même ligne. C'est la constante LINEAR_DELIMITOR, définie ici,
    # qui détermine ce comportement
    # 
    def define_linear_delimitor
      Object.const_set('LINEAR_DELIMITOR', mode_distributed? ? "\n" : " ")
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
      patro = "#{patro}#{LINEAR_DELIMITOR}(#{mails[idx]})" unless mails[idx].nil?
      patro
    end.pretty_join    
  end

  ##
  # Méthode qui s'assure que les informations ont bien été fournies
  # pour les informations.
  # 
  def infos_valides_or_raises
    infs = page_infos
    publ = owner.recipe.publishing
    # 
    # Les données qu'on doit trouver pour pouvoir établir la 
    # page d'informations
    # 
    missing_functions = []
    page_infos_missing_keys = []
    publishing_missing_keys = []
    [
      [ infs[:conception][:patro]   ,'le concepteur/rédacteur', "  conception:\n    patro: ..."],
      [ infs[:cover][:patro]        ,'le concepteur de la couverture', "  cover:\n    patro: ..."],
      [ infs[:correction][:patro]   ,'la correctrice', "  correction:\n    patro: ..."],
      [ infs[:mise_en_page][:patro] ,'le metteur en page', "  mise_en_page:\n    patro: ..."],
      [ infs[:printing][:name]      ,'l’imprimerie', "  printing:\n    name: ..." ],
      [ publ[:name]                  ,'la maison d’édition', nil, "#<publishing>\npublishing:\n  name: ...\n#</publishing>"],
    ].each do |value, fonction, page_infos_keys, publishing_keys|
      value || begin
        missing_functions.push(fonction)
        page_infos_missing_keys << page_infos_keys if page_infos_keys
        publishing_missing_keys << publishing_keys if publishing_keys
      end
    end
    missing_functions.empty? || begin
      unless page_infos_missing_keys.empty?
        page_infos_missing_keys.unshift("#<page_infos>\npage_infos:")
        page_infos_missing_keys << "#</page_infos>"
      end
      missing_keys = (page_infos_missing_keys + publishing_missing_keys).join("\n")
      raise FatalPrawForBookError.new(500, {missing_infos: missing_functions.pretty_join, missing_keys: missing_keys})
    end
  end

  def mode_distributed?
    disposition == 'distribute'
  end

  def mode_at_the_bottom?
    disposition == 'bottom'
  end

  def mode_at_the_top?
    disposition == 'top'
  end

  def disposition
    @disposition ||= page_infos[:aspect][:disposition]
  end

  def info_font
    @info_font ||= page_infos[:aspect][:value][:font]
  end
  def info_style
    @info_style ||= page_infos[:aspect][:value][:style]
  end
  def info_size
    @info_size ||= page_infos[:aspect][:value][:size]
  end

  def label_font
    @label_font ||= page_infos[:aspect][:libelle][:font]
  end
  def label_style
    @label_style ||= page_infos[:aspect][:libelle][:style]
  end
  def label_size
    @label_size ||= page_infos[:aspect][:libelle][:size]
  end
  def label_color
    @label_color ||= page_infos[:aspect][:libelle][:color]
  end

end #/class PageInfos
end #/class Pages
end #/module Prawn4book
