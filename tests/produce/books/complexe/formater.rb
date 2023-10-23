module ParserFormaterClass

  def formate_notedocu(str, context)
    formate_note('d', str, context)
    return nil # pour ne rien écrire
  end
  
  def formate_simplenote(str, context)
    formate_note('n', str, context)
    return nil # pour ne rien écrire
  end

  def formate_note(lettre, str, context)
    Prawn4book::Printer.pretty_render(
      pdf:      context[:pdf],
      text:     str,
      fonte:    Prawn4book::Fonte.default_fonte,
      options:  {
        align:    :justify,
        inline_format:true,
        left: 6.mm, 
        at: [6.mm, context[:pdf].bounds.width], # TODO Faire marcher sans ce :at
        puce: {
          content: PICTO_NOTE % [lettre],
          vadjust: 2, hadjust: 0, align: :left
        }
      },
    )
  end


  # PICTO_NOTE = '<font name="PictoPhil" size="16"><color rgb="555555">%s</color></font>'
  PICTO_NOTE = '<font name="PictoPhil" size="16">%s</font>'

end
