module Prawn4book
class PdfBook
class InputTextFile

  # @prop {PdfBook} La classe principale de l'instance à laquelle
  # appartient ce fichier texte
  attr_reader :pdfbook

  # @prop {String} Chemin d'accès au fichier
  attr_reader :path

  ##
  # Instanciation du fichier à partir de son path
  # 
  # @param pdfbook {Prawn4book} Instance du PdfBook contenant ce texte
  # @param patharg {Bool|Path} Soit true si le fichier porte le nom
  #             normal (texte.txt ou texte.md) soit le chemin d'accès
  #             complet
  #
  def initialize(pdfbook, patharg)
    @pdfbook  = pdfbook
    @path = define_path_from_arg(patharg)
  end

  def define_path_from_arg(patharg)
    case patharg
    when TrueClass
      txt_path = File.join(pdfbook.folder,'texte.txt')
      return txt_path if File.exist?(txt_path)
      md_path  = File.join(pdfbook.folder,'texte.md')
      return md_path if File.exist?(md_path)
      puts "Le fichier texte est introuvable…".rouge
      puts "(recherché dans '#{txt_path}' et\n'#{md_path}')".gris
      raise '- Abandon -'
    else
      if File.exist?(patharg)
        return patharg
      else
        raise "Le fichier texte '#{patharg}' est introuvable…"
      end
    end
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

end #/class InputTextFile
end #/class PdfBook
end #/module Prawn4book
