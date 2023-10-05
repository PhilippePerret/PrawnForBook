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

  ##
  # Parse le fichier pour en tirer les paragraphes
  #
  # Dans cette méthode, chaque paragraphe non vide du texte est 
  # transformé en une instance correspondant à son type, image,
  # titre, bloc formaté, etc. pour produire la propriété @paragraphes
  # de l'input-file
  def parse
    #
    # Pour resetter les paragraphes textuels (pour le moment
    # seulement les numéros)
    # 
    PdfBook::NTextParagraph.reset
    # 
    # Boucle sur tous les paragraphes du texte, quels qu'ils soient
    # 
    real_all_paragraphes.map do |par|
      #
      # Analyse du paragraphe pour savoir ce que c'est
      # 
      # 
      # spy "PARAGRAPHE : #{par.inspect}"
      # puts "Traitement du paragraphe : #{par.inspect}".orange
      Paragraphe.new(pdfbook, par).parse
      # => instance PdfBook::NImage, PdfBook::NTextParagraph, etc.
    end
    # NE RIEN METTRE (MAP RETOURNÉ)
  end

  ##
  # Pour le traitement des blocs de paragraphes et typiquement, des
  # table formatée façon Markdown.
  # Un "bloc de paragraphes" est un groupe de paragraphes associés
  # pour une raison ou une autre
  # 
  # @note
  #   Pour le moment, l'idée est de transformer chaque paragraphe
  #   bloc en un seul paragraphe de code HTML
  # 
  # @param [Array[<String>]] paragraphes Liste des paragraphes
  # @return [Array[<String>]] Liste des paragraphes avec les blocs traités (pour le moment, en HTML)
  def traite_blocs_paragraphes_in(paragraphes)
    # 
    # Le signe attendu pour marquer la fin du bloc (if any)
    # 
    bloc_end_sign = nil
    # 
    # Le signe de prolongation du bloc (if any)
    # 
    bloc_prolong_sign = nil
    # 
    # Pour recevoir les paragraphes du bloc
    # 
    bloc_lines = nil
    # 
    # Pour recevoir la liste des paragraphes qui seront renvoyés
    # 
    new_paragraphes = []

    paragraphes.each do |paragraphe|

      if bloc_prolong_sign 

        if paragraphe.start_with?(bloc_prolong_sign)
          # 
          # Ce paragraphe appartient au bloc
          # 
          bloc_lines << paragraphe
          next # pour ne pas l'ajouter deux fois
        else
          # 
          # Fin d'un bloc qui se prolonge par un premier caractère
          # 
          new_paragraphes << bloc_lines
          bloc_lines = nil        
          bloc_prolong_sign = nil
        end
      elsif bloc_end_sign && paragraphe.start_with?(bloc_end_sign)
        # 
        # Fin d'un bloc qui se termine par un signe particulier
        # 
        new_paragraphes << bloc_lines
        bloc_lines = nil        
        bloc_end_sign = nil
      end

      if bloc_prolong_sign.nil? && paragraphe.match?(REG_START_BLOC_WITH_PROLONG)
        # 
        # Débug d'un bloc avec signe de prolongation (signe qu'on 
        # retrouve au début de chacune de ses lignes, comme une
        # table)
        # 
        bloc_prolong_sign = paragraphe.match(REG_START_BLOC_WITH_PROLONG)[1]
        bloc_lines = []
        # puts "bloc_prolong_sign = #{bloc_prolong_sign.inspect}"

      elsif bloc_end_sign.nil? && paragraphe.match?(REG_START_BLOC_WITH_END_SIGN)
        # 
        # Début d'un bloc avec signe de fin de bloc
        # 
        bloc_end_sign = paragraphe.match(REG_START_BLOC_WITH_END_SIGN)[1]
        bloc_lines = []
        # puts "bloc_end_sign = #{bloc_end_sign.inspect}"

      end

      if bloc_end_sign || bloc_prolong_sign
        bloc_lines << paragraphe
      else
        #
        # Quand il n'y a rien à faire
        # 
        new_paragraphes << paragraphe
      end

    end

    unless bloc_lines.nil?
      new_paragraphes << bloc_lines
    end

    return new_paragraphes
  end

  REG_START_BLOC_WITH_PROLONG   = /^(\|)/
  REG_START_BLOC_WITH_END_SIGN  = /^(DOC)$/


  # @return \Array<\String> La liste des paragraphes réels, après 
  # remplacement des textes inclus.
  def real_all_paragraphes
    traite_blocs_paragraphes_in(good_paragraphes_in(path).map do |par|
      if par.start_with?('(( include') && par.end_with?(' ))')
        paragraphes_of_included_file(par[11..-4])
      else 
        par 
      end
    end.flatten)
  end

  # @return \String Le texte complet du fichier pour le livre, après
  # inclusion des textes à inclure.
  # 
  # @note
  #   Cette méthode ne sert pas pour construire le livre, mais pour
  #   les autres commandes
  # 
  def full_text
    real_all_paragraphes.join("\n")  
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
      par.empty?
    end.reject do |par|
      if par.match?(/^<\!\-\-.+\-\->$/)
        true
      elsif par.start_with?('<!--')
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
    parags = []
    good_paragraphes_in(fpath).each do |parag|
      if parag.match?(REG_INCLUDE_FILE)
        pth = parag.match(REG_INCLUDE_FILE)[:path]
        parags += paragraphes_of_included_file(pth)
      else
        parags << parag
      end
    end
    return parags
  end
  REG_INCLUDE_FILE = /^\(\( include (?<path>.+) \)\)$/.freeze

  def search_included_file_from(fpath)
    fpath = fpath.strip
    return fpath if File.exist?(fpath)
    spy "Path relatif du fichier inclus : #{fpath.inspect}"
    fpath_ini = fpath.freeze
    fpath = search_included_file_in_folder(fpath_ini, self.folder)
    return fpath if fpath
    if pdfbook.in_collection?
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

end #/class InputTextFile
end #/class PdfBook
end #/module Prawn4book
