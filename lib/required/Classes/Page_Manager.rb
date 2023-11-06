module Prawn4book
class PdfBook
class PageManager

  attr_reader :book, :pdf
  attr_reader :pages
  attr_reader :without_pagination

  def initialize(book, pdf)
    @book = book
    @pdf  = pdf

    # -- Liste de toutes les pages --
    # ( instances PdfBook::Page )
    @pages = []

    # -- Liste des numéros de page sans pagination --
    @without_pagination = []
  end

  # Boucle sur toutes les pages (dans l'ordre)
  # 
  def each(&block)
    if block_given?
      @pages.each { |page| yield page }
    end
  end

  # Ajoute une page au livre (une vraie page physique)
  # 
  # @param data_page [Hash]
  # 
  #   @option :number   [Integer] Numéro de page
  #   TODO : 
  #     - premier paragraphe
  #     - autres informations
  def add(data_page)
    pages << Page.new(data_page)
  end
  alias :<< :add

  # @return [PdfBook::Page] la page de numéro +number+
  # 
  def [](number)
    @pages[number - 1] || begin
      # Quand le numéro dépasse le nombre de pages, c'est qu'on est
      # dans un deuxième tour. On doit signaler une erreur, mais on
      # essaie quand même de prendre la page correspondante. Par exem-
      # ple, s'il y a 30 pages et qu'on demande la page 31, ça cor-
      # respond à la première page, c'est-à-dire la page :
      #      num-demandé - nombre-pages - 1
      #   =>     31           - 30      - 1
      #   => 0
      # 
      add_erreur <<~ERR
        Le numéro de page #{number.inspect} est introuvable.
        Je rectifie le numéro en fonction du nombre de pages (#{@pages.count}), mais il faudra corriger le problème car les effets indésirables sont imprévisibles.
        ERR
      correct_num = number - @pages.count
      @pages[correct_num]
    end
  end

end #/class PageManager

# --- CLASS PdfBook::Page ---

class Page

  attr_reader :data
  attr_reader :number
  attr_reader :titres

  def initialize(dpage)
    @data           = dpage
    @number         = dpage[:number]
    @titres         = dpage[:titres]
    @has_pagination = true
  end

  #
  # @note
  #   @titres contient l'état actuel des 6 niveaux de titre
  # 
  def add_titre(level, titre_str)
    @titres.merge!( level => [] ) unless @titres.key?(level)
    @titres[level] << titre_str
    data[:content_length] += titre_str.length
  end

  def no_content?
    data[:content_length] == 0 && data[:first_par].nil?
  end
  alias :empty? :no_content?

  def no_pagination?
    @has_pagination === false
  end

  def pagination=(value)
    @has_pagination = value
  end

  def [](key)
    return data[key]
  end

  def []=(key, value)
    data[key] = value
    instance_variable_set("@#{key}", value)
  end

end

end #/class PdfBook
end #/module Prawn4book
