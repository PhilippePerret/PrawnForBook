module Prawn4book

# ::runner
class Command
  def proceed
    PdfBook.install_book
  end
end #/Command

class PdfBook
class << self

  ##
  # = main =
  # 
  # Méthode principale pour "installer un livre"
  # 
  # "Installer un livre", pour le moment, signifie simplement qu'on
  # va mettre ses snippets en snippets courants.
  # À l'avenir, on pourra imaginer qu'il y a aussi des scripts propres
  # pour sublime text, etc.
  def install_book
    require_relative 'lib/install_snippets'
    install_snippets
  end

end #/<< self
end #/class PdfBook
end #/module Prawn4book
