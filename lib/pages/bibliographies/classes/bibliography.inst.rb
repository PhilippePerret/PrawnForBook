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
    @as_one_file = not(File.directory?(folder)) && folder.end_with?('.yaml')
    @asfolderofcard = not(@as_one_file)
    load_items_from_file if one_file? && data_file_exist? # pour ne pas être obligé de charger quand la bibliographie n'est pas définie
  end

  ##
  # @public
  # 
  # @return true si la bibliographie possède une méthode
  # de formatage personnalisée
  # 
  def custom_formating_method?
    :TRUE == @hasformatmethod ||= true_or_false(not(custom_format_method.nil?))
  end

  ##
  # @public
  # 
  # @return [Method] La méthode de formatage personnalisée d'un item
  # de cette bibliographie DANS LE TEXTE. Pour la méthode de formatage
  # de l'item dans la bibliographie elle-même, voir la méthode
  # #custom_format_method_for_biblio
  #
  def custom_format_method
    @custom_format_method ||= begin
      if BibliographyFormaterModule
        self.extend(BibliographyFormaterModule)
        method_name = "#{id}_in_text".to_sym
        if self.methods.include?(method_name) # true ou false
          nombre_parametres = self.method(method_name).parameters.count
          nombre_parametres == 3 || raise(PFBFatalError.new(730, {method_name: method_name}))
          method_name
        end
      end
    end
  end

  ##
  # @public
  # 
  # @return true si la bibliographie possède une méthode
  # de formatage personnalisée
  # 
  def custom_formating_method_for_biblio?
    :TRUE == @hasformatmethodforbiblio ||= true_or_false(not(custom_format_method_for_biblio.nil?))
  end

  # Retourne la méthode à appeler avant toute construction de
  # bibliographie de fin d'ouvrage ou nil si elle n'existe pas
  def method_pre_building
    @method_pre_building ||= begin
      method_name = "biblio_pre_building_#{id}".to_sym
      if self.respond_to?(method_name)
        method_name
      else
        nil
      end
    end
  end

  def custom_format_method_for_biblio
    @custom_format_method_for_biblio ||= begin
      if BibliographyFormaterModule
        self.extend(BibliographyFormaterModule)
        method_name = "biblio_#{id}".to_sym
        if self.methods.include?(method_name) # true ou false
          nombre_parametres = self.method(method_name).parameters.count
          nombre_parametres == 2 || raise(PFBFatalError.new(731, {method_name: method_name, nb_args: "#{nombre_parametres}#{' seul'if nombre_parametres == 1} argument#{'s' if nombre_parametres > 1}"}))
          method_name
        end
      end
    end
  end

  # @return true si la bibliographie fonctionne avec un fichier
  # unique contenant toutes les données
  def one_file?
    @as_one_file
  end

  # @return true si le fichier unique des données existe
  def data_file_exist?
    File.exist?(folder)
  end

  # @return true si la bibliographie fonctionne avec un dossier
  # contenant toutes les cartes des données
  def cards?
    @asfolderofcard
  end

  ##
  # Pour ajouter un item bibliographique
  # 
  # @api public
  # 
  def add_item(bibitem)
    key = bibitem.id.to_s.downcase
    @items.merge!(key => bibitem)
  end

  ##
  # À l'instanciation de la bibliographie, si elle fonctionne avec
  # un fichier YAML unique contenant toutes les données, on les charge
  # dans les items
  def load_items_from_file
    YAML.load_file(folder,**{symbolize_names:true}).each do |k, ditem|
      bibitem = BibItem.new(self, k, ditem)
      add_item(bibitem)
    end
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
    # puts "@items = #{@items.keys.inspect}"
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
    #
    # On s'assure d'abord que la bibliographie elle-même
    # est bien définie
    # 
    return false if not(well_defined?)
    return get(bibitem_id)  # nil si inexistant
  end

  def par_fiche?
    :TRUE == @percard ||= true_or_false(File.directory?(folder))
  end

  # @prop [String] Chemin d'accès au dossier des fiches de la bibliographie.
  def folder
    @folder ||= begin
      pth = data[:path] || begin
        raise PFBFatalError.new(711, {prefix:ERRORS[:biblio][:biblio_malformed] % {tag:id.to_s}, tag:id.to_s})
      end
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
    :TRUE == @iswelldefined ||= true_or_false(check_if_well_defined)
  end
  def check_if_well_defined
    prefix_err = ERRORS[:biblio][:biblio_malformed] % {tag: tag}
    data.key?(:title)   || raise(PFBFatalError.new(710, **{prefix: prefix_err, tag: tag}))
    data.key?(:path)    || raise(PFBFatalError.new(711, **{prefix: prefix_err, tag: tag}))
    File.exist?(folder) || raise(PFBFatalError.new(712, **{prefix: prefix_err, tag: tag, path:data[:path]}))
  end

  # - Data Methods -

  def tag         ; id.to_s end
  def path        ; @path         ||= File.join(book.folder,data[:path])           end
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
