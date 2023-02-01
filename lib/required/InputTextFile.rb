module Prawn4book
class PdfBook
class InputTextFile

  # @prop {PdfBook} La classe principale de l'instance à laquelle
  # appartient ce fichier texte
  attr_reader :pdfbook
  alias :book :pdfbook

  # @prop {String} Chemin d'accès au fichier
  attr_reader :path

  ##
  # Instanciation du fichier à partir de son path
  # 
  # @param pdfbook {Prawn4book} Instance du PdfBook contenant ce texte
  # @param patharg {Bool|Path} 
  #                 SI true => le fichier porte le nom officiel (texte.pfb.txt ou texte.pfb.md) 
  #                 SI nil  => idem
  #                 SINON   => le chemin d'accès complet
  #
  def initialize(pdfbook, patharg)
    @pdfbook  = pdfbook
    @path     = define_path_from_arg(patharg)
  end

  def define_path_from_arg(patharg)
    case patharg
    when TrueClass, NilClass
      txt_path = File.join(pdfbook.folder,'texte.pfb.txt')
      return txt_path if File.exist?(txt_path)
      md_path  = File.join(pdfbook.folder,'texte.pfb.md')
      return md_path if File.exist?(md_path)
      puts (ERRORS[:unfound_text_file] % patharg.inspect).rouge
      puts "(in '#{txt_path}',\n'#{md_path}')".gris
      raise '- Abandon -'
    else
      if File.exist?(patharg)
        return patharg
      else
        raise ERRORS[:unfound_text_file] % patharg.inspect 
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
  def paragraphes
    @paragraphes ||= parse
  end

  # @return [Array<String>] La liste des références croisées qu'on
  # peut trouver dans le texte (pour vérification des informations
  # au lancement de la construction du livre)
  def cross_references ; @cross_references end

  def has_cross_references?
    !cross_references.empty?
  end

  ##
  # Parse le fichier pour en tirer les paragraphes
  #
  # Dans cette méthode, chaque paragraphe non vide du texte est 
  # transformé en une instance correspondant à son type, image,
  # titre, bloc formaté, etc. pour produire la propriété @paragraphes
  # de l'input-file
  def parse
    spy "-> PARSE DU TEXTE".jaune

    # 
    # Pour consigner les cross-références (pour contrôle)
    # 
    @cross_references = {}
    # 
    # 
    # Boucle sur tous les paragraphes du texte
    # 
    good_paragraphes_in(path).map do |par|
      if par.start_with?('(( include') && par.end_with?(' ))')
        paragraphes_of_included_file(par[11..-4])
      else par end
    end.flatten.map do |par|
      #
      # Analyse du paragraphe pour savoir ce que c'est
      # 
      spy "PARAGRAPHE : #{par.inspect}"
      parag = Paragraphe.new(pdfbook, par).parse
      # => instance PdfBook::NImage, PdfBook::NTextParagraph, etc.
      if parag.sometext? && parag.match_cross_reference?
        @cross_references.deep_merge!(parag.cross_references)
      end
      parag # map
    end
    # NE RIEN METTRE (MAP RETOURNÉ)
  end

  ##
  # @return [Array<String>] La liste des "bons" paragraphes du 
  # fichier de chemin +pth+
  # 
  # @note
  #   Cette méthode est utilisée aussi bien pour le fichier de texte
  #   principal que pour les fichiers inclus.
  # 
  # @param [String] filepath Chemin d'accès vérifié au fichier
  # 
  def good_paragraphes_in(filepath)
    # 
    # @bypass_it Pour sauter les commentaires ou les textes "ex-commen-
    # tés" quand ils tiennent sur plusieurs lignes.
    bypass_it = false
    File.read(filepath).split("\n").map do |par|
      par.strip
    end.reject do |par|
      par.empty? # SURTOUT PAS : LES TITRES par.start_with?('# ')
    end.reject do |par|
      if par.start_with?('<!--')
        bypass_it = true
      elsif par.end_with?('-->')
        bypass_it = false
        true
      else
        bypass_it
      end
    end    
  end

  ##
  # @return [Array<String>] Liste des paragraphes du texte inclus
  # défini par le chemin absolu ou relatif +fpath+
  # 
  def paragraphes_of_included_file(fpath)
    fpath = search_included_file_from(fpath)
    return good_paragraphes_in(fpath)
  end

  def search_included_file_from(fpath)
    return fpath if File.exist?(fpath)
    fpath_ini = fpath.freeze
    fpath = search_included_file_in_folder(fpath_ini, self.folder)
    return fpath if fpath
    if pdfbook.in_collection?
      fpath = search_included_file_in_folder(fpath_ini, book.collection.folder)
      return fpath if fpath
    end
    raise PrawnFatalError.new(ERRORS[:building][:unfound_included_file] * fpath_ini)
  end
  def search_included_file_in_folder(fpath, dossier)
    fpath_ini = fpath.freeze
    ['', '.md','.text','.txt','.pfb.md','.pfb.txt'].each do |ext|
      fpath = File.join(folder, "#{fpath_ini}#{ext}")
      return fpath if File.exist?(fpath)
    end
    return nil # échec
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
