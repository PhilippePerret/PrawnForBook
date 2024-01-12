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

module Prawn4book
class PdfBook::AnyParagraph
  # @param time [String]
  #     Le temps, au format "H:MM:SS" où "H" sont les heures,
  #     MM sont les minutes et SS les secondes.
  #
  # @return l’horloge formatée
  #
  def horloge time
    h, m, s = time.split(':').map { |n| n.to_i.to_s }
    [h + __s(h), m + __s(m), s + __s(s)].join(' ')
    # "#{h} heure#{__s(h)} #{m} minute#{__s(m)} et #{s} seconde#{__s(s)}"
  end

  def __s(val)
    val.to_i > 1 ? "s" : ""
  end
end
end

