module Narration
class InputSimpleFile

  # @prop {String} Chemin d'accès au fichier
  attr_reader :path

  # @prop {Array of Any} paragraphes
  attr_reader :paragraphes

  ##
  # Instanciation du fichier à partir de son path
  # 
  def initialize(path)
    @path = path
  end

  ##
  # Parse le fichier pour en tirer les paragraphes
  #
  # Dans cette méthode, chaque paragraphe non vide du texte est 
  # transformé en une instance correspondant à son type, image,
  # titre, bloc formaté, etc. pour produire la propriété @paragraphes
  # de l'input-file
  # 
  def parse
    textinit = File.read(path)
    @paragraphes = 
      textinit.split("\n").map do |par|
        par.strip
      end.reject do |par|
        par.empty?
      end.map do |par|
        #
        # Analyse du paragraphe pour savoir ce que c'est
        # 
        NParagraphe.new(par).parse
        # => instance PdfBook::NImage, PdfBook::NTextParagraph
      end
  end


  ##
  # Le chemin d'accès, sans extension
  # 
  def affixe_path
    @affixe_path ||= File.join(folder, affixe)
  end

  def filename
    @filename ||= File.basename(path)
  end

  def affixe
    @affixe ||= File.basename(filename, File.extname(filename))
  end

  def folder
    @folder ||= File.dirname(path)
  end

end #/class InputSimpleFile
end #/module Narration
