module Prawn4book
class Pages
class PageIndex

  # = main =
  #
  # Méthode principale construisant la page
  # 
  def build(pdf)
    spy "-> Construction de l'index".jaune
    # 
    # S'il n'y a aucun mot indexé, on s'en retourne tout de suite
    # 
    return if table_index.empty?
    # 
    # La clé à utiliser pour la page ou le paragraphe
    # 
    key_num = pdfbook.page_number? ? :page : :paragraph
    # 
    # Le titre de la page d'index
    # 
    titre = PdfBook::NTitre.new(pdfbook, text:"Index", level:1)
    titre.print(pdf)
    # 
    # Pour savoir si la police du canon est différente de celle des
    # nombres
    # 
    diff_font_canon_and_number = (font_name != number_font_name) || (font_size != number_font_size) || (font_style != number_font_style)
    spy "font_name/font_style de l'index : #{font_name.inspect}/#{font_style.inspect}".bleu
    # 
    # Police et taille
    # 
    unless diff_font_canon_and_number
      ft = pdf.font(font_name, size: font_size, style: font_style)
    end
    # 
    # Boucle sur la table des index 
    # 
    table_index.sort_by do |canon, dcanon|
      dcanon[:canon_for_sort]
    end.each do |canon, dcanon|
      pdf.move_cursor_to_next_reference_line
      if diff_font_canon_and_number
        pdf.formatted_text [
          {text: canon, font: font_name, size: font_size, styles: [font_style]},
          {text: " : #{dcanon[:items].map{|dmot|dmot[key_num]}.join(', ')}", font: number_font_name, size: number_font_size, styles: [number_font_style]}
        ]
      else
        pdf.text "#{canon} : #{dcanon[:items].map{|dmot|dmot[key_num]}.join(', ')}"
      end
    end
    spy "<- /construction de l'index".jaune
  end

  def canon_font_name
    @canon_font_name ||= recipe.index_canon_font_name
  end
  alias :font_name :canon_font_name
  def canon_font_size
    @canon_font_size ||= recipe.index_canon_font_size
  end
  alias :font_size :canon_font_size
  def canon_font_style
    @canon_font_style ||= recipe.index_canon_font_style
  end
  alias :font_style :canon_font_style

  def number_font_name
    @number_font_name ||= recipe.index_number_font_name
  end
  def number_font_size
    @number_font_size ||= recipe.index_number_font_size
  end
  def number_font_style
    @number_font_style ||= recipe.index_number_font_style
  end

end #/class PageIndex
end #/class Pages
end #/module Prawn4book
