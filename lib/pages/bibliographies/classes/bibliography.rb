module Prawn4book
class Bibliography
###################       CLASSE      ###################
  
class << self
  # @prop Table des bibliographies avec en clé l'identifiant singulier
  # de la bibliographie et en value l'instance Prawn4Book::Bibliography
  attr_reader :biblios

  # @prop {Symbol} :page ou :paragraph en fonction du type de
  # pagination du livre.
  attr_accessor :page_or_paragraph_key

  ##
  # Appelé en bas de ce fichier
  # 
  def init
    @biblios= {}
  end

  ##
  # Fin de la préparation des bibliographies
  # 
  # @note
  #   Elle se fait après que toutes le bibliographies ont été 
  #   instanciées et vérifiées
  # 
  def prepare
    # 
    # Définition de l'expression régulière qui va permettre de
    # récupérer tous les items bibliographiques dans les paragraphes
    # 
    self.const_set('REG_OCCURRENCES', /(#{biblios.keys.join('|')})\((.+?)\)/)
  end

  # @return true s'il y a des marques bibliographiques (donc des
  # bibliographie)
  def any?
    not(biblios.empty?)
  end

  def get(biblio_tag, book = nil)
    @biblios[biblio_tag.to_sym] || new(book, biblio_tag)
  end

  ##
  # Méthode appelée pour imprimer une bibliographie dans le
  # livre sur la page courante.
  # 
  def print(biblio_tag, book, pdf)
    biblio = @biblios[biblio_tag.to_sym] || begin
      err_msg = ERRORS[:biblio][:biblio_undefined] % biblio_tag
      spy err_msg.rouge
      fatal_error err_msg
    end
    require 'lib/pages/bibliographies'
    page = Prawn4book::Pages::Bibliography.new(book, biblio)
    page.build(pdf)
  end

  ##
  # Pour ajouter une bibliographie
  # 
  # @param [Prawn4book::Bibliography] biblio La bibliographie à ajouter
  # 
  def add_biblio(biblio)
    @biblios.merge!(biblio.id.to_sym => biblio)
  end

  ##
  # Pour requérir le formater du livre +book+
  # 
  # @param [Prawn4book::PdfBook] book L'instance du livre
  # 
  def require_formaters(book)
    book.require_module_formatage
    if defined?(FormaterBibliographiesModule)
      Bibliography.extend FormaterBibliographiesModule
    end
  end

  # Au cours du parsing des paragraphes, on utilise cette méthode
  # pour ajouter une occurrence à une des bibliographies
  # 
  # @param [String] bib_tag Tag de la bibliographie
  # @param [Bibliography::BibItem] bibitem L'item de bibliographie (par exemple un livre ou un film)
  # @param doccurrence {Hash} Données de l'occurrence
  # 
  # @return L'instance Bibliography concernée
  # 
  def add_occurrence_to(bib_tag, bibitem, doccurrence)
    biblio = get(bib_tag) || erreur_fatale(ERRORS[:biblio][:biblio_undefined] % [bib_tag, bibitem.id])
    if bibitem.is_a?(Symbol) || bibitem.is_a?(String)
      bibitem = biblio.get(bibitem.to_sym)
    end
    bibitem.add_occurrence(doccurrence)
    return bibitem
  end

  # Ajoute une occurrence pour un livre
  # La méthode est utilisée pour le moment pour les références
  # croisée
  # 
  def add_occurrence_book(book, paragraph)
    add_occurrence_to('livre', book, {page: paragraph.first_page, paragraph: paragraph.numero})
  end

  ##
  # Pour instancier Bibliography::Livres qui est une instance de
  # bibliographie particulière, puisqu'elle est créée chaque fois,
  # contrairement aux autres bibliographies qui dépendent des livres
  # des collections, etc.
  # 
  # @note
  #   Avant, c'est toujours 'livre' pour identifier les livres.
  #   Maintenant, c'est une donnée qu'on peut régler dans la recette,
  #   au path [:bibliographies][:book_identifiant]
  def init_livres(pdfbook)
    self.const_set('Livres', new(pdfbook, pdfbook.recipe.biblio_book_identifiant))
  end

end #/<< self Bibliography


###################       INSTANCE      ###################


  attr_reader :pdfbook 
  alias :book :pdfbook
  attr_reader :id
  attr_reader :items

  ##
  # Instanciation d'une bibliographie
  # 
  # @param [Prawn4book::PDFBook] pdfbook Le livre en train d'être traité.
  # @param [String] biblio_id Identifiant singulier de la bibliographie, par exemple 'livre' ou 'film'.
  # 
  def initialize(pdfbook, biblio_id)
    @pdfbook  = @book = pdfbook || raise(PrawnBuildingError.new(ERRORS[:biblio][:instanciation_requires_book]))
    @id       = biblio_id.to_sym
    @items    = {}
    self.class.add_biblio(self)
  end

  ##
  # Pour ajouter un item bibliographique
  # 
  # @api public
  def add_item(bibitem)
    @items.merge!(bibitem.id => bibitem)
  end

  ##
  # Format des données bibliographiques (soit JSON soit YAML)
  # 
  def item_data_format
    (data[:item_format] || 'yaml').to_s
  end

  ##
  # @return [Prawn4book::Bibliography::BibItem|NilClass] l'item bibliographique
  # d'identifiant +bibitem_id+, par exemple un livre ou un film en
  # tant qu'entité bibliographique. Returne Nil s'il n'existe pas.
  # 
  # @param [String] bibitem_id Identifiant unique de l'entité bibliographique
  # 
  def get(bibitem_id)
    @items[bibitem_id] || begin
      bibitem = BibItem.new(self, bibitem_id)
      bibitem.exist? ? bibitem : nil
    end    
  end

  ##
  # S'assure que l'item de bibliographie existe
  # 
  # @param [String] bibitem_id L'identifiant de l'élément
  # 
  # @return [Boolean] true si la bibliographie existe.
  def exist?(bibitem_id)
    well_defined? && !get(bibitem_id).nil?
  end

  # @prop [String] Chemin d'accès au dossier des fiches de la bibliographie.
  def folder
    @folder ||= begin
      pth = data[:path] || raise(PrawnBuildingError.new((ERRORS[:biblio][:biblio_malformed] % id.to_s) + ERRORS[:biblio][:malformation][:path_undefined]))
      pth_ini = data[:path].freeze
      # 
      # Si c'est un chemin relatif dans le dossier du livre ou de
      # la collection.
      # 
      pth = File.expand_path(File.join(book.folder, pth_ini)) unless File.exist?(pth)
      pth = File.expand_path(File.join(book.collection.folder, pth_ini)) if not(File.exist?(pth)) && not(book.collection.nil?)
      # 
      # Pour @folder
      # 
      pth
    end
  end

  ##
  # Les données de la bibliographie telles que définies dans le 
  # fichier recette du livre ou de la collection.
  def data
    @data ||= get_data_biblios(id).merge(tag: id, id: id)
  end

  ##
  # @return [Boolean] true si la bibliographie est bien définie ou
  # raise une erreur dans le cas contraire.
  # 
  def well_defined?
    prefix_err = ERRORS[:biblio][:biblio_malformed] % tag
    data.key?(:title)   || raise(PrawnBuildingError.new(prefix_err + ERRORS[:biblio][:malformation][:title_undefined]))
    data.key?(:path)    || raise(PrawnBuildingError.new(prefix_err + ERRORS[:biblio][:malformation][:path_undefined]))
    File.exist?(folder) || raise(PrawnBuildingError.new(prefix_err + (ERRORS[:biblio][:malformation][:path_unfound] % data[:path])))
  end

  # - Data Methods -

  def tag         ; id.to_s end
  def title       ; @title        ||= data[:title]          end
  def title_level ; @title_level  ||= data[:title_level]||1 end

  private


    ##
    # Pour obtenir les données recette de la bibliographie d'identifiant
    # +biblio_id+
    # 
    # @return [Hash] Table des données de la bibliographie.
    # 
    # @param [String] biblio_id Identifiant singulier de la bibliographie (p.e. 'livre' ou 'film')
    # 
    def get_data_biblios(biblio_id)
      book.recipe.bibliographies[:biblios] || begin
        raise PrawnBuildingError.new(ERRORS[:biblio][:data_undefined])
      end
      book.recipe.bibliographies[:biblios][biblio_id] || begin
        raise PrawnBuildingError.new(ERRORS[:biblio][:biblio_undefined] % biblio_id)
      end
    end

end #/ class Bibliography

##
# Au chargement du module, on initialise la classe
# 
Bibliography.init

end #/module Prawn4book
