=begin

  class Prawn4book::HeadersFooters::Headfooter
  --------------------------------------------
  En tant que classe, elle consigne les données des headfooters
  En tant qu'instance, c'est la classe abstraite des classes filles
  Header(s) et Footer(s).

=end
module Prawn4book
class HeadersFooters
class Headfooter
###################       CLASSE      ###################
class << self
  ##
  # @return [Hash] la table de donnée du headfooter d'identifiant
  # +hf_id+
  # 
  # @note
  #   Comme l'utilisateur peut les définir à la main, on s'assure de
  #   pouvoir les trouver, avec l'identifiant symbolique ou string
  # 
  def get(hf_id)
    data[hf_id.to_s] || data[hf_id.to_sym] || raise("L'headfooter d'identifiant #{hf_id.inspect} est inconnu…")
  end
  # Les données des headfooters (telles qu'elles sont définies
  # dans la propriété :headers_footers de la recette du livre)
  def data=(value)  ; @data = value   end
  def data          ; @data           end
end #/ << self

################### INSTANCE (Abstract Class)   ###################
  attr_reader :data

  # @prop [Disposition] La disposition qui utilise ce headfooter
  attr_reader :disposition

  # @props Le livre et le pdf (hérités de la disposition)
  attr_reader :book, :pdf

  def initialize(disposition, data)
    @data         = data
    @disposition  = disposition
    # - raccourcis -
    @book         = disposition.book
    @pdf          = disposition.pdf
  end

  ##
  # Construction de l'headfooter
  # 
  def build
    spy "-> Construction de l'headfooter <<#{name}>> (ID #{id})".jaune
    build_even_pages if pd_left || pd_right || pd_center
    build_odd_pages  if pg_left || pg_right || pg_center
    spy "<- /fin construction headfooter ID #{id}".jaune
  end

  ##
  # Construction de l'headfooter sur les pages paires
  #
  def build_even_pages
    build_pages(:even)
  end
  ##
  # Construction de l'headfooter sur les pages impaires
  # 
  def build_odd_pages
    build_pages(:odd)
  end

  # @param [Symbol] side Soit :even soit :odd
  def build_pages(side)
    spy "   * Construction pages #{side.inspect}".jaune
    pdf.repeat(side, **{dynamic: true}) do
      numero = pdf.page_number
      next unless page_in_range?(numero)
      bpage = get_data_page(numero)  # instance BookData
      procedure = self.send("procedure_#{side}_page".to_sym)
      procedure.call(bpage)
      spy "Page #{numero} traitée".vert
    end
  end

  def procedure_even_page
    @procedure_even_page ||= procedure_any_page(pg_left, pg_center, pg_right, :even)
  end
  def procedure_odd_page
    @procedure_odd_page ||=  procedure_any_page(pd_left, pd_center, pd_right, :odd)
  end

  def procedure_any_page(dleft, dcenter, dright, side)
    # 
    # Procédure (vide) pour mettre les autres
    # 
    proce = Proc.new { |bpage| bpage }
    # 
    # On ajoute tous les tiers nécessaires
    # 
    if dleft
      procleft = Proc.new { |bpage|
        build_tiers(bpage, [0, top], dleft)
      }
      proce = (proce << procleft)
    end
    if dcenter
      proccenter = Proc.new { |bpage|
        build_tiers(bpage, [tiers, top], dcenter)
      }
      proce = (proce << proccenter)
    end
    if dright
      procright = Proc.new { |bpage|
        build_tiers(bpage, [2 * tiers, top], dright)
      }
      proce = (proce << procright)
    end
    proce
  end

  ##
  # Méthode qui dessine véritablement le tiers du headfooter
  # 
  # @return [BookPage] La page (pour l'addition des procédures)
  def build_tiers(bpage, at, dtiers)
    props = common_tiers_props.merge({at:at, align: dtiers[:align]})
    # 
    # Le contenu textuel
    # 
    content = case dtiers[:content]
    when String   then get_content_as_custom_text(dtiers[:content])
    when Numeric  then dtiers[:content].to_s
    when Symbol   then bpage.send(dtiers[:content])
    when Proc     then dtiers[:content].call(bpage)
    end.to_s # peut être vide
    content = case dtiers[:casse]
    when :all_caps then content.upcase 
    when :all_min  then content.downcase
    else content
    end
    # 
    # La fonte à appliquer
    # 
    font_props = {size: font_size(dtiers)}
    font_props.merge!(style: font_style(dtiers)) if font_style(dtiers)
    pdf.font(font_name(dtiers), **font_props) do
      pdf.text_box(content, **props)
    end
    # 
    # On retourne la page pour l'addition des procédures
    # 
    return bpage
  end

  ## 
  # Si le texte personnalisé contient du code ou des variables, il
  # faut l'estimer.
  # 
  # @return [String] Le texte à écrire dans le headfooter
  # 
  # @param [String] str Le texte original tel que défini dans la recette
  def get_content_as_custom_text(str)
    if str.match?(/#\{/)
      return eval('"' + str + '"')
    else
      str
    end
  end

  def common_tiers_props
    @common_tiers_props ||= begin
      spy "#{'Calcul de la hauteur'.jaune} : #{height.inspect}".bleu
      {height: height, width: tiers, size: font_size}
    end
  end

  # @prop [Float] Retourne le nombre de points-post-script pour le
  # document courant, pour un tiers de page.
  def tiers
    @tiers ||= (pdf.bounds.width.to_f / 3).round(6)
  end

  def font_name(dtiers = {})
    dtiers[:font] || @font_name ||= (font || 'Times-Roman')
  end
  def font_size(dtiers = {})
    dtiers[:size] || @font_size ||= (size || 10)
  end
  def font_style(dtiers = {})
    dtiers[:style] || @font_style ||= style # peut être nil
  end

private

  # @eturn [Boolean] true si la page de numéro +num+ est dans le
  # rang des pages à prendre
  # @note
  #   Cela dépend de la disposition
  def page_in_range?(num)
    return num >= disposition.first_page && num <= disposition.last_page
  end

  # - Data Methods -

  # @return [Integer] La hauteur du pied de page ou de l'entête en
  # fonction du contenu des tiers. On prend le tiers le plus grand.
  def height
    @height ||= begin
      max_height = 0
      [ 
        :pg_left, :pg_center, :pg_right, 
        :pd_left, :pd_center, :pd_right
      ].each do |tiers|
        dtiers = self.send(tiers)
        next if dtiers.nil?
        tiers_height = get_height_of_tiers(dtiers)
        max_height = tiers_height if tiers_height > max_height
      end
      max_height.ceil
    end
  end

  def get_height_of_tiers(dtiers)
    fprops = {size: font_size(dtiers)}
    fprops.merge!(style: font_style(dtiers)) if font_style(dtiers)
    pdf.font(font_name(dtiers)) do
      return pdf.height_of("MAXq")
    end
  end

  # @return [Hash] La table des données de la page de numéro 
  # +page_num+
  # 
  def get_data_page(page_num)
    disposition.data_pages[page_num]
  end

  # - Data -

  def id            ; @id           ||= data[:id]         end
  def name          ; @name         ||= data[:name]       end
  def font          ; @font         ||= data[:font]       end
  def size          ; @size         ||= data[:size]       end
  def style         ; @style        ||= data[:style]      end
  # - page gauche (pg_) -
  def pg_left       ; @pg_left      ||= data[:pg_left]    end
  def pg_right      ; @pg_right     ||= data[:pg_right]   end
  def pg_center     ; @pg_center    ||= data[:pg_center]  end
  # - page droite (pd_) -
  def pd_left       ; @pd_left      ||= data[:pd_left]    end
  def pd_right      ; @pd_right     ||= data[:pd_right]   end
  def pd_center     ; @pd_center    ||= data[:pd_center]  end

end #/class Headfooter
end #/class HeadersFooters
end #/module Prawn4book
