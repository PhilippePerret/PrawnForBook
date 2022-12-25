module Prawn4book
class PdfBook
class NTextParagraph < AnyParagraph


  # --- Helper Methods ---

  ##
  # Méthode principale d'écriture du paragraphe
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
    # formater le paragraphe et on poursuit.
    # 
    if own_formaters?
      own_formaters # on poursuit
    end

    parag = self

    # spy "pfbcode = #{self.pfbcode}"

    mg_left   = self.margin_left
    if pfbcode && pfbcode[:margin_left]
      mg_left += pfbcode[:margin_left]
    end
    mg_right  = self.margin_right
    indent    = self.indent

    pdf.update do

      #
      # Placement du cursor sur la bonne ligne de référence
      # 
      theline = cursor
      # spy "cursor = #{theline.inspect}"
      if parag.pfbcode && parag.pfbcode[:margin_top]
        theline -= parag.pfbcode[:margin_top]
      end
      # spy "cursor rectifié = #{theline.inspect}"
      move_cursor_to_lineref(theline)
      start_cursor = theline
      # spy "start_cursor = #{start_cursor}"
    end

    # 
    # Indication de la première page du paragraphe
    # 
    self.first_page = pdf.page_number

    # # 
    # # S'il faut NUMÉROTER LES PARAGRAPHES, on place un numéro
    # # en regard du paragraphe.
    # # 
    # parag.print_paragraph_number(self) if paragraph_number? 

    # 
    # TEXTE FINAL du paragraphe
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
    fontSize    = font_size(pdf)
    fontStyle   = font_style(pdf)

    pdf.update do
      # 
      # FONTE (name, taille et style)
      # 
      begin
        spy "Application de la fonte : #{fontFamily}"
        ft = font fontFamily, size: fontSize, font_style: fontStyle
      rescue Prawn::Errors::UnknownFont => e
        spy "--- fonte inconnue ---"
        spy "Fontes : #{pdfbook.recipe.get(:fonts).inspect}"
        raise
      end

      # 
      # Le paragraphe va-t-il passer à la page suivante ?
      # (pour pouvoir calculer son numéro de dernière page)
      # 
      final_str_height = height_of(final_str)
      chevauchement = cursor - final_str_height < 0
      # spy "final_str_height : #{final_str_height.inspect}"
      # spy "chevauchement : #{chevauchement.inspect}"

    end


    #
    # ÉCRITURE DU PARAGRAPHE
    # 
    begin
      options = {
        inline_format:  true,
        align:          :justify,
        font_style:     fontStyle,
        size:           fontSize
      }
      if mg_left > 0
      
        wbox = pdf.bounds.width - (mg_left + mg_right)
        options.merge!(at: [mg_left, pdf.cursor])
      
        print_paragraph_in_text_box(pdf, final_str, options)
      
      else
      
        print_paragraph_as_text(pdf, final_str, options)
      
      end
    rescue Exception => e
      puts "Problème avec le paragraphe #{final_str.inspect}".rouge
      puts "Erreur : #{e.message}"
      exit
    end

    # 
    # On prend la dernière page du paragraphe, c'est celle sur 
    # laquelle on se trouve maintenant
    # 
    self.last_page = pdf.page_number

  end

  ##
  # Impression naturelle du texte (sans contrainte, dans le flux, par
  # opposition au placement dans un text_box)
  # 
  def print_paragraph_as_text(pdf, str, options)
    pdf.text(str, options)
  end

  ##
  # Impression du texte dans un text_box pour placement particulier
  # 
  def print_paragraph_in_text_box(pdf, str, options)
    pdf.text_box(str, options)
  end

  ##
  # Impression du numéro de paragraphe en regard du paragraphe
  # 
  def print_paragraph_number(pdf)
    numero = number.to_s

    pdf.update do
      # 
      # Fonte spécifique pour cette numérotation
      # 
      font(pdfbook.num_parag_font, size: pdfbook.num_parag_font_size) do
      
        # 
        # Calcul de la position du numéro de paragraphe en fonction du
        # fait qu'on se trouve sur une page gauche ou une page droite
        # 
        span_pos_num = 
          if belle_page?
            wspan = width_of(numero)
            bounds.right + (parag_number_width - wspan)
          else
            - parag_number_width
          end

        @span_number_width ||= 1.cm

        float {
          move_down(7 + pdfbook.recipe.get(:num_parag, {})[:top_adjustment].to_i)
          span(@span_number_width, position: span_pos_num) do
            text "#{numero}", color: '777777'
          end
        }
      end #/font
    end    
  end

  # --- Print Data Methods --- #

  def margin_bottom
    @margin_bottom || 0  
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
      pdf.default_font
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
      puts 
      if self.instance_variables.include?(prop_name)
        self.instance_variable_set(prop_name, args)
      else
        puts "instances_varialbes : #{self.instance_variables.inspect}"
        raise "Le paragraphe ne connait pas la propriété #{prop_name.inspect}."
      end
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

  def own_formaters?
    return false if styled_tags.nil?
    @own_formaters_methods = []
    styled_tags.each do |tag|
      if self.respond_to?("formate_#{tag}".to_sym)
        @own_formaters_methods << "formate_#{tag}".to_sym
        # Il faut toutes les récupérerer
      end
    end
    return @own_formaters_methods.any?
  end

  def own_formaters
    @own_formaters_methods.each do |formater|
      send(formater, self)
    end
  end



end #/class NTextParagraph
end #/class PdfBook
end #/module Prawn4book
