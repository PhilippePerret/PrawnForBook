module Prawn4book

# ::runner
class Command
  def proceed
    PdfBook.snippet
  end
end #/Command

class PdfBook
class << self

  ##
  # = main =
  # 
  # Méthode principale pour gérer les snippets en ligne de commande.
  #
  def snippet
    puts "La commande `snippet’ doit être implémentée.".orange
  end

end #/<< self
end #/class PdfBook
end #/module Prawn4book
