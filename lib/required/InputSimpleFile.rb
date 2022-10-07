module Prawn4book
class PdfBook
class InputSimpleFile

  # @prop {PdfBook} La classe principale de l'instance à laquelle
  # appartient ce fichier texte
  attr_reader :pdfbook

  # @prop {String} Chemin d'accès au fichier
  attr_reader :path

  ##
  # Instanciation du fichier à partir de son path
  # 
  def initialize(pdfbook, path)
    @pdfbook  = pdfbook
    @path     = path
  end

  # @prop {Array of Any} paragraphes
  # 
  # Soit les paragraphes ont déjà été parsés dans le document, et
  # placés dans un fichier 'texte.yaml' qui peut être lu tel quel,
  # soit il faut parser le texte original pour produire ces 
  # paragraphes.
  # 
  # Rappel : le fait de placer les paragraphes dans un fichier YAML
  # permet de définir très précisément comment il faut traiter les
  # choses (kerning, passage à la page suivante, etc.).
  def paragraphes
    @paragraphes ||= begin
      if File.exist?(data_paragraphes_path)
        YAML.load_file(data_paragraphes_path, aliases: true).map do |dparag|
          Paragraphe.dispatch_by_type(dparag)
        end
      else
        parse.tap do |parags|
          lespars = parags.map { |parag| parag.data }
          File.write(data_paragraphes_path, lespars.to_yaml)
        end
      end
    end
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
    File.read(path).split("\n").map do |par|
      par.strip
    end.reject do |par|
      par.empty?
    end.map do |par|
      #
      # Analyse du paragraphe pour savoir ce que c'est
      # 
      Paragraphe.new(par).parse
      # => instance PdfBook::NImage, PdfBook::NTextParagraph
    end
  end

  # @prop {String} Chemin d'accès au fichier de données des 
  # paragraphes, en format YAML
  def data_paragraphes_path
    @data_paragraphes_path ||= File.join(pdfbook.folder, 'texte.yaml')
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
end #/class PdfBook
end #/module Prawn4book
