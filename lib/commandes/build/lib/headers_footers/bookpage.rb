=begin
  
  class HeadersFooters::Disposition::BookPage

  Gestion des données de pages pour les headers et footers

=end
module Prawn4book
class HeadersFooters
class BookPage

  class << self
    def numero_page?
      @withnumeropage == true
    end
    def set_numero_page(value)
      @withnumeropage = value
    end
  end

  attr_reader :data

  ##
  # Instanciation
  # 
  # @param [Hash] data Données de la page
  # @option data [Integer] :numero Numéro de la page (1-based)
  # @option data [String|Nil] :title1   Nouveau grand titre
  # @option data [String|Nil] :current_title1 Grand titre courant (commencé sur une page précédente)
  # @option data [String|Nil] :title2   Nouveau titre de niveau 2 inauguré sur la page
  # @option data [String|Nil] :current_title2 Titre de niveau 2 courant (inauguré sur une page précédente)
  # @option data [String|Nil] :title3   Nouveau titre de niveau 3 inauguré sur la page
  # @option data [String|Nil] :current_title3 Titre de niveau 3 courant (inauguré sur une page précédente)
  # @option data [Integer|Nil] :first_par Indice du premier paragraphe de la page (if any)
  # @option data [Integer|Nil] :last_par Indice du dernier paragraphe de la page (if any)
  def initialize(data)
    @data = data
  end

  # - Helpers Methods -
  # 
  # Méthodes qui peuvent être utilisées dans le contenu d'un tiers
  # de header/footer pour le remplir

  # @return [String] Le vrai numéro de page, en fonction du type de
  # numérotation (par numéro de page ou numérotation de paragraph)
  # 
  # @api public
  def numero
    (self.class.numero_page? ? num_page : numero_paragraphs).to_s
  end

  # - Volatile Data -

  def numero_paragraphs
    @numero_paragraphs ||= "#{first_par || '-'}/#{last_par||'-'}"
  end

  # - Data -

  def num_page        ; @num_page       ||= data[:num_page]       end
  def first_par       ; @first_par      ||= data[:first_par]      end
  def last_par        ; @last_par       ||= data[:last_par]       end
  def title1          ; @title1         ||= data[:title1]         end
  def title2          ; @title2         ||= data[:title2]         end
  def title3          ; @title3         ||= data[:title3]         end
  def current_title1  ; @current_title1 ||= data[:current_title1] end
  def current_title2  ; @current_title2 ||= data[:current_title2] end
  def current_title3  ; @current_title3 ||= data[:current_title3] end


end #/class BookPage
end #/class HeadersFooters
end #/module Prawn4book
