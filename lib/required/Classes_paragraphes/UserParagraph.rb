require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class UserParagraph < AnyParagraph

  # Quand l'utilisateur utilise la méthode Printer.pretty_render
  # sans fournir de propriétaire (:owner), un propriétaire de cette
  # classe est aussitôt créé pour permettre les opérations de base
  # sur les héritiers de AnyParagraph.
  # 


  def initialize(text, options)
    super(PdfBook.current, nil)
    @type     = 'user'
    @text     = text
    @options  = options
  end

  # --- Predicate Methods ---

  def paragraph?; true end

end #/class UserParagraph
end #/class PdfBook
end #/module Prawn4book
