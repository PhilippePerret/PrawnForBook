module Prawn4book
class PrawnView

  attr_accessor :previous_paragraph
  attr_accessor :previous_text_paragraph

  ##
  # @public
  # 
  # ÉCRITURE DE TOUS LES PARAGRAPHES
  # 
  # @param [Array<AnyParagraph>] paragraphes Les paragraphes à écrire.
  # 
  def print_paragraphs(paragraphes)
    # On boucle sur tous les paragraphes du fichier d'entrée
    # 
    # Note : chaque paragraphe est une instance de classe de
    # son type. Par exemple, les images sont des PdfBook::NImage,
    # les titres sont des PdfBook::NTitre, etc.
    # 
    green_point = '.'.vert.freeze
    clear unless debug?
    paragraphes.each_with_index do |paragraphe, idx|

      # puts "Instance Paragraphe: #{paragraphe}"

      #
      # On s'en retourne tout de suite s'il ne faut pas écrire ce
      # paragraphe.
      # 
      next if paragraphe.not_printed?

      #
      # Réglage du numéro de page du paragraphe (quel que soit son
      # type de pagination et son type)
      # 
      paragraphe.page_numero = page_number
      
      # 
      # --- ÉCRITURE DU PARAGRAPHE ---
      # 
      # (quel que soit son type, mais chaque type possède sa propre
      #  méthode #print)
      # 
      paragraphe.print(self)
      STDOUT.write green_point

      #
      # Faut-il fermer des notes ?
      # 
      book.notes_manager.check_if_end_of_notes(self)

      #
      # Si c'est un texte, on consigne le paragraphe dans sa page
      #
      if paragraphe.paragraph?
        book.set_paragraphs_in_pages(paragraphe)
      end

      #
      # Traitement particulier si c'est un titre
      #   
      # - on doit trouver sa ligne de base en fonction de line_height
      #   du nombre de lignes qu'il faut laisser avant et après 
      #   (l'idée, pour le moment, est de toujours replacer le curseur
      #    au bon endroit)
      # - traite le cas où le texte de la suite serait sur une autre
      #   page TODO
      # - on le mémorise comme titre courant de son niveau. 
      #   L'information est utile pour régler les titres des 
      #   nouvelles pages.
      # 
      if paragraphe.titre?
        book.set_current_title(paragraphe, page_number)
      end

      # 
      # Quand on atteint la dernière page désirée (définie en
      # options par '-last=XXX'), on s'arrête
      # 
      break if page_number >= last_page

      #
      # On consigne ce dernier paragraphe
      # (utile par exemple pour savoir s'il faut appliquer le
      #  lines_before du paragraphe suivant)
      # 
      self.previous_paragraph = paragraphe
      self.previous_text_paragraph = paragraphe if paragraphe.paragraph?
      
    end
    
  end

  def previous_paragraph_titre?
    previous_paragraph && previous_paragraph.titre?
  end


end #/class PrawnView
end #/module Prawn4book
