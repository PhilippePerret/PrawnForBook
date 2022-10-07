module Prawn4book
class PdfBook

  ##
  # = main =
  # 
  # Méthode principale pour générer le PDF du livre
  # 
  def generate_pdf_book
    clear
    File.delete(pdf_path) if File.exist?(pdf_path)
    PdfFile.generate(pdf_path, pdf_config) do |doc|
      # 
      # On définit les polices requises pour le livre
      # 
      # define_required_fonts(self.config[:fonts])
      doc.define_required_fonts(recette[:fonts])
      #
      # Définition des numéros de page
      # 
      doc.set_pages_numbers
      #
      # On se place toujours en haut de la page pour commencer
      #
      doc.move_cursor_to_top_of_the_page

      interligne = recette[:interligne] # TODO : à mettre dans la recette

      # 
      # On boucle sur tous les paragraphes du fichier d'entrée
      # 
      # Note : chaque paragraphe est une instance de classe de
      # son type. Par exemple, les images sont des PdfBook::NImage,
      # les titres sont des PdfBook::NTitre, etc.
      # 
      # Note : 'with_index' permet juste de faire des essais
      # 
      inputfile.paragraphes.each_with_index do |paragraphe, idx|
        doc.insert(paragraphe)
        break if doc.page_number == 24
        doc.move_down( paragraphe.margin_bottom )
      end
    end #/PdfFile.generate

    if File.exist?(pdf_path)
      puts "Le book PDF a été produit avec succès !".vert
      puts "(in #{pdf_path})".gris
    else
      puts "Malheureusement le book PDF ne semble pas avoir été produit.".rouge
    end
  end

end #/class PdfBook
end #/module Prawn4book
