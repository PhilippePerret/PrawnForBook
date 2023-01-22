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

  attr_reader :book, :pdf
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
  def initialize(book, pdf, data)
    @book = book
    @pdf  = pdf
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
    if no_num_if_empty? && empty?
      ''
    else
      (self.class.numero_page? ? num_page : numero_paragraphs).to_s
    end
  end

  # @return [String] Les titres courants.
  # 
  # @ATTENTION
  #   Il ne faut pas confondre cette propriété avec l'attribut :title1
  #   des données, qui n'est défini que si un nouveau titre est 
  #   présent sur la page. Ici, il s'agit du grand titre courant,
  #   même s'il a été inauguré 10 pages plus tôt.
  # 
  # @api public
  def title1
    @title1 ||= data[:title1] || data[:current_title1]
  end
  def title2
    @title2 ||= data[:title2] || data[:current_title2]
  end
  def title3
    @title3 ||= data[:title3] || data[:current_title3]
  end

  # - Precidate Methods -

  # @return true si la page est vide
  def empty?
    content_length == 0
  end

  # @return true si on ne doit pas inscrire de numéro quand la page 
  # est vide
  def no_num_if_empty?
    book.recipe.no_numero_on_empty_page?
  end

  # @return true si on ne doit numéroter que lorsqu'il y a des 
  # paragraphes
  def num_only_if_num?
    book.recipe.numero_paragraph_only_if_paragraph?
  end

  # @return true si on doit mettre le numéro de la page quand il n'y 
  # a pas de paragraphes
  def num_page_if_no_num?
    book.recipe.numero_page_if_no_numero_paragraph?
  end

  def no_num?
    first_par.nil? && last_par.nil?    
  end

  # - Volatile Data -

  def numero_paragraphs
    @numero_paragraphs ||= begin
      if empty? && no_num_if_empty?
        ''
      elsif no_num? && num_only_if_num?
        if num_page_if_no_num?
          num_page
        else
          ''
        end
      else
        format_numero_paragraphs % {first: (first_par||'-'), last:(last_par||'-')}
      end
    end
  end


  # - Volatile Data -

  def format_numero_paragraphs
    @format_numero_paragraphs ||= begin
      if book.recipe.format_numero
        book.recipe.format_numero.gsub(/first/,'%{first}').gsub(/last/,'%{last}')
      else
        '%{first}/%{last}'
      end
    end
  end

  # - Data -

  def num_page        ; @num_page       ||= data[:num_page]       end
  def first_par       ; @first_par      ||= data[:first_par]      end
  def last_par        ; @last_par       ||= data[:last_par]       end
  def content_length  ; @content_length ||= data[:content_length].to_i end


end #/class BookPage
end #/class HeadersFooters
end #/module Prawn4book
