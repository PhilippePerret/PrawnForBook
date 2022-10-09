module Prawn4book
class PdfBook
class NTitre

  def self.font_size(level)
    @@data_font_size ||= {}
    @@data_font_size[level] ||= begin
      data_titles["level#{level}".to_sym][:size] || (11 + ( (8 - level) * 2.5)).to_i
    end    
  end

  def self.data_titles
    @@data_titles ||= PdfBook.current.recette[:titles]
  end

  attr_reader :data

  def initialize(data)
    @data   = data.merge!(type: 'titre')
  end

  # --- Helpers Methods ---

  # @prop La taille de la police en fonction du niveau de titre
  # 
  def font_size
    @font_size ||= self.class.font_size(level)
  end

  def font_style
    @font_style ||= begin
      case level
      when 1 then :bold
      when 2 then :normal
      else        :normal
      end
    end
  end

  # @prop {Integer} Espace avec le texte suivant
  def margin_bottom
    @margin_bottom ||= [nil, 50, 35, 15][level]
  end

  # --- Predicate Methods ---

  def level ; @level  ||= data[:level]  end
  def text  ; @text   ||= data[:text]   end

end #/class NTitre
end #/class PdfBook
end #/module Prawn4book
