module Prawn4book
class PdfBook
class NTitre

  attr_reader :data

  def initialize(data)
    @data   = data.merge!(type: 'titre')
  end

  # --- Helpers Methods ---

  # @prop La taille de la police en fonction du niveau de titre
  # 
  def font_size
    @font_size ||= (11 + ( 8.0 / level) * 2).to_i
  end

  def font_style
    @font_style ||= begin
      case level
      when 1 then :bold
      when 2 then :normal
      else        :light
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
