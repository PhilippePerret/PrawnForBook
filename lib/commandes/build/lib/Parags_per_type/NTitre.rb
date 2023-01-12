module Prawn4book
class PdfBook
class NTitre < AnyParagraph


  # --- Helpers Methods ---

  ##
  # Méthode principale qui écrit le titre dans la page
  # 
  def print(pdf)
    titre = self

    # 
    # Faut-il passer à la page suivante ?
    # C'est le cas si la propriété :next_page est à true dans la
    # recette, pour ce titre. Ou si c'est sur une belle page que le
    # titre doit être affiché.
    # 
    spy "next_page? est #{next_page?.inspect}"
    spy "belle_page? est #{belle_page?.inspect}"
    
    if next_page? || belle_page?
      spy "Nouvelle page".bleu
      pdf.start_new_page 
    end
    # 
    # Si le titre doit être affiché sur une belle page, et qu'on se
    # trouve sur une page paire, il faut encore passer à la page
    # suivante.
    # 
    if belle_page? && pdf.page_number.even?
      psy "Nouvelle page pour se trouver sur une belle page".bleu
      pdf.start_new_page
    end

    pdf.update do

      # unless previous_paragraph && previous_paragraph.titre? && previous_paragraph.margin_bottom
      #   move_cursor_to_lineref(topMargin * line_height)
      # end

      spy "Position du cursor : #{cursor.inspect}".bleu
      line_ref = ( (cursor / line_height) - 1) * line_height
      spy "line_ref pour le titre : #{line_ref.inspect}".bleu
      move_cursor_to(line_ref)
      spy "Position cursor après déplacement : #{cursor.inspect}".bleu

      # # 
      # # Position top du titre (en fonction des nombres
      # # de lignes qu'il doit laisser avant)
      # # 
      # if (topMargin - 1) > 0
      #   move_down((topMargin - 1) * line_height)
      #   debugit && puts(TB+"Cursor après ajout top-margin: #{round(cursor)} [(#{topMargin} - 1) * #{line_height}]")
      # end

      #
      # Application de la fonte
      # 
      ft = font(titre.font, style: titre.style, size: titre.size)
      spy "font.ascender du titre : #{ft.ascender}".bleu
      
      # #
      # # Positionnement sur la ligne de référence
      # # 
      # start_cursor = line_reference.dup
      # move_cursor_to start_cursor

      # 
      # Écriture du titre
      # 
      # move_up(ft.ascender) # ajustement ligne de référence # <===== !!!!
      ftext = titre.formated_text(self)
      text ftext, align: :left, size: titre.size, leading: leading, inline_format: true
      # move_down(ft.ascender)
      spy "Cursor après écriture titre : #{cursor.inspect}".bleu
      # # 
      # # Espace après (if any)
      # #
      # if ( botMargin - 1 ) > 0
      #   move_down((botMargin - 1) * line_height)
      # end

    end

    # 
    # Ajout du titre à la table des matières
    # 
    num = pdf.previous_text_paragraph ? pdf.previous_text_paragraph.numero : 0
    pdf.tdm.add_title(self, pdf.page_number, num + 1)
  end

  def formated_text(pdf)
    str = text
    str = pdf.add_cursor_position(str) if add_cursor_position?
    return str
  end

end #/class NTitre
end #/class PdfBook
end #/module Prawn4book
