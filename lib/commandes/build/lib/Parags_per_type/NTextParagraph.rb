module Prawn4book
class PdfBook
class NTextParagraph < AnyParagraph


  # --- Helper Methods ---

  ##
  # Méthode principale d'écriture du paragraphe
  # 
  def print(pdf)
    
    parag = self

    pdf.update do

      start_cursor = line_reference.dup
      move_cursor_to start_cursor
      # puts "Curseur au départ du print paragraphe : #{round(start_cursor)}"

      # 
      # Données textuelles du paragraphe
      # 
      fontFamily  = parag.font_family(self)
      fontSize    = parag.font_size(self)
      fontStyle   = parag.font_style(self) 

      # 
      # Indication de la première page du paragraphe
      # 
      parag.first_page = page_number

      if paragraph_number? 
        numero = parag.number.to_s

        # 
        # On place le numéro de paragraphe
        # 
        font pdfbook.font_or_default("Bangla"), size: 7
        # 
        # Taille du numéro si c'est en belle page, pour calcul du 
        # positionnement exactement
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

        move_cursor_to( start_cursor - 1 )
        span(@span_number_width, position: span_pos_num) do
          text "#{numero}", color: '777777'
        end
      
        # Reprendre la position de départ
        move_cursor_to(start_cursor)
      
      end #/end if paragraph_number?


      # puts "cursor avant écriture paragraphe = #{cursor}"

      final_str = parag.formated_text(self)
      add_cursor_position? && final_str = add_cursor_position(final_str)

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
        text final_str, align: :justify, size: fontSize, 
          font_style: fontStyle, inline_format: true
        move_down(ft.ascender)
        # puts "Cursor fin écriture parag : #{round(cursor)}"
      rescue Exception => e
        puts "Problème avec le paragraphe #{final_str.inspect}".rouge
        exit
      end

      # 
      # On prend la dernière page du paragraphe, c'est celle sur 
      # laquelle on se trouve maintenant
      # 
      parag.last_page = page_number # + (chevauchement ? 1 : 0)

      # debug rapport
      # puts "Parag ##{parag.numero.to_s.ljust(2)} first: #{parag.first_page.to_s.ljust(2)} last: #{parag.last_page.to_s.ljust(2)}"

      # 
      # Vérification ligne de référence
      # 
      if (start_cursor - cursor) % line_height > 0.05
        puts "Il y a un problème de leading… Le texte ne se trouve plus sur la ligne de référence…".rouge
        puts "(start_cursor - cursor) % line_height = (#{round(start_cursor)} - #{round(cursor)}) % #{line_height} = #{(start_cursor - cursor) % line_height}".rouge
      end

    end
  end

  def margin_bottom
    @margin_bottom || 0  
  end
  def margin_top
    @margin_top || 0
  end

  def font_family(pdf)
    @font_family ||= pdf.default_font
  end

  def font_size(pdf)
    @font_size ||= pdf.default_font_size
  end

  def font_style(pdf)
    @font_style ||= pdf.default_font_style
  end

end #/class NTextParagraph
end #/class PdfBook
end #/module Prawn4book
