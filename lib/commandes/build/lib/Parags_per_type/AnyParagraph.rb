module Prawn4book
class PdfBook
class AnyParagraph

  attr_reader :pdf


  def margin_top
    @margin_top ||= (pfbcode && pfbcode[:margin_top]) || 0
  end
  def margin_bottom 
    @margin_bottom ||= (pfbcode && pfbcode[:margin_bottom]) || 0
  end

  def width
    @width ||= begin
      w = pfbcode && pfbcode[:width]
      if w
        if w.is_a?(String) && w.end_with?('%')
          w = pourcentage_to_pdfpoints(w, pdf.bounds.width)
        end
      end
      w
    end
  end

  def margin_left
    @margin_left ||= begin
      ml = margin_left_raw
      if ml
        if ml.is_a?(String) && ml.end_with?('%')
          ml = pourcentage_to_pdfpoints(ml, pdf.bounds.width)
        end
      end
      ml || 0
    end
  end

  def margin_left_raw
    @margin_left_raw ||= pfbcode && pfbcode[:margin_left]
  end

  def margin_right
    @margin_right ||= 0
  end

  # --- Calcul Methods --- #

  ##
  # Reçoit une valeur par exemple en pourcentage ("50%") et 
  # retourne une valeur en points-pdf
  #
  # @param  value {String|Integer} Valeur pourcentage à calculer
  #               Soit le nombre (pe 50) soit le string (pe '50%')
  # @param  refval {Measurment} La valeur de référence. Par exemple
  #         la largeur de la page si on veut une valeur horizontale
  #         En d'autres termes, cette valeur correspond au 100 %
  def pourcentage_to_pdfpoints(value, refval)
    if value.is_a?(String)
      value = value[0..-2].to_i
    end
    refval * value / 100
  end

end #/class AnyParagraph
end #/class PdfBook
end #/class Prawn4book
