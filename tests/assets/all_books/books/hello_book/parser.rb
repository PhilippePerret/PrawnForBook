module ParserFormaterClass

  def pre_parse(str, context)

    return str
  end

  def parse(str,context)
    @@liste_formatage ||= {}

    pa = context[:paragraph]

    str = str.gsub(/reformate\((.+?)\)/.freeze) do
      mot = $1.freeze
      @@liste_formatage.merge!(mot => {page:pa.first_page, paragraph:pa.numero})
      '<font name="Courrier" size="12">%s</font>'.freeze % mot
    end
    
    return str
  end

  def liste_formatage
    @@liste_formatage
  end

end #/module ParserFormaterClass
