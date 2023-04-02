module ParserParagraphModule

  def parser_formater(str, pdf)
    # 
    # calcul de la taille
    # 
    # @default_font_size ||= PdfBook.current.recipe.default_font_size
    @rapport_size_mot ||= 9.3 / 12
    size_mot = (@rapport_size_mot * pdf.current_font_size).round(2)
    # spy "pdf.current_font_size : #{pdf.current_font_size.inspect}".orange
    # 
    # On parse le texte
    # 
    str = str.gsub(REG_MOT) do
      txt = $1.freeze
      SPAN_MOT % [size_mot, txt]
    end
    # spy "Paragraphe après transformation : #{str}"
    # spy(:off)
    return str    
  end
  REG_MOT  = /mot\((.+?)\)/.freeze
  SPAN_MOT = '<font name="Verdana" size="%s">%s</font>'.freeze

  #
  # Méthode appelée par tous les paragraphes
  # 
  def __paragraph_parser(paragraph, pdf)
    paragraph.text = parser_formater(paragraph.text, pdf)
  end

end
