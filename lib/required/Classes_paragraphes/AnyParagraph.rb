module Prawn4book
class PdfBook
class AnyParagraph

  # Liste des balises de style de paragraphe
  attr_accessor :class_tags

  # [Hash] Table des spécifications finales pour l'impression du
  # paragraphe (quel qu'il soit)
  # Permet par exemple de consigner :size ou :font_size pour la 
  # taille courante de police (qui peut être définie par pfbcode, le
  # code qui précède le paragraphe.
  # @OBSOLÈTE Doit être remplacé par la propriété @style
  attr_accessor :final_specs

  # Méthodes utiles pour la numérotation
  # 
  # @note
  #   Elles sont mises ici, dans AnyParagraph, mais ne servent pour
  #   le moment que pour le NTextParagraph et le NTable (mais à 
  #   l'avenir, on peut imaginer qu'elles servent aussi pour les
  #   images, qui pourraient être aussi numérotées)
  def self.reset
    reset_numero
  end
  @@last_numero = 0
  def self.reset_numero
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
  def self.get_current_numero
    @@last_numero
  end
  # @return [Integer] le dernier numéro de paragraphe (utilisé par
  # les titres pour connaitre le numéro de leur premier paragraphe)
  # @note
  #   Inauguré pour les références internes, pour que ça fonctionne
  #   avec le titre et une numérotation des paragraphes.
  def self.last_numero
    @@last_numero
  end


  # @return true si un parseur de paragraphe customisé est utilisé
  # (il existe quand un fichier parser.rb, propre au film et/ou à la
  #  collection définit la méthode ParserParagraphModule::paragraph_parser
  #  donc self.paragraph_parser dans le module ParserParagraphModule
  #  cf. le manuel pour le détail)
  def self.has_custom_paragraph_parser?
    @@custom_paragraph_parser_exists == true
  end
  def self.custom_paragraph_parser_exists=(value)
    @@custom_paragraph_parser_exists = value
  end


  #
  # Attention : ça n'est QUE le début commun de l'impression. Voir
  # dans chaque class les traitements particuliers.
  # 
  def print(pdf)
    # 
    # Indication de la première page du paragraphe (titre, images,
    # etc.)
    # 
    self.first_page = pdf.page_number

    if some_text?
      # 
      # Formatage général
      # 
      context = { pdf: pdf, paragraph:self }
      @text = self.class.__parse(text, context)
    end

  end


  ##
  # Impression du numéro de paragraphe en regard du paragraphe
  # 
  def print_paragraph_number(pdf)

    num = numero.to_s
    
    #
    # Pour l'intérieur de pdf.update
    # 
    me = self

    pdf.update do

      # 
      # Fonte spécifique pour cette numérotation
      # 
      font(me.recipe.parag_num_font_name, size: me.recipe.parag_num_font_size) do
      
        # 
        # Calcul de la position du numéro de paragraphe en fonction du
        # fait qu'on se trouve sur une page gauche ou une page droite
        # 
        parag_number_width = width_of(num)
        
        span_pos_num = 
          if belle_page?
            bounds.right + me.distance_from_text
          else
            - (parag_number_width + me.distance_from_text)
          end

        @span_number_width ||= 1.cm

        spy "Numéro #{num} appliqué au paragraphe".orange
        spy "    @span_number_width = #{@span_number_width.inspect}".orange
        spy "    position: #{span_pos_num.inspect}".orange

        float {
          move_down(me.class.diff_height_num_parag_and_parag(pdf))
          span(@span_number_width, position: span_pos_num) do
            text "#{num}", color: me.parag_numero_color
          end
        }
      end #/font
    end    
  end

  def distance_from_text 
    @distance_from_text ||= book.recipe.parag_num_distance_from_text
  end

  def parag_numero_color
    @parag_numero_color ||= begin
      self.class.paragraph_numero_color(book.recipe.parag_num_strength)
    end
  end

  # --- Print Data Methods --- #

  def self.paragraph_numero_color(strength)
    @@paragraph_numero_color ||= begin
      (((100 - strength) * 255 / 100).to_s(16).upcase.rjust(2,'0') * 3 ).tap { |n| add_notice("Couleur : #{n}") }
      # => p.e. "030303" ou "CCCCCC"
    end
  end


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
        "    diff         = #{diff.inspect}".bleu +
        "    Rectifié à   = #{diff - 1}".bleu
      diff - recipe.parag_num_vadjust
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

  def font_size
    @font_size ||= style[:font_size] || recipe.default_font_size
  end

  def font_family
    @font_family ||= style[:font_family] || recipe.default_font_family
  end

  def font_style
    @font_style ||= style[:font_style] || recipe.default_font_style
  end

  # - Alignement du texte -
  def text_align
    @text_align || style[:align] ||style[:text_align] || :justify 
  end
  def text_align=(value); @text_align = value     end
  alias :alignment :text_align
  alias :align :text_align

  # - Marge haute du paragraphe (en nombre de lignes) -
  def margin_top
    @margin_top ||= style[:margin_top] || 0 
  end
  def margin_top=(value); @margin_top = value end

  # - Marge basse du paragraphe (en nombre de lignes) -
  def margin_bottom
    @margin_bottom ||= style[:margin_bottom] || 0 
  end

  def margin_left
    @margin_left ||= style[:margin_left] || begin
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
    @margin_right ||= style[:margin_right] || 0
  end
  def margin_right=(mg)
    if mg.is_a?(String) && mg.end_with?('%')
      mg = pourcentage_to_pdfpoints(mg, pdf.bounds.width)
    end
   @margin_right = mg
  end

  def kerning?
    not(kerning.nil?)
  end
  def kerning
    style[:kerning]
  end

  def character_spacing?
    not(character_spacing.nil?)
  end
  def character_spacing
    style[:character_spacing]
  end

  def width
    @width ||= style[:width] || begin
      w = pfbcode && pfbcode[:width]
      if w
        if w.is_a?(String) && w.end_with?('%')
          w = pourcentage_to_pdfpoints(w, pdf.bounds.width)
        end
      end
      w
    end
  end


  # --- Volatile Data ---

  ##
  # Style précis du paragraphe
  # 
  # Est censé contenir tout ce qu'il faut savoir sur le paragraphe
  # à commencer par les styles définis par le pfbcode (paragraphe
  # précédent)
  # 
  def style
    @style ||= begin
      sty = {}
      sty.merge!(pfbcode.parag_style) if pfbcode 
      sty
    end
  end
  ##
  # Pour ajouter du style à la volée
  # 
  def add_style(table)
    style.merge!(table)
  end

  def pfbcode ; @pfbcode ||= data[:pfbcode] end

  def length  ; @length ||= (text||'').length     end

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
