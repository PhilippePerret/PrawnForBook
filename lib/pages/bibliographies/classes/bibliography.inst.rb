module Prawn4book
class Bibliography

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
  # Format (extension) des fichiers des  données bibliographiques (soit JSON soit YAML)
  # 
  def item_data_format
    (data[:item_format] || 'yaml').to_s
  end

  ##
  # Format des données bibliographiques
  # 
  def data_format
    @data_format ||= File.exist?(data_format_file) && YAML.load_file(data_format_file)
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
  def main_key    ; @main_key     ||= data[:main_key] || :title end

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
end #/module Prawn4book
