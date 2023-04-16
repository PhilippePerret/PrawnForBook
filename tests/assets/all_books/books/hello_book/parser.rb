module ParserFormaterClass

  def pre_parse(str, context)
    puts "Pour pré-parser le texte #{str.inspect}"

    return str
  end

  def parse(str,context)
    puts "Pour parser #{str.inspect}"

    return str
  end

end #/module ParserFormaterClass
