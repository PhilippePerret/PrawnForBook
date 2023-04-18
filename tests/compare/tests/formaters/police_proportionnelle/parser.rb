module ParserFormaterClass
  def parse(str, context)
    # 
    # calcul de la taille
    # 
    # @default_font_size ||= PdfBook.current.recipe.default_font_size
    @rapport_size_mot ||= 9.3 / 12
    size_mot = (@rapport_size_mot * context[:font_size]).round(2)
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
end #/module ParserFormaterClass
