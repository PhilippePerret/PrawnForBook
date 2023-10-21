require_relative 'ReferencesTable'

module Prawn4book
class PdfBook

  attr_reader :folder

  ##
  # Instanciation du PdfBook qui va permettre de générer le fichier
  # PDF prêt à l'impression.
  # 
  # @param [String] folder Path to folder book.
  def initialize(folder)
    @folder = folder
  end

  # Pour ouvrir le livre dans Aperçu, en double pages
  def open_book
    if File.exist?(pdf_path)
      `osascript "#{APP_FOLDER}/resources/bin/open_book.scpt" "#{pdf_path}"`
    else
      puts "Il faut produire le livre, avant de pouvoir le lire ! (jouer `prawn-for-book build')".rouge
    end
  end

  # --- Usefull Methods ---

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
    if in_collection? && (fpath = exist?([collection.folder, rpath]))
      return fpath
    elsif (fpath = exist?([folder,rpath]))
      return fpath
    else
      nil
    end
  end

  def exist?(args)
    f = File.join(*args)
    return f if File.exist?(f)
  end

  # --- Objects Methods ---

  def font_or_default(font_name)
    fontes.key?(font_name) ? font_name : second_font  
  end

  ##
  # Instance pour gérer les pages
  # 
  def pages(pdf = nil)
    @pages ||= PdfBook::PageManager.new(self, pdf)
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

  ##
  # Pour gérer les notes dans le livre
  # 
  def notes_manager
    @notes_manager ||= PdfBook::NotesManager.new(self)    
  end

  ##
  # Pour gérer l'index du livre
  # 
  def page_index
    @page_index ||= begin
      require 'lib/pages/page_index'
      Prawn4book::Pages::PageIndex.new(self)
    end
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

  # --- Paths Methods ---

  def text_file
    @text_file ||= inputfile.path
  end

  def pdf_path
    @pdf_path ||= File.join(folder,'book.pdf')
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
