module Prawn4book
class PdfBook
class InputTextFile

  # Instance du fichier texte du livre (texte.pfb.md) qui définit
  # son contenu.
  # OU un fichier inclus dans le texte source.

  # @prop [PdfBook] La classe principale de l'instance à laquelle
  # appartient ce fichier texte. C'est le livre abstrait en 
  # construction, à ne pas confondre avec le Prawn::Document (en fait
  # Prawn::View) qui s'occupe réellement de construire le fichier
  # PDF du livre.
  attr_reader :book

  # @prop {String} Chemin d'accès au fichier
  attr_reader :path

  ##
  # Instanciation du fichier à partir de son path
  # 
  # @param book {Prawn4book} Instance du PdfBook contenant ce texte
  # @param patharg {Bool|Path} 
  #                 SI true => le fichier porte le nom officiel (texte.pfb.txt ou texte.pfb.md) 
  #                 SI nil  => idem
  #                 SINON   => le chemin d'accès complet
  #
  def initialize(book, patharg)
    @book = book
    @path = define_path_from_arg(patharg)
  end


  # = main =
  # 
  # Méthode principale qui procède à la lecture du fichier et à 
  # l'écriture des paragraphes dans le document +pdf+.
  # 
  # @note
  # 
  #   Les paragraphes des fichiers inclus passent aussi par ici.
  # 
  #######################################
  ###  READ AND PRINT ALL PARAGRAPHS  ###
  #######################################
  # 
  # 
  def parse_and_write(pdf)
    book.reset
    PdfBook::NTextParagraph.reset
    File.readlines(path, **{chomp:true}).map.with_index do |par_str, idx|
      if par_str.match?(REG_INCLUSION)
        # -- Fichier inclus --
        InputTextFile.new(book, included_file_path(par_str.match(REG_INCLUSION)[:code])).parse_and_write(pdf)
      else
        # -- (Whatever) Paragraphe --
        # @note
        #   Le +self+ sert simplement à savoir d'où vient le para-
        #   graphe injecté
        book.inject(pdf, par_str, idx, self)
      end
    end
    if not(Prawn4book.second_turn_required?) || Prawn4book.second_turn?
      puts "\n[#{affixe}] #{book.paragraphes.count} paragraphes instanciés et imprimés.".bleu
    end
  end


  REG_INCLUSION = /^\(\( include (?<code>.+) \)\)$/.freeze


  # @return Le chemin d'accès au fichier défini par la path (qui peut
  # être absolu ou relatif au livre ou à la collection) +fpath+
  def included_file_path(fpath)
    fpath = fpath.strip
    return fpath if File.exist?(fpath)
    fpath_ini = fpath.freeze
    fpath = search_included_file_in_folder(fpath_ini, self.folder)
    return fpath if fpath
    if book.in_collection?
      fpath = search_included_file_in_folder(fpath_ini, book.collection.folder)
      return fpath if fpath
    end
    raise PrawnFatalError.new(ERRORS[:building][:unfound_included_file] % fpath_ini)
  end
  def search_included_file_in_folder(affix, dossier)
    affix_ini = affix.freeze
    fpath = File.expand_path(File.join(dossier, affix_ini))
    return fpath if File.exist?(fpath)
    dossier = File.dirname(fpath).freeze
    affix   = File.basename(fpath,File.extname(fpath)).freeze
    ['', '.md','.text','.txt','.pfb.md','.pfb.txt'].each do |ext|
      fpath = File.join(dossier, "#{affix}#{ext}")
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


private

  # @private
  # 
  # Déterine le chemin d'accès au fichier contenant tout le texte
  # du livre.
  # 
  def define_path_from_arg(patharg)
    if patharg.is_a?(String) && File.exist?(patharg)
      return File.expand_path(patharg)
    end
    case patharg
    when TrueClass, NilClass
      ['txt', 'md'].each do |e|
        tpath = File.expand_path(File.join(book.folder,"texte.pfb.#{e}"))
        return tpath if File.exist?(tpath)
      end
    end
    raise PFBFatalError.new(50, {p: patharg.inspect})
  end


end #/class InputTextFile
end #/class PdfBook
end #/module Prawn4book
