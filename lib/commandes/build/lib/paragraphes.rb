module Prawn4book
class PrawnView

  attr_accessor :previous_paragraph
  attr_accessor :previous_text_paragraph


  # @param paragraphes {Array of AnyParagraph}
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
    suivi = 'Écriture du paragraphe #%{num}…'.vert
    paragraphes.each_with_index do |paragraphe, idx|

      next if paragraphe.not_printed?

      paragraphe.page_numero = page_number
      # spy "Page ##{page_number} pour le paragraphe #{idx}"

      # 
      # --- PRÉ-TRAITEMENT DU PARAGRAPHE ---
      # 
      if pdfbook.module_parser? && paragraphe.paragraph?
        pdfbook.__paragraph_parser(paragraphe)
      end
      
      # 
      # --- ÉCRITURE DU PARAGRAPHE ---
      # 
      paragraphe.print(self)
      STDOUT.write green_point

      # On peut indiquer les pages sur lesquelles est inscrit le
      # paragraphe
      if paragraphe.paragraph?
        # - Suivi du travail -
        # write_at(suivi % {num: paragraphe.numero}, 0, 0)
        pdfbook.set_paragraphs_in_pages(paragraphe)
      end

      #
      # Si ce paragraphe est un titre, on le mémorise comme titre
      # courant de son niveau. L'information est utile pour régler
      # les titres des nouvelles pages.
      # 
      if paragraphe.titre?
        pdfbook.set_current_title(paragraphe, page_number)
      end
      
      break if page_number === last_page

      #
      # On consigne ce dernier paragraphe
      # (utile par exemple pour savoir s'il faut appliquer le
      #  margin_top du paragraphe suivant)
      self.previous_paragraph = paragraphe
      if paragraphe.paragraph?
        self.previous_text_paragraph = paragraphe
      end
      
    end
    
  end


end #/class PrawnView
end #/module Prawn4book
