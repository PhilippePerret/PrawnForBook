require_relative 'ReferencesTable'

module Prawn4book
class PdfBook

  attr_reader :folder

  # [PdfBook::ColumnsBox] Quand un affichage par colonne est en 
  # cours, cette propriété est déinie.
  attr_accessor :columns_box # noter le "s" (il n’y en a pas dans Prawn::ColumnBox)

  ##
  # Instanciation du PdfBook qui va permettre de générer le fichier
  # PDF prêt à l'impression.
  # 
  # @param [String] folder Path to folder book.
  def initialize(folder)
    @folder       = folder
    @columns_box  = nil
  end

  def reset
    # Pour mettre absolument tous les paragraphs rencontrés (même
    # les lignes vides)
    @paragraphes            = []
    @current_table          = nil
    @current_comment        = nil
  end


  # --- Building Methods ---

  # @api
  # 
  # = main =
  # 
  # Méthode principale qui reçoit le +paragraph_str+ d'une +source+
  # qui peut être le fichier texte.pfb.md (avant tout), un fichier
  # inclus ou une méthode d'utilisateur, qui l'instancie et l'injecte
  # dans le livre en construction.
  # 
  # @note
  #   Pour que ça fonctionne de façon optimale, il faut absolument
  #   que tous les paragraphes passent par ici.
  # 
  def inject(pdf, paragraph_str, idx = 0, source = 'user_method')

    # Si une table est en cours de traitement (@current_table non 
    # nil) et que +paragraph_str+ n'est plus un élément de table (il
    # ne commence pas ni ne finit par "|") alors on met fin à la 
    # table et on l'imprime.
    # Si +paragraph_str+ est encore un élément de table, on ajoute
    # la ligne à la table et on s'en retourne.
    # 
    # @note
    #   Noter qu'avec cet algorithme, s'il y a une table comme 
    #   dernier élément dans le livre, elle ne sera jamais imprimée
    #   TODO Régler le problème en fin de parsing.
    # 
    if @current_table
      if paragraph_str.match?(AnyParagraph::REG_END_TABLE)
        # - On doit imprimer le paragraphe-table -
        # puts "ON doit imprimer la table à la page #{pdf.page_number}".jaune
        par = @current_table
        @current_table = nil 
        # - On poursuit pour l’imprimer ci-dessous -
      elsif paragraph_str.match?(AnyParagraph::REG_TABLE)
        # On met le paragraphe dans la table et on s'en retourne
        @current_table.add_line(paragraph_str.strip)
        return
      end
    end

    # Si un bloc de code est ouvert (par ~~~[langage] ou ```[langage])
    if @current_code_block && paragraph_str.match?(AnyParagraph::REG_END_CODE_BLOCk)
      # <= fin du bloc de code
      # => On doit l’imprimer
      @current_code_block.print(pdf)
      @current_code_block = nil
      return
    end 

    # Si un commentaire est ouvert (par "[#" sur une ligne)
    if @current_comment
      if paragraph_str.match?(AnyParagraph::REG_END_COMMENT)
        @current_comment.add(paragraph_str[0...-2].strip)
        @current_comment = nil
      else
        @current_comment.add(paragraph_str)
      end
      # Dans tous les cas (si un commentaire *est* ou *était* 
      # ouvert), on s'en retourne
      return
    end

    # - Instanciation du paragraphe -
    # (ça a pu être fait avant avec une table)

    par || begin
      par = AnyParagraph.instance_type_from_string(
        book:self, 
        string:paragraph_str, 
        indice:idx,
        options: {is_code: not(@current_code_block.nil?)}
      )
      if par.is_a?(NTable)
        @current_table = par
        return
      elsif par.is_a?(CodeBlock)
        @current_code_block = par
        return
      elsif par.is_a?(EmptyParagraph) && par.comment?
        @current_comment = par
      end
    end

    # Réglage de l'index absolu.
    par.abs_index = @paragraphes.count
    # Définition de la source (utile pour certains messages)
    par.source = source

    # - Ajout à la liste des paragraphes -
    @paragraphes << par

    # - S’il y a une impression en colonnes multiples, il ne faut
    #   pas graver tout de suite -
    unless columns_box.nil?
      if par.pfbcode? && par.multi_columns_end?
        self.columns_box.print(pdf)
        self.columns_box = nil
      else
        columns_box.add(par)
      end
      return
    end

    # - Si le paragraphe appartient à un bloc de code -
    # (pas d’impression immédiate)
    if @current_code_block
      @current_code_block.add(par)
      return
    end

    ###########################################
    ### IMPRESSION DU (WHATEVER) PARAGRAPHE ###
    ###########################################
    print_paragraph(pdf, par)

  end

  # Impression proprement dite du paragraphe
  # 
  # La méthode est aussi bien appelée au premier tour qu'au second
  def print_paragraph(pdf, paragraphe)

    # @semantic
    bloc_note_en_cours = @current_bloc == :notes_page

    # - Pré-traitement en fonction du bloc courant (if any) -
    if paragraphe.note_page?
      unless bloc_note_en_cours
        notes_manager.init_bloc_notes(pdf)
        @current_bloc = :notes_page
      end
    elsif bloc_note_en_cours && not(paragraphe.note_page?)
      # Note
      # ----
      # Il faut mettre la fermeture du bloc avant l’écriture du 
      # paragraphe courant qui n’est pas un paragraghe de note
      notes_manager.end_bloc(pdf)
      @current_bloc = nil
    end

    # --- IMPRESSION ---
    paragraphe.print(pdf)
    unless Prawn4book.soft_feedback?
      STDOUT.write '.'.vert
    end

  end


  # --- Usefull Methods ---

  # @api stable
  # 
  # Retourne le premier path du livre/collection trouvé dans la
  # liste de propositions fournies, qui peuvent être des simples noms
  # de fichier ou des chemins relatifs.
  # 
  def file_exist?(ary)
    ary = ary.compact 
    ary.each do |fname|
      fpath = existing_path(fname)
      return fpath unless fpath.nil?
    end
    return nil
  end

  # @api
  # 
  # Retourne le chemin d'accès complet à un fichier appartenant au
  # livre ou à la collection du livre quand on fournit +rpath+ qui
  # peut être :
  #   - un chemin d'accès déjà complet
  #   - un chemin d'accès relatif à la collection (si collection)
  #   - un chemin d'accès relatif au livre
  # 
  def existing_path(rpath)
    rpath = File.expand_path(rpath)
    return rpath if File.exist?(rpath)
    # Un fichier dans le dossier du livre a toujours la priorité sur
    # le même fichier dans la collection
    if (fpath = exist?([folder,rpath]))
      return fpath
    elsif in_collection? && (fpath = exist?([collection.folder, rpath]))
      return fpath
    else
      nil
    end
  end

  # @api
  # Pour ouvrir le livre dans Aperçu, en double pages
  def open_book
    if File.exist?(pdf_path)
      `osascript "#{APP_FOLDER}/resources/bin/open_book.scpt" "#{pdf_path}"`
    else
      puts "Il faut produire le livre, avant de pouvoir le lire ! (jouer `prawn-for-book build')".rouge
    end
  end

  # --- Predicate Methods ---

  def exist?(args)
    f = File.join(*args)
    return f if File.exist?(f)
  end

  # --- Objects Methods ---

  # @prop [Array<AnyParagraph>] Paragraphes
  # 
  # Tous les paragraphes du texte, instanciés. Noter que dans la
  # nouvelle version de l'application (version 2 LINE), absolument
  # tous les paragraphes du fichier sont instanciés, même les 
  # paragraphe vide (Prawn4book::PdfBook::EmptyPar). De même que tous
  # les paragraphes produits par les méthodes, sauf exception (quand
  # l'utilisateur ne passe pas par les méthodes d'injection)
  # 
  # @note
  # 
  #   Attention, pour le moment, cette liste ne contient que les 
  #   paragraphes du fichier source, pas ceux des fichiers éventuel-
  #   lement inclus (qui ont eux aussi cette propriété, puisque ce 
  #   sont eux aussi des InputTextFile)
  # 
  def paragraphes
    @paragraphes
  end

  # def font_or_default(font_name)
  #   fontes.key?(font_name) ? font_name : second_font  
  # end

  ##
  # Instance pour gérer les pages
  # 
  def pages(pdf = nil)
    @pages ||= PdfBook::PageManager.new(self, pdf)
  end

  # @return la page de numéro +number+
  # 
  def page(number)
    return pages.page(number)
  end

  def table_of_content
    @table_of_content ||= PdfBook::TableOfContent.new(self)
  end
  ##
  # Instance pour gérer les références (internes et croisées) 
  # du livre courant.
  # 
  # @note
  #   Les références sont une liste de cibles dans le texte ou dans
  #   le texte d'un autre livre, qui peuvent être atteinte depuis
  #   un pointeur dans le texte.
  #
  def table_references
    @table_references ||= begin
      PdfBook::ReferencesTable.new(self).tap do |reft|
        reft.init
      end
    end
  end
  alias :references :table_references

  ##
  # Instance pour gérer les notes dans le livre
  # 
  def notes_manager
    @notes_manager ||= PdfBook::NotesManager.new(self)    
  end

  ##
  # Instance pour gérer l'index du livre
  # 
  def page_index
    @page_index ||= begin
      require 'lib/pages/page_index'
      Prawn4book::Pages::PageIndex.new(self)
    end
  end

  ##
  # Instance pour gérer les index personnalisés du livre
  # 
  def index_manager
    @index_manager ||= PdfBook::IndexManager.new(self)
  end

  # Retourne l’instance [PdfBook::Index] de l’index personnalisé
  # d’identifiant +index_id+
  # 
  # @note
  #   Attention : il n’existe pas forcément au moment de son
  #   appel.
  # 
  def index(index_id)
    index_manager.get(index_id)
  end

  # Instance pour gérer les abréviations
  #
  def abbreviations
    @abbreviations ||= PdfBook::TableAbbreviations.new(self)
  end

  def glossary
    @glossary ||= PdfBook::Glossary.new(self)
  end

  def table_illustrations
    @table_illustrations ||= PdfBook::TableIllustrations.new(self)
  end

  def collection
    @collection ||= in_collection? ? Collection.new(self) : nil
  end

  # @prop L'instance du fichier texte qui contient le texte à
  # traiter.
  # 
  def inputfile
    @inputfile ||= InputTextFile.new(self, recette[:text_path])
  end

  # --- Predicate Methods ---
  
  # @return true si le document appartient à une collection
  def in_collection?
    :TRUE == @isincollection ||= true_or_false(check_if_collection)
  end

  def has_text?
    File.exist?(text_file)
  end

  # --- Data Methods ---

  def title
    @title ||= recipe.title
  end

  def subtitle
    @subtitle ||= recipe.subtitle
  end

  # --- Paths & Names Methods ---

  # Préfixe fourni dans la recette ou en ligne de commande
  def filename_suffix
    @filename_suffix ||= CLI.options[:suffix] || ""
  end
  
  def filename
    @filename ||= File.basename(File.dirname(text_file))
  end

  def text_file
    @text_file ||= inputfile.path
  end

  def pdf_path
    @pdf_path ||= File.join(folder, book_pdf_name)
  end

  def book_pdf_name
    @book_pdf_name ||= "book#{filename_suffix}#{"_bat" if Prawn4book.bat?}.pdf"
  end

  private

    # @return [String] Nom du fichier recette
    def recipe_name ; 'recipe.yaml' end

    ##
    # @return true si le livre appartient à une collection,
    # en checkant que cette collection existe bel et bien.
    def check_if_collection
      return File.exist?(File.join(File.dirname(folder),'recipe_collection.yaml'))
    end

end #/class PdfBook
end #/module Prawn4book
