module Prawn4book
class PdfBook
class PageManager

  attr_reader :book, :pdf
  attr_reader :pages

  def initialize(book, pdf)
    @book = book
    @pdf  = pdf

    # -- Liste de toutes les pages --
    # ( instances PdfBook::Page )
    @pages = []

  end

  # @return le nombre de page
  # 
  def count
    @pages.count
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
  # 
  def add(data_page)
    pages << Page.new(Marshal.load(Marshal.dump(data_page)))
    if pages[-1].number != pages.count
      puts "Mauvais numéro de page dans add. Ne devrait jamais arriver".rouge
      exit 114
    end
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

      # Le backtrace pour savoir d’où on vient
      bt = caller.map do |str|
        if str.match?(APP_FOLDER)
          str.sub(APP_FOLDER,'.')
        end
      end.compact[0..-6].join("\n")

      # L’erreur générée
      add_erreur(PFBError[200] % {
        num: number.inspect, 
        nb: count,
        bt: bt
      }) 
      correct_num = number - @pages.count
      @pages[correct_num]
    end
  end #/[]
  alias :page :[] # pour faire book.pages.page(x)

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
    init_content
  end

  # Ajoute un titre à la page
  # 
  def add_titre(level, titre_str)
    @own_titles << {title: titre_str, level: level}
  end

  # Définit les titres courants de la page
  # 
  # @note
  #   @titres contient l'état actuel des 6 niveaux de titre
  #   Bien faire la différence entre @titres, qui contient les titres
  #   en cours sur la page, même s’ils ont été "déclarés" des dizaines
  #   de pages avant, et @own_titles qui définit les titres que la
  #   page contient réellement, qui sont imprimés sur elle.
  # 
  def set_current_titles(les_titres)
    @titres = les_titres
  end

  def add_content_length(len)
    data[:content_length] += len
  end

  # Si deuxième tour, on remet la page à 0-content à sa création
  def init_content
    data.merge!(content_length: 0, first_par:nil)
    @own_titles = [] # les titres propres à la page
  end

  # @return true si la page peut recevoir une entête et/ou un pied
  # de page, c’est-à-dire si ça n’est pas juste une page de titre ou
  # une page vide
  def printable?
    not(not_printable?)
  end

  # @return true si la page ne contient rien, ni titre ni aucun
  # texte.
  def empty?
    no_content? && no_title?
  end

  # @return true si la page n’est pas vierge, c’est-à-dire si elle 
  # contient au moins un titre et un court texte
  def not_empty?
    not(empty?)
  end

  # @return True si c’est une page vierge, une page ne contenant 
  # qu’un titre ou une page marquée explicitement à ne pas paginer
  def not_printable?
    no_content? || no_pagination? || title_only?
  end

  def no_content?
    data[:content_length] == 0 && data[:first_par].nil? && no_title?
  end
  alias :empty? :no_content?

  def no_pagination?
    @has_pagination === false
  end

  def no_title?
    @own_titles.count == 0
  end

  # @return true si la page ne contient qu’un titre
  def title_only?
    @own_titles.count == 1 && data[:content_length] == 0
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

end #/class Page
end #/class PdfBook
end #/module Prawn4book
