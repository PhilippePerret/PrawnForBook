module Prawn4book
class PdfBook
class NTitre

  attr_accessor :page_numero

  def self.font_family(level)
    key = "level#{level}".to_sym
    data_titles[key] || init_data_title(key, level)
    data_titles[key][:font] || 'Arial'
  end

  def self.font_size(level)
    key = "level#{level}".to_sym
    data_titles[key] || init_data_title(key, level)
    data_titles[key][:size] || (11 + ( (8 - level) * 2.5)).to_i
  end

  def self.font_style(level)
    key = "level#{level}".to_sym
    data_titles[key] || init_data_title(key, level)
    data_titles[key][:style] || :normal
  end

  def self.margin_bottom(level)
    key = "level#{level}".to_sym
    data_titles[key] || init_data_title(key, level)
    data_titles[key][:margin_bottom] || 0
  end

  def self.margin_top(level)
    key = "level#{level}".to_sym
    data_titles[key] || init_data_title(key, level)
    data_titles[key][:margin_top] || 0
  end

  # Pour instancier un titre non défini
  def self.init_data_title(key, level)
    data_titles.merge!(key => {})
  end

  def self.data_titles
    @@data_titles ||= PdfBook.current.recette[:titles]
  end

  attr_reader :data

  def initialize(data)
    @data = data.merge!(type: 'titre')
  end

  # --- Helpers Methods ---

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

  # --- Predicate Methods ---

  def paragraph?; false end
  def titre?    ; true  end

  # --- Data Methods ---

  def level ; @level  ||= data[:level]  end
  def text  ; @text   ||= data[:text]   end

end #/class NTitre
end #/class PdfBook
end #/module Prawn4book
