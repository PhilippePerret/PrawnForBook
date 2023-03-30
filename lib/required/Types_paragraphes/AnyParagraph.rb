module Prawn4book
class PdfBook
class AnyParagraph

  # Méthodes utiles pour la numérotation
  # 
  # @note
  #   Elles sont mises ici, dans AnyParagraph, mais ne servent pour
  #   le moment que pour le NTextParagraph et le NTable (mais à 
  #   l'avenir, on peut imaginer qu'elles servent aussi pour les
  #   images, qui pourraient être aussi numérotées)
  @@last_numero = 0
  def self.reset
    @@last_numero = 0
  end
  def self.init_first_turn
    reset
  end
  def self.init_second_turn
    reset
  end
  def self.get_next_numero
    @@last_numero += 1
  end


  ##
  # Impression du numéro de paragraphe en regard du paragraphe
  # 
  def print_paragraph_number(pdf)
    numero = number.to_s
    
    #
    # Pour l'intérieur de pdf.update
    # 
    me = self

    pdf.update do

      # 
      # Fonte spécifique pour cette numérotation
      # 
      font(me.book.num_parag_font, size: me.book.num_parag_font_size) do
      
        # 
        # Calcul de la position du numéro de paragraphe en fonction du
        # fait qu'on se trouve sur une page gauche ou une page droite
        # 
        parag_number_width = width_of(numero)
        
        span_pos_num = 
          if belle_page?
            bounds.right + me.distance_from_text
          else
            - (parag_number_width + me.distance_from_text)
          end

        @span_number_width ||= 1.cm

        spy "Numéro #{numero} appliqué au paragraphe".orange
        spy "    @span_number_width = #{@span_number_width.inspect}".orange
        spy "    position: #{span_pos_num.inspect}".orange

        float {
          move_down(me.class.diff_height_num_parag_and_parag(pdf))
          span(@span_number_width, position: span_pos_num) do
            text "#{numero}", color: '777777'
          end
        }
      end #/font
    end    
  end

  def distance_from_text 
    @distance_from_text ||= book.recipe.parag_num_distance_from_text
  end

  # --- Print Data Methods --- #

  def self.diff_height_num_parag_and_parag(pdf)
    @@diff_height_num_parag_and_parag ||= begin
      recipe = pdf.pdfbook.recipe
      parag_height = nil
      numer_height = nil
      pdf.font(recipe.default_font_name, **{size:recipe.default_font_size}) do
        parag_height = pdf.height_of("Mot")
      end
      pdf.font(recipe.parag_num_font_name, **{size:recipe.parag_num_font_size}) do
        numer_height = pdf.height_of("194")
      end
      diff = (parag_height - numer_height).round(3)
      spy "Calcul de la différence entre fonte normale et numéro de paragraphe\n".jaune +
        "    parag_height = #{parag_height.inspect}\n".bleu +
        "    numer_height = #{numer_height.inspect}\n".bleu +
        "    diff         = #{diff.inspect}"
        "    Rectifié à   = #{diff - 1}"
      diff - recipe.parag_numero_vadjust
    end
  end

  attr_reader :pdfbook

  # @prop Première et dernière page du paragraphe
  attr_accessor :first_page
  attr_accessor :last_page
  attr_accessor :page_numero

  def initialize(pdfbook)
    @pdfbook = pdfbook
  end

  def titre?    ; false end
  def sometext? ; false end # surclassé par les filles
  alias :some_text? :sometext?
  def pfbcode?  ; false end

  # Sera mis à true pour les paragraphes qui ne doivent pas être
  # imprimés, par exemple les paragraphes qui définissent des 
  # propriétés pour les paragraphes suivants.
  def not_printed?
    @isnotprinted === true
  end

  def pfbcode
    @pfbcode ||= data[:pfbcode]
  end

  def length
    @length ||= text.length
  end

  # --- Cross-references Methods ---

  # Noter que ces méthodes, pour le moment, ne servent qu'à des fins
  # de check, pour voir si les références sont bien définies.

  # @return [Hash] Liste des références croisées que contient
  # le paragraphe (texte ou le titre). La clé  est l'identifiant
  # du livre (tel qu'il est défini dans la bibliographie des livres)
  # et la valeur est la liste des cibles de ce livre.
  def cross_references
    tbl = {}
    text.scan(REG_APPEL_CROSS_REFERENCE).to_a.each do |book_id, cible|
      tbl.key?(book_id) || tbl.merge!(book_id => [])
      tbl[book_id] << cible
    end
    return tbl
  end

  # @return [Boolean] True si le paragraphe (texte ou titre) contient
  # des références croisées
  # 
  def match_cross_reference?
    text.match?(/\( \->\((.+?):(.+?)\)/)
  end


REG_CIBLE_REFERENCE = /\(\( <\-\((.+?)\) \)\)/
REG_APPEL_REFERENCE = /\(\( \->\((.+?)\) +\)\)/
REG_APPEL_CROSS_REFERENCE = /\(\( \->\((.+?):(.+?)\) +\)\)/

end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
