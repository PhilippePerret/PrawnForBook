module Narration
class PdfBook < Prawn::Document
class NParagraphe

  # --- Data Methods ---

  # @prop {String} Contenu du paragraphe
  # Pour un paragraphe normal (real), c'est le paragraphe lui-même,
  # pour une image, c'est le chemin d'accès
  attr_reader :content

  # @prop {Integer} Niveau du paragraphe
  # 
  # Par exemple, pour les titres, c'est le niveau du titre
  attr_reader :level


end #/class NParagraphe
end #/class PdfBook
end #/module Narration
