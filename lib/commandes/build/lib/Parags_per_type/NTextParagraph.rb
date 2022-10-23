module Prawn4book
class PdfBook
class NTextParagraph < AnyParagraph


  # --- Helper Methods ---

  ##
  # Méthode principale d'écriture du paragraphe
  # 
  def print(pdf)
    
    if own_builder?
      return own_builder(pdf)
      # on s'arrête, c'est le builder qui construit le paragraphe
    elsif own_formaters?
      own_formaters
      # et on continue
    end

    parag = self

    mg_left   = self.margin_left
    mg_right  = self.margin_right
    indent    = self.indent

    pdf.update do

      move_cursor_to_lineref(cursor)
      start_cursor = cursor

      # 
      # Indication de la première page du paragraphe
      # 
      parag.first_page = page_number

      # 
      # S'il faut NUMÉROTER LES PARAGRAPHES, on place un numéro
      # en regard du paragraphe.
      # 
      parag.print_paragraph_number(self) if paragraph_number? 

      # 
      # TEXTE FINAL du paragraphe
      # 
      final_str = parag.formated_text(self)

      #
      # Fonte et style à utiliser pour le paragraphe
      # (note : peut avoir été modifié de force ou par le style)
      # 
      # Note : elles ne peuvent être définies qu'ici, après le
      # parse du paragraphe (dont les balises initiales peuvent
      # modifier l'aspect)
      # 
      fontFamily  = parag.font_family(self)
      fontSize    = parag.font_size(self)
      fontStyle   = parag.font_style(self) 
      # 
      # La fonte proprement dite
      # 
      ft = font fontFamily, size: fontSize, font_style: fontStyle
      
      # 
      # Le paragraphe va-t-il passer à la page suivante ?
      # (pour pouvoir calculer son numéro de dernière page)
      # 
      final_str_height = height_of(final_str)
      chevauchement = cursor - final_str_height < 0

      # 
      # Écriture du paragraphe
      # 
      begin
        # 
        # Ajustement du curseur pour être sur la ligne et non pas
        # en dessous
        # 
        move_up( ft.ascender - line_height)
        if mg_left
          wbox = bounds.width - (mg_left + mg_right)
          text_box(
            final_str, 
            at:[mg_left, cursor], size: fontSize, 
            font_style: fontStyle, align: :justify, 
            inline_format: true
          )
          move_down(final_str_height)
        else
          text(final_str, align: :justify, size: fontSize, 
                  font_style: fontStyle, inline_format: true)
        end
        move_down(ft.ascender)
        # puts "Cursor fin écriture parag : #{round(cursor)}"
      rescue Exception => e
        puts "Problème avec le paragraphe #{final_str.inspect}".rouge
        puts "Erreur : #{e.message}"
        exit
      end

      # 
      # On prend la dernière page du paragraphe, c'est celle sur 
      # laquelle on se trouve maintenant
      # 
      parag.last_page = page_number # + (chevauchement ? 1 : 0)

      # 
      # Vérification ligne de référence
      # 
      # if (start_cursor - cursor) % line_height > 0.05
      if (start_cursor - cursor) % line_height > 0.1
        puts "Il y a un problème de leading… Le texte « #{final_str} » ne se trouve plus sur la ligne de référence…".rouge
        puts "(start_cursor - cursor) % line_height = (#{round(start_cursor)} - #{round(cursor)}) % #{line_height} = #{(start_cursor - cursor) % line_height}".rouge
      end

    end
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
