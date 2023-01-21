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
    spy "   * Construction pages paires…".jaune
    pdf.repeat(:even, **{dynamic: true}) do
      numero = pdf.page_number
      next unless page_in_range?(numero)
      bpage = get_data_page(numero) # instance BookData
      procedure_even_page.call(bpage) 
      spy "Page #{numero} traitée".vert
    end
  end
  def procedure_even_page
    @procedure_even_page ||= begin
      # 
      # Propriétés par défaut pour tous les text-box
      # 
      cusdata = {height: 20, width: tiers, size: font_size}
      # 
      # Procédure (vide) pour mettre les autres
      # 
      proce = Proc.new { |bpage| bpage }
      # 
      # On ajoute tous les tiers nécessaires
      # 
      if pd_left
        procleft = Proc.new { |bpage|
          props = cusdata.merge({at:[0, top], align: pd_left[:align]})
          pdf.text_box(bpage.send(pd_left[:content]), **props)
          bpage
        }
        proce = (proce << procleft)
      end
      if pd_center
        proccenter = Proc.new { |bpage|
          props = cusdata.merge({at:[tiers, top], align: pd_center[:align]})
          pdf.text_box(bpage.send(pd_center[:content]), **props)
          bpage
        }
        proce = (proce << proccenter)
      end
      if pd_right
        procright = Proc.new { |bpage|
          props = cusdata.merge({at:[2 * tiers, top], align: pd_right[:align]})
          pdf.text_box(bpage.send(pd_right[:content]), **props)
          bpage
        }
        proce = (proce << procright)
      end
      proce
    end
  end

  # @prop [Float] Retourne le nombre de points-post-script pour le
  # document courant, pour un tiers de page.
  def tiers
    @tiers ||= (pdf.bounds.width.to_f / 3).round(6)
  end

  def font_size
    @font_size ||= 16 # TODO À RÉGLER
  end

  ##
  # Construction de l'header sur les pages impaires
  # 
  def build_odd_pages
    spy "   * Construction pages impaires".jaune
    pdf.repeat(:odd, **{dynamic: true}) do
      numero = pdf.page_number
      next unless page_in_range?(numero)
      bpage = get_data_page(numero)  # instance BookData

      spy "Page #{numero} traitée".vert
    end
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
