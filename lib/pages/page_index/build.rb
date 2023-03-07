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
    diff_font_canon_and_number = (canon_fonte != number_fonte)
    # 
    # Police et taille
    # 
    unless diff_font_canon_and_number
      spy "Font/size appliqués : #{canon_fontstyle.inspect}/#{canon_font_size.inspect}".bleu
      pdf.font(canon_fonte)
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
          {text: canon, font: canon_fonte},
          {text: " : #{dcanon[:items].map{|dmot|dmot[key_num]}.join(', ')}", font: number_fonte}
          # {text: canon, font: font_name, size: font_size, styles: [font_style]},
          # {text: " : #{dcanon[:items].map{|dmot|dmot[key_num]}.join(', ')}", font: number_font_name, size: number_font_size, styles: [number_font_style]}
        ]
      else
        pdf.text("#{canon} : #{dcanon[:items].map{|dmot|dmot[key_num]}.join(', ')}")
      end
    end
    spy "<- /construction de l'index".jaune
  end

  def canon_fonte
    @canon_fonte ||= Fonte.new(canon_fontstyle, **{size: canon_font_size})
  end
  def number_fonte
    @number_fonte ||= begin
      if canon_fontstyle == number_fontstyle && canon_font_size == number_font_size
        canon_fonte
      else
        Fonte.new(number_fontstyle, **{size:number_font_size})
      end
    end
  end

  def canon_fontstyle
    @canon_fontstyle ||= recipe.index_canon_font_n_style
  end
  def canon_font_size
    @canon_font_size ||= recipe.index_canon_font_size
  end

  def number_fontstyle
    @number_font_name ||= recipe.index_number_font_n_style
  end
  def number_font_size
    @number_font_size ||= recipe.index_number_font_size
  end

end #/class PageIndex
end #/class Pages
end #/module Prawn4book
