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

    #
    # Donnée utiles (pour raccourci)
    # 
    linesBefore = self.lines_before
    linesAfter  = self.lines_after - 1 # 1 est ajoutée au texte suivant

    pdf.update do

      #
      # On place le titre au bon endroit en fonction des lignes
      # qu'il faut avant
      # 
      if linesBefore > 0
        move_down(linesBefore * line_height)
        spy "Ligne avant le titre : #{linesBefore}"
      else
        spy "Pas de lignes avant le titre".gris
      end
      #
      # Application de la fonte
      # 
      ft = font(titre.font, style: titre.style, size: titre.size)

      # 
      # Formatage du titre
      # 
      ftext = titre.formated_text(self)

      # 
      # On déplace le curseur sur la prochaine ligne
      # de base (en tenant compte de la hauteur de la
      # police du titre)

      move_cursor_to_next_reference_line
      
      # 
      # Écriture du titre
      # 
      # move_up(ft.ascender) # ajustement ligne de référence # <===== !!!!
      text ftext, align: :left, size: titre.size, leading: leading, inline_format: true
      spy "Cursor après écriture titre : #{cursor.inspect}".bleu

      #
      # On place le cursor sur la ligne suivante en fonction
      # du nombre de lignes qu'il faut laisser après
      # 
      if linesAfter > 0
        move_down(linesAfter * line_height)
        spy "Lignes après le titre : #{linesAfter.inspect}"
      else
        spy "Pas de lignes après le titre".gris
      end
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
