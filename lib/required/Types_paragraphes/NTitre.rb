require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class NTitre < AnyParagraph

  attr_accessor :page_numero

  attr_reader :data

  def initialize(pdfbook, data)
    super(pdfbook)
    @data = data.merge!(type: 'titre')
  end

  def leading
    @leading ||= self.class.leading(level)
  end

  def font_family
    @font_family ||= self.class.font_family(level)
  end
  # @prop La taille de la police en fonction du niveau de titre
  # 
  def font_size
    @font_size ||= self.class.font_size(level)
  end

  def font_style
    @font_style ||= self.class.font_style(level)
  end

  # @prop {Integer} Espace avec le texte suivant
  def lines_after
    @lines_after ||= self.class.lines_after(level)
  end

  # @prop {Integer} Espace avec le texte précédent
  def lines_before
    @lines_before ||= self.class.lines_before(level)
  end

  # --- Predicate Methods ---

  def next_page?
    :TRUE == @onnewpage ||= true_or_false(self.class.next_page?(level))
  end

  def belle_page?
    :TRUE == @onbellepage ||= true_or_false(self.class.belle_page?(level))
  end

  def paragraph?; false end
  def titre?    ; true  end

  # --- Data Methods ---

  def level ; @level  ||= data[:level]  end
  def text  ; @text   ||= data[:text]   end


  # --- MÉTHODES DE CLASSES ---

  def self.font_family(level)
    get_data(:font, level)
  end

  def self.font_size(level)
    get_data(:size, level)
  end

  def self.font_style(level)
    get_data(:style, level)
  end

  def self.lines_after(level)
    get_data(:lines_after, level)
  end

  def self.lines_before(level)
    get_data(:lines_before, level)
  end

  def self.leading(level)
    get_data(:leading, level)
  end

  def self.next_page?(level)
    val = get_data(:next_page, level) === true
    return val
  end

  def self.belle_page?(level)
    get_data(:belle_page, level) === true
  end

  ##
  # @return [Any] La valeur +property+ pour le niveau de titre
  # +level+
  def self.get_data(property, niveau)
    key_niveau = :"level#{niveau}"
    unless data_titles[key_niveau].key?(property)
      spy "data_titles[key_niveau] ne connait que les clés : #{data_titles[key_niveau].keys.inspect}".rouge
      exit
    end
    return data_titles[key_niveau][property]
  end

  def self.data_titles
    @@data_titles ||= PdfBook.current.recette.titles_data
  end

end #/class NTitre
end #/class PdfBook
end #/module Prawn4book
