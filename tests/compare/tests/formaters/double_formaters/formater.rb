module BibliographyFormaterModule
end #/module BibliographyFormaterModule

module TableFormaterModule
end

module ParserFormaterClass

  def formate_book_style1(str, context)
    str = "<font name=\"Courier\" size=\"18\"><b><i>#{str}</i></b></font>"
    return str
  end

end #/module ParserFormaterClass
