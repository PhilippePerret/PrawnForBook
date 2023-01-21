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
      bookpage = get_data_page(pdf.page_number) # instance BookData
    end
  end 

  ##
  # Construction de l'header sur les pages impaires
  # 
  def build_odd_pages
    spy "   * Construction pages impaires".jaune
    pdf.repeat(:odd, **{dynamic: true}) do
      bookpage = get_data_page(pdf.page_number)  # instance BookData

    end
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
