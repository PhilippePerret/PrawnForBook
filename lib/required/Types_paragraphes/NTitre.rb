require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class NTitre < AnyParagraph

  attr_accessor :page_numero

  attr_reader :data

  def initialize(data)
    @data = data.merge!(type: 'titre')
  end

  # --- Predicate Methods ---

  def next_page?
    :TRUE == @onnewpage ||= true_or_false(self.class.next_page?(level))
  end

  def titre?; true end

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
  def margin_bottom
    @margin_bottom ||= self.class.margin_bottom(level)
  end

  # @prop {Integer} Espace avec le texte précédent
  def margin_top
    @margin_top ||= self.class.margin_top(level)
  end

  # --- Predicate Methods ---

  def paragraph?; false end
  def titre?    ; true  end

  # --- Data Methods ---

  def level ; @level  ||= data[:level]  end
  def text  ; @text   ||= data[:text]   end


  # --- MÉTHODES DE CLASSES ---

  def self.font_family(level)
    get_recipe(:font, level, DEFAULT_FONT)
  end

  def self.font_size(level)
    get_recipe(:size, level, (11 + ( (8 - level) * 2.5)).to_i)
  end

  def self.font_style(level)
    get_recipe(:style, level, :normal)
  end

  def self.margin_bottom(level)
    get_recipe(:margin_bottom, level, 0)
  end

  def self.margin_top(level)
    get_recipe(:margin_top, level, 0)
  end

  def self.leading(level)
    get_recipe(:leading, level, 0)
  end

  def self.next_page?(level)
    get_recipe(:next_page, level, false) === true
  end

  def self.get_recipe(property, level, default_value)
    key = "level#{level}".to_sym
    data_titles[key] || init_data_title(key, level)
    data_titles[key][property] || default_value
  end

  # Pour instancier un titre non défini
  def self.init_data_title(key, level)
    data_titles.merge!(key => {})
  end

  def self.data_titles
    @@data_titles ||= PdfBook.current.recette[:titles] || {}
  end

end #/class NTitre
end #/class PdfBook
end #/module Prawn4book
