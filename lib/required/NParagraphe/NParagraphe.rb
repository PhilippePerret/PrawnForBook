module Narration
class PdfBook < Prawn::Document
class NParagraphe

  # Instanciation avec les données quand on le remonte du fichier
  # YAML
  def initialize(data = nil)
    @data = data
  end

end #/class NParagraphe
end #/class PdfBook
end #/module Narration
