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
  # @return [Integer] le dernier numéro de paragraphe (utilisé par
  # les titres pour connaitre le numéro de leur premier paragraphe)
  # @note
  #   Inauguré pour les références internes, pour que ça fonctionne
  #   avec le titre et une numérotation des paragraphes.
  def self.last_numero
    @@last_numero
  end


  #
  # Attention : ça n'est que le début commun de l'impression. Voir
  # dans chaque class les traitements particuliers.
  # 
  def print(pdf)
    # 
    # Indication de la première page du paragraphe (titre, images,
    # etc.)
    # 
    self.first_page = pdf.page_number
    # 
    # Préformatage, si c'est un texte
    # 
    preformate(pdf) if some_text?

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
      pdf.font(Prawn4book::Fonte.default_fonte) do
      # pdf.font(recipe.default_font_name, **{size:recipe.default_font_size}) do
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

  attr_reader :pdf

  attr_reader :pdfbook

  # @prop Première et dernière page du paragraphe
  attr_accessor :first_page
  attr_accessor :last_page
  attr_accessor :page_numero

  def initialize(pdfbook)
    @pdfbook = pdfbook
  end

  # --- Predicate Methods ---

  def titre?    ; false end
  def sometext? ; false end # surclassé par les filles
  alias :some_text? :sometext?
  def pfbcode?  ; false end
  def citation? ; false end
  def list_item?; false end 

  # Sera mis à true pour les paragraphes qui ne doivent pas être
  # imprimés, par exemple les paragraphes qui définissent des 
  # propriétés pour les paragraphes suivants.
  def not_printed?
    @isnotprinted === true
  end

  # --- Text Methods ---

  def text=(value); @text = value end


  # --- Méthodes d'aspect et de positionnement ---

  # - Alignement du texte -
  def text_align        ; @text_align || :justify end
  def text_align=(value); @text_align = value     end
  alias :alignment :text_align
  alias :align :text_align

  # - Marge haute du paragraphe (en nombre de lignes) -
  def margin_top ; @margin_top ||= (pfbcode && pfbcode[:margin_top]) || 0 end
  def margin_top=(value); @margin_top = value end

  # - Marge basse du paragraphe (en nombre de lignes) -
  def margin_bottom ; @margin_bottom ||= (pfbcode && pfbcode[:margin_bottom]) || 0 end

  def width
    @width ||= begin
      w = pfbcode && pfbcode[:width]
      if w
        if w.is_a?(String) && w.end_with?('%')
          w = pourcentage_to_pdfpoints(w, pdf.bounds.width)
        end
      end
      w
    end
  end

  def margin_left
    @margin_left ||= begin
      ml = margin_left_raw
      if ml
        if ml.is_a?(String) && ml.end_with?('%')
          ml = pourcentage_to_pdfpoints(ml, pdf.bounds.width)
        end
      end
      ml || 0
    end
  end
  def margin_left=(ml)
    if ml.is_a?(String) && ml.end_with?('%')
      ml = pourcentage_to_pdfpoints(ml, pdf.bounds.width)
    end
    @margin_left = ml
  end

  def margin_left_raw
    @margin_left_raw ||= pfbcode && pfbcode[:margin_left]
  end

  def margin_right
    @margin_right ||= 0
  end
  def margin_right=(mg)
    if mg.is_a?(String) && mg.end_with?('%')
      mg = pourcentage_to_pdfpoints(mg, pdf.bounds.width)
    end
   @margin_right = mg
  end


  # --- Volatile Data ---

  def pfbcode ; @pfbcode ||= data[:pfbcode] end

  def length  ; @length ||= text.length     end

  # --- Raccourcis ---

  # @shortcut
  def recipe; @recipe || pdfbook.recipe end


  private

  # --- Calcul Methods --- #

    ##
    # Reçoit une valeur par exemple en pourcentage ("50%") et 
    # retourne une valeur en points-pdf
    #
    # @param  value {String|Integer} Valeur pourcentage à calculer
    #               Soit le nombre (pe 50) soit le string (pe '50%')
    # @param  refval {Measurment} La valeur de référence. Par exemple
    #         la largeur de la page si on veut une valeur horizontale
    #         En d'autres termes, cette valeur correspond au 100 %
    def pourcentage_to_pdfpoints(value, refval)
      if value.is_a?(String)
        value = value[0..-2].to_i
      end
      refval * value / 100
    end


end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
