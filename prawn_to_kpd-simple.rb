=begin

Pour tenter de générer le pdf avec Prawn


=end

require_relative 'lib/required'

Prawn::Fonts::AFM.hide_m17n_warning = true


#
# Le fichier de destination
#
doc = Narration::PdfBook.generate(
  filename,
  margin: Narration::PdfBook::MARGIN_ODD) do 


    # 
    # Définition des polices à utiliser
    # 
    font_families.update("Garamond" => {
      normal: "/Users/philippeperret/Library/Fonts/ITC - ITC Garamond Std Light Condensed.ttf",
      italic: "/Users/philippeperret/Library/Fonts/ITC - ITC Garamond Std Light Condensed Italic.ttf"
    })
    font_families.update("Bangla" => {
      normal: "/System/Library/Fonts/Supplemental/Bangla MN.ttc",
      bold:   "/System/Library/Fonts/Supplemental/Bangla MN.ttc"
    })
    font_families.update({
      "Avenir" => {
        normal: "/System/Library/Fonts/Avenir Next Condensed.ttc"
      }
    })

    font_families.update({
      "Arial" => {
        normal: "/Users/philippeperret/Library/Fonts/Arial Narrow.ttf"
      }
    })


    #
    # Espacement entre les lignes
    # 
    default_leading 1 # 5 aligne sur la baseline

    repeat(:odd) do
      font "Arial"
      draw_text "Page n°X", at: [300, 0], size: 9
    end

    repeat(:even) do
      font "Arial"
      draw_text "n°X Page", at: [0, 0], size: 9
    end


    #
    # On prend le texte
    # TODO : plus tard, quand le texte aura été "préparé", il sera 
    # dans un fichier YAML, paragraphe par paragraphe avec les 
    # ajustement nécessaires.
    # 
    texte = File.read('./texte.txt')
    # 
    # On le prépare (par exemple pour récupérer les modifications qui
    # ont été prévu pour lui)
    paragraphes = texte.split("\n").map { |p| p.strip }.reject { |p| p.empty? }

    # paragraphes = (1..50).to_a.map do |iline| "Le paragraphe #{iline} assez long pour voir le bout" end
    # puts "Paragraphes : #{paragraphes}"

    #
    # On se place toujours en haut de la page
    move_cursor_to_top_of_the_page

    interligne = 18

    #
    # Indice du paragraphe
    # 
    # Note : on n'utilise pas 'each_with_index' car tous les 
    # paragraphes ne sont pas des paragraphes (il y a par exemple des
    # images, qui ne sont pas comptées comme des paragraphes)
    # 
    paragraphe_indice = 0

    #
    # On écrit tous les paragraphes
    # 
    paragraphes.each_with_index do |paragraphe, idx|


      if paragraphe.start_with?('IMAGE')
        insert_image(paragraphe)
        next
      end

      paragraphe_indice += 1
      parag_number = paragraphe_indice + 1901

      # 
      # Rectification de la ligne de départ (cursor) pour tomber 
      # sur la grille (je tâtonne pour le moment)
      new_cursor = (cursor.to_i / interligne) * interligne
      move_cursor_to new_cursor

      puts "cursor avant écriture numéro paragraphe = #{cursor}"

      cursor_before_paragraph_number = cursor.freeze

      span_pos = belle_page? ? :right : :left
      span_pos_num = belle_page? ? 11.2.cm : -1.cm 
      span(2.cm, position: span_pos_num) do
        font "Bangla"
        # pos_num = [(belle_page? ? 11.2.cm : -0.8.cm ), cursor - 16]
        number = parag_number.to_s
        number = number.rjust(4) unless belle_page?
        # draw_text "#{number}", at: pos_num, color: 'CCCCCC', inline_format: true
        # draw_text "#{number}", at: pos_num, size: 8, color: 'CCCCCC', inline_format: true, float:true
        text "#{number}", size: 8, color: '777777' #, inline_format: true
      end

      move_cursor_to cursor_before_paragraph_number

      puts "cursor avant écriture paragraphe = #{cursor}"

      
      font "Garamond" # apparemment, ça ne fonctionne que comme ça
      text "#{paragraphe} (à #{cursor})", align: :justify, size: 11, font_style: 'normal', inline_format: true

      # move_down 20

      break if page_number == 24

    end #/ fin de boucle sur tous les paragraphes

end
