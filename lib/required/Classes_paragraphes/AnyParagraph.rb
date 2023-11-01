module Prawn4book
class PdfBook
class AnyParagraph

  #
  # Attention : ça n'est QUE le début commun de l'impression. Voir
  # dans chaque class les traitements particuliers.
  # 
  def print(pdf)

    # -- Comme son nom d'indique --
    # 
    prepare_and_formate_text(pdf)

  end


  # Préparation du paragraphe
  # 
  # @note
  #   Le traitement a été sorti pour pouvoir être utilisé par
  #   des méthodes personnalisées (à commencer par le Printer)
  # 
  def prepare_and_formate_text(pdf)
    #
    # Définir le numéro du paragraphe ici, pour que
    # le format :hybrid (n° page + n° paragraphe) fonctionne
    # 
    if paragraph? && not(AnyParagraph.numerotation_paragraphs_stopped?)
      @numero = AnyParagraph.get_next_numero
    end

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
      @text = AnyParagraph.__parse(text, context)
    end
  end

  ##
  # Impression du numéro de paragraphe en regard du paragraphe
  # 
  # @param pdf [Prawn::View] Le pdf en construction
  # 
  # @param options [Hash] Options pour l'affichage du numéro
  # 
  #   :voffset    Décalage vertical (pour mettre le numéro plus haut ou plus bas)
  #               Note : c'est une utilisation surtout lorsque le numéro est "forcé"
  #   :hoffset    Décalage horizontal du numéro.
  #               idem.
  # 
  # @note
  # 
  #   Sauf si la numérotation a été arrêtée à l'aide de :
  #     (( stop_numeration_paragraphs ))
  # 
  def print_paragraph_number(pdf, **options)

    return if AnyParagraph.numerotation_paragraphs_stopped?

    num = numero.to_s
    
    #
    # Pour l'intérieur de pdf.update
    # 
    me = self


    # -- Hauteur pour le numéro --
    # (peut-être rectifié localement par options[:voffset])
    # 
    num_top = me.class.diff_height_num_parag_and_parag(pdf)
    if options && options[:voffset]
      num_top += options[:voffset]
    end


    pdf.update do

      # 
      # Fonte spécifique pour cette numérotation
      # 
      font(me.class.parag_num_fonte) do
      
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

        if options && options[:hoffset]
          span_pos_num += options[:hoffset]
        end

        @span_number_width ||= 1.cm

        spy "Numéro #{num} appliqué au paragraphe".orange
        spy "    @span_number_width = #{@span_number_width.inspect}".orange
        spy "    position: #{span_pos_num.inspect}".orange

        float {
          move_down(num_top)
          span(@span_number_width, position: span_pos_num) do
            text "#{num}", **{color: me.parag_numero_color}
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

  attr_reader :pdf

  attr_reader :book

  attr_reader :text

  # @prop Première et dernière page du paragraphe
  attr_accessor :first_page
  attr_accessor :last_page
  attr_accessor :page_numero

  # Liste des balises de style de paragraphe
  attr_accessor :class_tags

  # Index du paragraphe dans le texte source. Il est donc
  # très facile de faire référence à ce paragraphe à l'aide de
  # ce pindex ("Le #{pindex}e paragraphe contient une erreur")
  # 
  # @note : pour l'index absolu dans <book>.paragraphes, voir la
  # propriété suivante.
  # 
  attr_reader :pindex

  # Index absolu du paragraphe dans <book>.paragraphes.
  # C'est avec cet index absolu qu'on peut connaitre la nature des
  # paragraphes avant.
  attr_accessor :abs_index

  attr_reader :type

  def initialize(book, pindex)
    @book   = book
    @pindex = pindex
    @unknown_targets = []
  end

  # @return La référence au paragraphe en fonction de la pagination
  # choisie. Si on est en mode 'page', seul le numéro de la première
  # page du paragraphe est retourné. Si on est en mode 'parags', seul
  # le numéro du paragraphe est retourné. Si on est en mode 'hybrid',
  # c'est le page-paragraphe qui est retourné
  # 
  # @param [Bool] prefix  Si true on retourne la référence avec un
  # préfix adéquant. Sinon, on retourne seulement la référence (le 
  # numéro de page, de paragraphe ou le numéro hybride)
  # 
  def reference(prefix = true)
    @reference ||= begin
      case book.recipe.page_num_type
      when 'hybrid'   then "#{'pg. '  if prefix}#{first_page}-#{numero}"
      when 'pages'    then "#{'page ' if prefix}#{first_page}"
      when 'parags'   then "#{'par. ' if prefix}#{numero}"
      end
    end
  end

  # Enregistre une cible ultérieure
  # 
  # @param data_ref [Hash]
  #   :ticket     Le ticket de boucherie
  #   :ref_id     ID de la référence (son nom entre les parenthèses)
  #   :page       Numéro de page
  #   :y          La position y dans la page
  #   :x          La position x dans la page (non encore défini)     
  def has_unknown_target(data_ref)
    # puts "data_ref = #{data_ref.inspect}".bleu
    @unknown_targets << data_ref
  end

  def resolve_targets
    @unknown_targets.each do |dtarget|
      @text = @text.sub(dtarget[:ticket], book.references.get(dtarget[:ref_id], {paragraph:self, pdf:pdf}))
    end
  end

  # --- Text Methods ---

  def text=(value); @text = value end


  # --- Méthodes d'aspect et de positionnement ---

  def font_size
    @font_size ||= begin
      styles[:font_size] || recipe.default_font_size
    end
  end

  def font_family
    @font_family ||= begin
      styles[:font_family] || recipe.default_font_name
    end
  end

  def font_style
    @font_style ||= begin
      styles[:font_style] || recipe.default_font_style
    end
  end

  # - Alignement du texte -
  def text_align
    @text_align || styles[:align] || styles[:text_align] || :justify 
  end
  def text_align=(value); @text_align = value     end
  alias :alignment :text_align
  alias :align :text_align

  # - Marge haute du paragraphe (en nombre de lignes) -
  def margin_top
    @margin_top ||= styles[:margin_top]  || 0 
  end
  def margin_top=(t)
    @margin_top = real_value_for(t) 
  end

  # - Marge basse du paragraphe (en nombre de lignes) -
  def margin_bottom
    @margin_bottom ||= styles[:margin_bottom] || 0 
  end

  def margin_left
    @margin_left ||= styles[:margin_left] || 0
  end
  def margin_left=(ml)
    @margin_left = real_value_for(ml)
  end

  def margin_left_raw
    @margin_left_raw ||= styles[:margin_left]
  end

  def margin_right
    @margin_right ||= styles[:margin_right] || 0
  end
  def margin_right=(mg)
   @margin_right = real_value_for(mg)
  end

  def kerning
    styles[:kerning]
  end

  def character_spacing
    styles[:character_spacing]
  end

  def width
    @width ||= styles[:width]
  end

  # --- Volatile Data ---

  ##
  # Style précis du paragraphe
  # 
  # Est censé contenir tout ce qu'il faut savoir sur le paragraphe
  # à commencer par les styles définis par le prev_pfbcode (paragraphe
  # précédent)
  # 
  def styles
    @styles ||= get_and_calc_styles
  end

  # Pour ajouter du style à la volée
  # (par exemple quand c'est un item de liste ou une citation)
  # 
  def add_style(table)
    styles.merge!(table)
  end

  # @return le premier paragraphe imprimé précédent (donc en 
  # excluant les lignes vides)
  # 
  # @note
  #   Cette méthode a été inauguré pour les titres, pour savoir si
  #   un titre suit un autre titre.
  #   Voir aussi la méthode predicate previous_is_title?
  # 
  def prev_printed_paragraph
    @prev_printed_paragraph ||= begin
      if abs_index
        pidx  = abs_index.dup
        ppp   = nil
        while pidx > 0
          pidx -= 1
          ppp   = book.paragraphes[pidx]
          break unless ppp.empty_paragraph?
          ppp = nil
        end
        ppp
      end
    end
  end

  # @return [PdfBook::PFBCode|ClassNil] S'il existe, le paragraphe
  # de code qui précède le paragraphe courant.
  def prev_pfbcode
    @prev_pfbcode ||= begin
      if abs_index && abs_index > 0
        if book.paragraphes[abs_index - 1].pfbcode?
          book.paragraphes[abs_index - 1] 
        end
      end
    end
  end
  alias :pfbcode :prev_pfbcode

  def length  ; @length ||= (text||'').length     end


  # @shortcut
  def recipe; @recipe || book.recipe end


  private

  # --- Calcul Methods --- #

    def get_and_calc_styles
      sty = {}
      if prev_pfbcode
        prev_pfbcode.next_parag_style.each do |k, v|
          k = case k
              when :font    then :font_family
              when :size    then :font_size
              when :style   then :font_style
              when :left    then :margin_left
              when :right   then :margin_right
              when :top     then :margin_top
              when :bottom  then :margin_bottom
              else k
              end
          sty.merge!(k => real_value_for(v))
        end
      end
      return sty
    end

    # Traite la valeur +value+ qu'elle soit une valeur numérique ou
    # une valeur exprimée en pourcentage, comme dans les styles.
    # 
    def real_value_for(value)
      if value.is_a?(Symbol)
        return value
      elsif value.is_a?(Numeric)
        return value
      elsif value.is_a?(String) && value.numeric?
        return value.to_i
      elsif value.match?(/\%$/)
        pourcentage_to_pdfpoints(value)
      else
        value
      end
    end

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
