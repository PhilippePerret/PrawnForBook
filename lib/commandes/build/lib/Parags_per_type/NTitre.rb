module Prawn4book
class PdfBook
class NTitre < AnyParagraph


  # --- Helpers Methods ---
  TB = ' ' * 6
  def print(pdf)
    titre = self

    debugit = debug?

    debugit && puts("\n\n\nTITRE « #{text} »".jaune)
    debugit && puts(TB+"Cursor arrivée dans print : #{round(pdf.cursor)}")
    # 
    # Faut-il passer à la page suivante ?
    # C'est le cas si la propriété :next_page est à true dans la
    # recette, pour ce titre. Ou si c'est sur une belle page que le
    # titre doit être affiché.
    # 
    pdf.start_new_page if next_page? || belle_page?
    # 
    # Si le titre doit être affiché sur une belle page, et qu'on se
    # trouve sur une page paire, il faut encore passer à la page
    # suivante.
    # 
    pdf.start_new_page if belle_page? && pdf.page_number.even?

    debugit && puts(TB+"Cursor de nouvelle page : #{round(pdf.cursor)}")

    # 
    # Espace avant
    # (seulement si le paragraphe précédent n'avait pas de margin
    #  bottom)
    # 
    pdf.update do
      # 
      # Les données de l'instance titre
      # 
      topMargin   = titre.margin_top
      botMargin   = titre.margin_bottom
      font_family = titre.font_family
      font_style  = titre.font_style
      font_size   = titre.font_size
      leading     = titre.leading
      level       = titre.level

      unless previous_paragraph && previous_paragraph.titre? && previous_paragraph.margin_bottom
        move_cursor_to_lineref(topMargin * line_height)
      end

      # 
      # Margin top du titre
      # 
      debugit && puts(TB+"topMargin = #{topMargin}")
      if (topMargin - 1) > 0
        move_down((topMargin - 1) * line_height)
        debugit && puts(TB+"Cursor après ajout top-margin: #{round(cursor)} [(#{topMargin} - 1) * #{line_height}]")
      end

      #
      # Application de la fonte
      # 
      ft = font(font_family, style: font_style, size: font_size)

      #
      # Positionnement sur la ligne de référence
      # 
      start_cursor = line_reference.dup
      move_cursor_to start_cursor

      # 
      # Écriture du titre
      # 
      debugit && puts(TB+"Position avant ajustement ascender : #{round(cursor)}")
      move_up(ft.ascender) # ajustement ligne de référence
      ftext = titre.formated_text(self)
      debugit && puts(TB+"Position après ajustement ascender: #{round(cursor)}")
      text ftext, align: :left, size: font_size, leading: leading, inline_format: true
      debugit && puts(TB+"Position après écriture : #{round(cursor)}")
      move_down(ft.ascender)
      debugit && puts(TB+"Position après réajustement: #{round(cursor)}")
    
      # 
      # Espace après (if any)
      #
      debugit && puts(TB+"botMargin = #{botMargin}")
      if ( botMargin - 1 ) > 0
        move_down((botMargin - 1) * line_height)
        debugit && puts(TB+"Position après application de bot-margin: #{round(cursor)}")
      end

      debugit && puts(TB+"Curseur à la fin de l'écriture du titre: #{round(cursor)}")
      debugit && puts("/TITRE (#{titre.text})".jaune)

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
