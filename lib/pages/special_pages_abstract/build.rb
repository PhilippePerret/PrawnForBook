=begin
  
  Méthodes communes pour la construction

=end
module Prawn4book
class SpecialPage

  ##
  # Méthode permettant de redéfinir la font courante si elle n'est
  # pas la même que la fonte précédemment définie
  # 
  def redef_current_font(font, pdf)
    if font != @current_font
      @current_font = font
      begin
        pdf.font(@current_font)
      rescue Prawn::Errors::UnknownFont
        begin
          pdf.font(@current_font, {style: :roman})
        rescue Prawn::Errors::UnknownFont
          pdf.font('Helvetica', {style: :regular})
        end
      end
    end
  end
end #/class SpecialPage
end #/module Prawn4book
