module Prawn4book
class PrawnView

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
    clear
    suivi = 'Écriture du paragraphe #%{num}…'.vert
    paragraphes.each_with_index do |paragraphe, idx|

      # STDOUT.write green_point

      paragraphe.page_numero = page_number

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


      # On peut indiquer les pages sur lesquelles est inscrit le
      # paragraphe
      if paragraphe.paragraph?
        # - Suivi du travail -
        # write_at(suivi % {num: paragraphe.numero}, 0, 0)
        STDOUT.write green_point

        pdfbook.pages[paragraphe.first_page] || begin
          pdfbook.pages.merge!(paragraphe.first_page => {first_par:paragraphe.numero, last_par:nil})
        end
        pdfbook.pages[paragraphe.last_page] || begin
          pdfbook.pages.merge!(paragraphe.last_page => {first_par:paragraphe.numero, last_par:nil})
        end
        # On le met toujours en dernier paragraphe de sa première page
        pdfbook.pages[paragraphe.first_page][:last_par] = paragraphe.numero
      end

      
      break if page_number === last_page
      
      if paragraphe.margin_bottom.nil?
        raise "Problème avec margin_bottom de : #{paragraphe.inspect}"
      end

      # TODO Retravailler par rapport à la grille de références
      move_down( paragraphe.margin_bottom )

    end
    
  end


end #/class PrawnView
end #/module Prawn4book
