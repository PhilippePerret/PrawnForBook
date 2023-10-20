module Prawn4book
class PdfBook
class PageManager

  attr_reader :book, :pdf


  def initialize(book, pdf)
    @book = book
    @pdf  = pdf

    # -- Liste de toutes les pages --
    # ( instances PdfBook::Page )
    @pages = []

    # -- Liste des numéros de page sans pagination --
    @without_pagination = []
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
    @pages[number - 1]
  end

end #/class PageManager

# --- CLASS PdfBook::Page ---

class Page

  attr_reader :number
  attr_reader :titres

  def initialize(dpage)
    @number = dpage[:number]
    @titres = dpage[:titres]
  end

  def add_titre(level, titre_str)
    @titres.merge!( level => [] ) unless @titres.key?(level)
    @titres[level] << titre_str
  end

end

end #/class PdfBook
end #/module Prawn4book
