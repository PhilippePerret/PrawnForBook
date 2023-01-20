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
    # Application de la fonte
    # 
    ft = pdf.font(titre.font, style: titre.style, size: titre.size)

    # 
    # Formatage du titre
    # 
    ftext = titre.formated_text(self)

    #
    # Nombre de lignes avant
    # 
    # Si le paragraphe précédent était un titre, on n'applique pas
    # le réglage linesBefore de ce titre.
    # Si le titre est trop grand pour la page, il faut ajouter des
    # :lines_before
    # 
    # QUESTION : en haut de page, faut-il systématiquement supprimer
    # les lignes avant ? Faudrait-il un paramètre 
    #   :skip_lines_before_on_page_top
    if pdf.previous_paragraph_titre?
      linesBefore = 0 
    else
      linesBefore = self.lines_before
    end
    # 
    # Nombre de lignes après
    # 
    linesAfter  = self.lines_after

    pdf.update do

      #
      # On place le titre au bon endroit en fonction des lignes
      # qu'il faut avant.
      # 
      if linesBefore > 0
        move_down(linesBefore * line_height)
        spy "Ligne avant le titre : #{linesBefore}"
      else
        spy "Pas de lignes avant le titre".gris
      end

      # 
      # On déplace le curseur sur la prochaine ligne
      # de base
      # 
      move_cursor_to_next_reference_line

      #
      # Si c'est un titre (ou pas…) et qu'il va manger sur la
      # marge haute, on le descend d'autant de lignes de référence
      # que nécessaire pour qu'il tienne dans la page.
      # 
      text_height = height_of(ftext.split(' ').first)
      while (cursor - 2 * line_height) + text_height > bounds.top
        move_down(line_height)
      end

      # 
      # Écriture du titre
      # 
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
