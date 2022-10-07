module Prawn4book
class PdfBook
class << self

  # @return une instance du book courant
  #
  # Soit ce livre est défini par le dossier courant (s'il contient
  # les éléments requis) soit il est défini par le premier argument
  # 
  def get_current
    if CLI.components[1]
      puts "Je dois prendre le livre #{CLI.components[1].inspect}"
      cfolder = CLI.components[1]
    else
      cfolder = File.expand_path('.')
    end

    # 
    # Le livre existe-t-il vraiment ? Si oui, on le prend, sinon,
    # on lève une exception.
    # 
    if File.exist?(cfolder) && File.exist?(File.join(cfolder,'recipe.yaml'))
      PdfBook.new(cfolder)
    else
      raise "Impossible de trouver le livre '#{cfolder}'… Ce n'est pas un dossier de livre PDF."
    end
  end

end #/<< self
end #/class PdfBook
end #/module Prawn4book
