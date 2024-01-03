module ParserFormaterClass
  
  def formate_erreur(str, context)
    my = self
    pdf = context[:pdf]
    pdf.update do
      font(Prawn4book::Fonte.default)
      text("<b>\# #{str}</b>", **my.options_formate_erreur)
      update_current_line
    end
    return nil
  end

  def options_formate_erreur
    @options_formate_erreur ||= {size:12, color: "FF0000", inline_format:true}.freeze
  end

end
