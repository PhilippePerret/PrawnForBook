module Prawn4book
class PrawnView

  attr_accessor :previous_paragraph
  attr_accessor :previous_text_paragraph


  # @param [Array<AnyParagraph>] paragraphes Les paragraphes à écrire.
  def print_paragraphs(paragraphes)
    # On boucle sur tous les paragraphes du fichier d'entrée
    # 
    # Note : chaque paragraphe est une instance de classe de
    # son type. Par exemple, les images sont des PdfBook::NImage,
    # les titres sont des PdfBook::NTitre, etc.
    # 
    # Note : 'with_index' permet juste de faire des essais
    green_point = '.'.vert
    clear unless debug?
    paragraphes.each_with_index do |paragraphe, idx|

      next if paragraphe.not_printed?

      if paragraphe.paragraph?
        spy "Écriture du paragraphe-texte #{paragraphe.numero}…".vert
      elsif paragraphe.titre?
        spy "Écriture du paragraphe-titre index #{idx} #{paragraphe.text.inspect}".vert
      end

      paragraphe.page_numero = page_number
      spy "Page du paragraphe #{idx} : ##{page_number}"

      # 
      # --- PRÉ-TRAITEMENT DU PARAGRAPHE ---
      # 
      # S'il existe un module parser et que le paragraphe est vraiment
      # un paragraphe (et non pas une définition, un style ou autre)
      # alors on parse ce paragraphe pour en tirer les informations
      # utiles ou faire des remplacements (par exemple des références
      # ou des prises de mots d'index)
      # 
      if pdfbook.module_parser? && paragraphe.paragraph?
        pdfbook.__paragraph_parser(paragraphe)
      end
      
      # 
      # --- ÉCRITURE DU PARAGRAPHE ---
      # 
      paragraphe.print(self)
      STDOUT.write green_point

      #
      # Si c'est un texte, on consigne le paragraphe dans sa page
      #
      if paragraphe.paragraph?
        pdfbook.set_paragraphs_in_pages(paragraphe)
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
        pdfbook.set_current_title(paragraphe, page_number)
      end
      
      break if page_number === last_page

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
