=begin
  Class Prawn4book::Bibliography::BibItem
  ---------------------------------------
  Gestion des items bibliographiques
=end
module Prawn4book
class Bibliography
class BibItem

  attr_reader :id, :biblio

  ##
  # Instanciation de l'item bibliographique
  # @note
  #   Il n'existe pas forcément au moment de son identification. Ça
  #   peut être l'identifiant utilisé dans le texte, qui n'existe pas
  # 
  # @param [Prawn4book::Bibliography] biblio L'instance de la bibliographie contenant l'item.
  # @param [String] bibitem_id
  # 
  def initialize(biblio, bibitem_id, data = nil)
    @biblio       = biblio
    @id           = bibitem_id
    @occurrences  = []
    @data         = data # quand fichier unique contenant toutes les données
  end

  # --- Public Methods ---

  ##
  # Pour ajouter une occurrence à l'item
  # 
  # @param [Hash] doccurrence Table contenant :page et :paragraph
  # 
  # @api public
  def add_occurrence(doccurrence)
    # SI J'UTILISE spy ICI, ÇA PLANTE POUR : can't modify frozen string…
    # spy "-> add_occurrence de :\n\tbibitem = #{title}\n\tdoccurrence : #{doccurrence.inspect}".jaune
    # 
    # Si c'est la toute première occurrence, il faut ajouter cet
    # item à la liste des items de sa bibliographie (pour qu'elle 
    # soit prise en compte)
    # 
    if @occurrences.empty?
      # SI J'UTILISE spy ICI, ÇA PLANTE POUR : can't modify frozen string…
      # spy "   (ajouté à sa bibliographie)".gris
      biblio.add_item(self)
    end
    # 
    # Ajouter cette occurrence
    # 
    @occurrences << doccurrence
  end

  # @return [String] Une liste pour le livre des occurrences de l'item
  # bibliographique courant.
  #
  # @api public
  # 
  def occurrences_as_displayed_list
    unite = TERMS[key_numerotation]
    unite = "#{unite}s" if @occurrences.count > 1
    "#{unite} #{@occurrences.map { |hoccu| hoccu[key_numerotation] }.pretty_join}"
  end

  # --- Predicate Methods ---

  ##
  # @return [Boolean] true si l'item est bien défini
  def defined?
    exist?
  end

  ##
  # @return [Boolean] true si l'item existe (sa fiche ou sa donnée
  # dans le fichier unique)
  # 
  def exist?
    if biblio.one_file?
      biblio.items.key?(id)
    else
      File.exist?(path)
    end
  end

  # --- Méthode pour cross-reference (quand Bibliography::Livres) ---

  # @return [Boolean] true si la cible +cible_id+ existe dans le
  # livre.
  def cible?(cible_id)
    crossable? && has_reference?(cible_id)
  end

  # @return true si la cible +cible_id+ existe dans le fichier
  # référence du livre
  def has_reference?(cible_id)
    data_refs.key?(cible_id.to_sym)
  end

  # @return [String] La référence à copier dans le texte
  def reference_to(cible_id)
    ref = ref_to(cible_id)
    str = PdfBook.current.page_number? ? "page #{ref[:page]}" : (ref[:paragraph] ? "paragraphe #{ref[:paragraph]}" : "page #{ref[:page]}")
    return "#{str} de <i>#{title}</i>"
  end

  # @return [Hash] table de la référence +cible_id+, contenant 
  # simplement {:page, :paragraph}, le numéro de page et de paragraph
  # pour la cible donnée dans cet item bibliographique.
  def ref_to(cible_id)
    data_refs[cible_id.to_sym]
  end

  # @return [Boolean] true si l'item (qui est un livre) peut être 
  # utilisé pour les références croisées. Il l'est si :
  # 1)  il définit un path conduisant à un livre prawn
  # 2)  il définit un path qui conduit à un fichier references.yaml
  #     contenant la définition des références (même lorsque ce n'est)
  #     pas un livre prawn
  def crossable?(or_raise = true)
    prefix_err = ERRORS[:biblio][:uncrossable] % id.to_s
    data[:refs_path]        || raise(PrawnBuildingError.new(prefix_err + ERRORS[:biblio][:crossable_requires_refs_path]))
    File.exist?(refs_path)  || begin
      if prawn_book?
        raise(PrawnBuildingError.new(prefix_err + ERRORS[:biblio][:book_requireds_building_for_refs]))
      else
        raise(PrawnBuildingError.new(prefix_err + ERRORS[:biblio][:crossable_refs_path_unfound]))
      end
    end
  rescue PrawnBuildingError => e
    raise e if or_raise
    return false
  else
    return true
  end

  # @return true si c'est un livre prawn (donc qui contient une recette)
  def prawn_book?
    File.exist?(File.join(data[:refs_path],'recipe.yaml'))
  end

  # - Volatile Data -

  # @return [Hash] La table des références du livre, pour références
  # croisées.
  def data_refs
    @data_refs ||= begin
      YAML.load_file(refs_path, **{aliases:true, symbolize_names:true})
    end
  end

  # - Data Methods -

  # @return [String] Chemin d'accès au fichier des références du livre
  def refs_path
    @refs_path ||= begin
      pth = data[:refs_path] || raise(PrawnBuildingError.new( (ERRORS[:biblio][:uncrossable] % id.to_s) + ERRORS[:biblio][:crossable_requires_refs_path]))
      pth_ini = data[:refs_path].freeze
      pth = File.join(pth, 'references.yaml') unless File.exist?(pth)
      File.exist?(pth) || begin
        # Le chemin peut être relatif
        pth = File.join(biblio.book.folder, pth_ini)
        pth = File.join(pth, 'references.yaml') if File.exist?(File.join(pth, 'references.yaml'))
      end
      #
      # Le livre peut se trouver dans la collection
      # 
      File.exist?(pth) || begin
        pth = File.expand_path(File.join(biblio.book.folder,'..',pth_ini))
        pth = File.join(pth, 'references.yaml') if File.exist?(File.join(pth, 'references.yaml'))
      end
      File.exist?(pth) || raise(PrawnBuildingError.new( (ERRORS[:biblio][:uncrossable] % id.to_s) + ERRORS[:biblio][:crossable_refs_path_unfound] % pth_ini))
      pth
    end
  end

  ##
  # Méthode appelée quand un titre explicite est donné pour l'item
  # de bibliographie (par exemple le mot au pluriel) et qui renvoie
  # le texte formaté.
  # 
  # @param [String|NilClass] actual Le mot à afficher vraiment ou nil
  def formate_for_text(actual, paragraph)
    if custom_methode_formatage == :none
      actual || title
    else
      custom_methode_formatage.call(data.dup, actual, paragraph)
    end
  end

  # @return [String] l'item de bibliographie formaté pour le 
  # texte. 
  # Soit une méthode propre est définie, soit on utilise la donnée
  # :title qui doit toujours exister pour une carte de donnée d'un
  # item de bibliographie (sauf, justement, si une méthode propre
  # est définie)
  # 
  # @note
  #   Maintenant, on ne le met plus en cache, car il dépend de la
  #   taille de police courante. On pourrait la checker, mais, 
  #   quelque part, ça serait une dépense d'énergie aussi grande…
  # 
  def formated_for_text(paragraph = nil)
    # @formated_for_text ||= formate_for_text(title, paragraph)
    formate_for_text(title, paragraph)
  end

  def custom_methode_formatage
    @custom_methode_formatage ||= self.class.formatage_in_text_method(biblio)
  end
  def self.formatage_in_text_method(biblio)
    @methodes_formatage_per_biblio ||= {}
    @methodes_formatage_per_biblio[biblio.id] ||= begin
      if defined?(FormaterBibliographiesModule) && defined?(FormaterBibliographiesModule.method("#{biblio.id}_in_text".to_sym))
        FormaterBibliographiesModule.method("#{biblio.id}_in_text".to_sym)
      else
        :none
      end
    end
  end

  # @note
  #   Je ne sais pas du tout pourquoi, mais ici, si j'utilise
  #   '@title ||=' pour mettre en cache la donnée titre, ça plante
  #   avec un cant' modify frozen string
  def title
    keytitle = biblio.respond_to?(:main_key) ? biblio.main_key : :title
    data[keytitle] || raise(ERRORS[:biblio][:bibitem_requires_title])
  end

  # @return [String] Le titre, mais normalisé pour pouvoir servir de
  # clé de classement.
  def keysort
    @keysort ||= title.normalized.downcase
  end

  # @return [Hash] Table de données de l'item bibliographique
  def data
  @data ||= begin
      case biblio.item_data_format.to_s
      when 'yaml' then YAML.load_file(path, **{aliases:true, symbolize_names:true})
      when 'json' then JSON.parse(File.read(path))
      else fatal_error(ERRORS[:biblio][:bad_format_bibitem] % biblio.item_data_format.to_s)
      end
    end
  end
  ##
  # @return [String] Chemin d'accès à la fiche de l'item
  # 
  def path
    @path ||= begin
      rf = nil
      id_min = id.dup.to_s.downcase
      id_plein = id.dup.to_s.gsub(/ /,'_')
      id_plein_min = id_min.dup.to_s.gsub(/ /,'_')
      rf_temp = File.join(biblio.folder, "%{idt}.#{biblio.item_data_format}").freeze
      [id, id_min, id_plein, id_plein_min].each do |idt|
        rf = rf_temp % {idt: idt}
        break if File.exist?(rf)
      end
      rf
    end
  end

  # - shortcut -
  def recipe
    @recipe ||= biblio.book.recipe
  end

  private

    # @return [Symbol] :page ou :paragraph en fonction du type de
    # numérotation.
    def key_numerotation
      @key_numerotation ||= recipe.page_number? ? :page : :paragraph
    end

end #/class BibItem
end #/class Bibliography
end #/module Prawn4book
