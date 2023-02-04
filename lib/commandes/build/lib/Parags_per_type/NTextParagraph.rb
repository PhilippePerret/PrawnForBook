module Prawn4book
class PdfBook
class NTextParagraph < AnyParagraph

  alias :book :pdfbook

  # --- Helper Methods ---

  ##
  # Méthode principale d'écriture du paragraphe
  # @note
  #   C'est vraiment cette méthode qui écrit un paragraphe texte,
  #   en plaçant le curseur, en réglant les propriétés, etc.
  # 
  def print(pdf)
    
    #
    # Si le paragraphe possède son propre builder, on utilise ce
    # dernier pour le construire et on s'en retourne.
    # 
    if own_builder?
      return own_builder(pdf) # stop
    end
    #
    # Si le paragraphe possède un formateur, on s'en sert pour 
    # formater le paragraphe et on poursuit (contrairement au
    # "constructeur" ci-dessus)
    # 
    own_formaters if own_formaters?


    mg_left   = self.margin_left
    if pfbcode && pfbcode[:margin_left]
      mg_left += pfbcode[:margin_left]
    end
    mg_right  = self.margin_right
    mg_top    = self.margin_top
    theindent = self.indent

    # 
    # Indication de la première page du paragraphe
    # 
    self.first_page = pdf.page_number

    # 
    # TEXTE FINAL du paragraphe
    # @note
    #   C'est dans cette méthode que sont traités les codes ruby, les
    #   marques bibliographiques, les références (cibles et appels)
    #   etc.
    # 
    final_str = formated_text(pdf)

    #
    # Fonte et style à utiliser pour le paragraphe
    # (note : peut avoir été modifié de force ou par le style)
    # 
    # Note : elles ne peuvent être définies qu'ici, après le
    # parse du paragraphe (dont les balises initiales peuvent
    # modifier l'aspect)
    # 
    fontFamily  = font_family(pdf)
    fontStyle   = font_style(pdf)
    fontSize    = font_size(pdf)
    textIndent  = recipe.text_indent
    textAlign   = self.text_align
    # spy "Indentation du texte : #{textIndent.inspect}" if textIndent > 0

    #
    # Pour invoquer cette instance
    # 
    parag = self

    pdf.update do

      # 
      # FONTE (name, taille et style)
      # 
      begin
        spy "Application de la fonte : #{Fonte.default_fonte.inspect}"
        ft = font(Fonte.default_fonte)
      rescue Prawn::Errors::UnknownFont => e
        spy "--- fonte inconnue ---"
        spy "Fontes : #{pdfbook.recipe.get(:fonts).inspect}"
        raise
      end
    end


    ###########################
    #  ÉCRITURE DU PARAGRAPHE #
    ###########################
    begin
      pdf.update do
        options = {
          inline_format:  true,
          align:          textAlign,
          # font_style:     fontStyle,
          size:           fontSize
        }

        if mg_top && mg_top > 0
          move_down(mg_top)
        end

        # 
        # Placement sur la première ligne de référence suivante
        # 
        move_cursor_to_next_reference_line

        # options.merge!(indent_paragraphs: textIndent) if textIndent
        if mg_left > 0
          #
          # Écriture du paragraphe dans une boite
          # 
          wbox = bounds.width - (mg_left + mg_right)
          span_options = {position: mg_left}
          # - dans un text box -
          span(wbox, **span_options) do
            text(final_str, **options)
          end
        else
          # 
          # Écriture du paragraphe dans le flux (texte normal)
          # 

          # spy "Position cursor pour écriture du texte \"#{final_str[0..200]}…\") : #{cursor.inspect}".bleu

          #
          # Écriture du numéro du paragraphe
          # 
          parag.print_paragraph_number(pdf) if pdfbook.recipe.paragraph_number?

          # 
          # Hauteur que prendra le texte
          # 
          final_height = height_of(final_str)
          # 
          # Le paragraphe tient-il sur deux pages ?
          # 
          chevauchement = (cursor - final_height) < 0

          # --- Écriture ---

          if chevauchement
            # 
            # On passe ici quand le texte est trop et qu'il va
            # passer sur la page suivante. Malheureusement, en utilisant
            # le comportement par défaut, le texte sur la page suivante
            # n'est pas posé sur les lignes de référence. Il faut donc
            # que je place un bounding_box pour placer la part de
            # texte possible, puis on passe à la page suivante et on
            # se place sur la place suivante.
            # 
            height_diff = final_height - cursor
            # spy "Texte trop long (de #{height_diff}) : <<< #{final_str} >>>".rouge
            # spy "margin bottom: #{parag.margin_bottom}"
            box_height = cursor + line_height
            # spy "Taille box = #{box_height}".rouge
            other_options = {
              width:  bounds.width,
              height: box_height,
              at:     [0, cursor],
              overflow: :truncate
            }.merge(options)
            excedant = text_box(final_str, **other_options)
            # spy "Excédant de texte : #{excedant.pretty_inspect}".rouge
            start_new_page
            move_cursor_to_next_reference_line
            final_str = excedant.map {|h| h[:text] }.join('')
          end
          spy "final_str = #{final_str.inspect}"
          spy "options = #{options.inspect}"
          text(final_str, **options)
        end
      end
    rescue PrawnFatalError => e
      raise e
    rescue Exception => e
      puts "Problème avec le paragraphe #{final_str.inspect}".rouge
      puts e.backtrace.join("\n").rouge if debug?
      puts "ERREUR : #{e.message}"
      exit
    end

    # 
    # On prend la dernière page du paragraphe, c'est celle sur 
    # laquelle on se trouve maintenant
    # 
    self.last_page = pdf.page_number

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

  def indent
    @indent ||= book.recipe.text_indent
  end

  def distance_from_text 
    @distance_from_text ||= book.recipe.parag_num_distance_from_text
  end
  def margin_bottom
    @margin_bottom || book.recipe.book_format[:page][:margins][:bot]
  end
  def margin_top
    @margin_top || 0
  end

  def margin_left; @margin_left ||= 0 end
  def margin_left=(val); @margin_left = val end

  def margin_right; @margin_right ||= 0 end
  def margin_right=(val); @margin_right = val end

  def font_family(pdf)
    @font_family ||= begin
      pdf.default_font_name
    end
  end
  def font_family=(val)
    @font_family = val
  end

  def font_size(pdf)
    @font_size ||= begin
      inline_style(:font_size, pdf.default_font_size)
    end
  end
  def font_size=(val)
    @font_size = val
  end

  def font_style(pdf)
    @font_style ||= begin
      pdf.default_font_style
    end
  end
  def font_style=(val)
    @font_style = val
  end

  def method_missing(method_name, *args, &block)
    if method_name.to_s.end_with?('=')
      prop_name = method_name.to_s[0..-2].to_sym
      if self.instance_variables.include?(prop_name)
        self.instance_variable_set(prop_name, args)
      else
        puts "instances_variables : #{self.instance_variables.inspect}"
        PrawnView.add_error_on_property(prop_name)
        raise "Le paragraphe ne connait pas la propriété #{prop_name.inspect}."
      end
    else
      raise NoMethodError.new("La méthode #{method_name.inspect} est inconnue de nos services.")
    end
  end

  # @return le style qui est peut-être défini par un code en ligne
  # au-dessus du paragraphe.
  def inline_style(key, default)
    return default if pfbcode.nil?
    pfbcode.parag_style[key] || default
  end

  def own_builder?
    return false if styled_tags.nil?
    styled_tags.each do |tag|
      if self.respond_to?("build_#{tag}_paragraph".to_sym)
        @own_builder_method = "build_#{tag}_paragraph".to_sym
        return true
      end
    end
    return false
  end

  # Constructeur propre
  def own_builder(pdf)
    send(@own_builder_method, self, pdf)
  end

  #
  # @note
  #  'styled_tags' contient les tags en début de paragraphe, avant
  #   des '::', qui définissent la "class" du paragraphe.
  def own_formaters?
    return false if styled_tags.nil?
    @own_formaters_methods = []
    styled_tags.each do |tag|
      if self.respond_to?("formate_#{tag}".to_sym)
        @own_formaters_methods << "formate_#{tag}".to_sym
        # Il faut toutes les récupérerer
      elsif self.respond_to?("#{tag}_formater".to_sym)
        @own_formaters_methods << "#{tag}_formater".to_sym
      end
    end
    return @own_formaters_methods.any?
  end

  def own_formaters
    @own_formaters_methods.each do |formater|
      begin
        self.send(formater, self)
      rescue PrawnFatalError => e
        raise e
      rescue Exception => e
        puts "FORMATER ERROR: #{e.message}".rouge
      end
    end
  end



end #/class NTextParagraph
end #/class PdfBook
end #/module Prawn4book
