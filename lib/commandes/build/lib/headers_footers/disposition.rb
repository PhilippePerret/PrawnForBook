module Prawn4book
class HeadersFooters
class Disposition

  # Données de la disposition
  # Cf. initialize pour le détail
  attr_reader :data

  # Le livre et le pdf hérités du constructeur principal (headersfooters)
  attr_reader :book, :pdf

  # @param [Prawn4book|HeadersFooters] Le constructeur principal
  # @param [Hash] data Données telles que définies dans la recette
  #     du livre si les pieds de page et entêtes sont définis
  # @option data [Symbol] :id Identifiant de la disposition
  # @option data [String] :name Nom humain pour cette disposition
  # @option data [Symbol|Nil] :footer_id ID du footheader utilisé en pied de page pour cette disposition, s'il y a un pied de page dans les pages
  # @option data [Symbol|Nil] :header_id ID du footheader utilisé en entête pour cette disposition s'il y un entête dans les pages
  # @option data [Integer] :first_page Première page qui utilise cette disposition
  # @option data [Integer] :last_page Dernière page qui utilise cette disposition
  # 
  def initialize(headersfooters, data)
    @headersfooters = headersfooters
    @data = data
    @book = headersfooters.book
    @pdf  = headersfooters.pdf
  end

  # = main =
  # 
  # Construction de la disposition courante (header et footer)
  # 
  def build
    spy "-> Construction de la disposition <<#{name}>>".jaune
    build_header if header_id
    build_footer if footer_id
    spy "<- /fin construction disposition <<#{name}>>".jaune
  end

  ##
  # Construction de l'entête (sur toutes les pages)
  def build_header
    headfoot = Header.new(self, Headfooter.get(header_id))
    headfoot.build
  end
  ##
  # Construction du pied de page (sur toutes les pages)
  def build_footer
    headfoot = Footer.new(self, Headfooter.get(footer_id))
    headfoot.build
  end

  # - Shortcuts -

  def data_pages ; @headersfooters.data_pages end

  # - Data -
  # (cf. initialize)

  def id              ; @id               ||= data[:id]                 end
  def name            ; @name             ||= data[:name]               end
  def footer_id       ; @footer_id        ||= data[:footer_id]          end
  def footer_vadjust  ; @footer_vadjust   ||= data[:footer_vadjust]||0  end
  def header_vadjust  ; @header_vadjust   ||= data[:header_vadjust]||0  end
  def header_id       ; @header_id        ||= data[:header_id]          end
  def first_page      ; @first_page       ||= data[:first_page]||1      end
  def last_page       ; @last_page        ||= data[:last_page]||100000  end

end #/class Disposition
end #/class HeadersFooters
end #/module Prawn4book
