module Narration
class PdfBook < Prawn::Document
class NParagraphe

  # --- Predicate Methods ---

  def real?     ; :TRUE === @istypereal   end
  def image?    ; :TRUE === @istypeimage  end
  def titre_n1? ; :TRUE === @istypetitre_n1 end
  def titre_n2? ; :TRUE === @istypetitre_n2 end
  def titre_n3? ; :TRUE === @istypetitre_n3 end
  def titre_n4? ; :TRUE === @istypetitre_n4 end

end #/class NParagraphe
end #/class PdfBook
end #/module Narration
