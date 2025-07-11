=begin
  Class Prawn4book::Bibliography::BibItem
  ---------------------------------------
  Gestion des items bibliographiques
=end
module Prawn4book
class Bibliography
class BibItem

  PICTOBIB = '<font name="PictoPhil" size="14"><color rgb="555555">%s</color></font>'

  attr_reader :id, :biblio
  attr_reader :occurrences

  ##
  # Instanciation de l'item bibliographique
  # @note
  #   Il n'existe pas forcément au moment de son identification. Ça
  #   peut être l'identifiant utilisé dans le texte, qui n'existe pas
  # 
  # @param biblio [Prawn4book::Bibliography]
  # 
  #   Instance de la bibliographie contenant l'item.
  # 
  # @param bibitem_id [String]
  # 
  #   Identifiant de l'item bibliographique
  # 
  # @param data [Hash]
  # 
  #   Quand les données viennent d'un fichier unique contenant 
  #   toutes les données.
  # 
  def initialize(biblio, bibitem_id, data = nil)
    @biblio       = biblio
    @id           = bibitem_id
    @data         = data
    @occurrences  = []
  end

  # --- Public Methods ---

  ##
  # Formatage de l'élément bibliographique DANS LE TEXTE
  # Pour le formatage de l'élément dans la bibliographie, voir
  # la méthode biblio_<biblio id> qui doit être définie pour le livre
  # ou la collection.
  # 
  # @return [String] l'item de bibliographie formaté pour le 
  # texte. 
  # 
  # Soit une méthode propre est définie, soit on utilise la donnée
  # :title qui doit toujours exister pour une carte de donnée d'un
  # item de bibliographie (sauf, justement, si une méthode propre
  # est définie avec :main_key dans la recette du livre/de la 
  # collection)
  # 
  # @note
  #   On ne le met pas en cache, car l'affichage peut dépendre de
  #   beaucoup de choses, et notamment du +context+.
  # 
  # @param [Hash] context   Contexte d'écriture, notamment le paragraphe (donc la page, le numéro de paragraphe, la police courante, etc.)
  # @param [String] actual  Le texte explicite peut-être fourni. Dans ce cas, c'est lui qu'on met en forme.
  #
  def formated(context, actual)
    if biblio.custom_formating_method?
      biblio.send(biblio.custom_format_method, self, context, actual)
    else
      actual || title
    end
  end

  #
  # Pour pouvoir utiliser <instance>.<propriété> pour
  # obtenir les valeurs de l'instance
  # 
  def method_missing(methode, *args, &block)
    if data.key?(methode)
      data[methode]
    elsif biblio.respond_to?(methode)
      if args
        biblio.send(methode, *args)
      else
        biblio.send(methode)
      end
    else
      raise NoMethodError.new(methode, args, &block)
    end
  end

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
    # Si la propriété :hybrid n'est pas donnée, on la crée
    # 
    doccurrence.key?(:hybrid) || doccurrence.merge!(hybrid: "#{doccurrence[:page]}-#{doccurrence[:paragraph]}")
    # 
    # Ajouter cette occurrence
    # 
    unless @occurrences.include?(doccurrence)
      @occurrences << doccurrence
    end
  end

  # @return [String] Une liste pour le livre des occurrences de l'item
  # bibliographique courant.
  # 
  # #occurrences_pretty_list 
  #   retourne une liste qui se termine par "et" au lieu de 
  #   la virgule
  #
  # #occurrences_list
  #   retourne une liste où toutes les occurrences sont séparées
  #   par ', '
  #
  # @api public
  # 
  def occurrences_pretty_list(main_text:)
    main_data = {
      text:         main_text,
      fonte:        biblio.fonte,
      fonte_normal: biblio.fonte_number_normal,
      fonte_main:   biblio.fonte_number_main,
      fonte_minor:  biblio.fonte_number_minor,
      key_ref:      key_numerotation
    }
    Occurrences.as_formatted(main_data, @occurrences)
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
      File.exist?(path) || File.exist?(path_txt)
    end
  end

  def exists_or_raises
    exist? || raise(PFBFatalError.new(714, **{id: id}))
  end

  # --- Méthode pour cross-reference (quand Bibliography::Livres) ---

  # @return [Boolean] true si la cible +cible_id+ existe dans le
  # livre.
  def cible?(cible_id)
    crossable?(true) && has_reference?(cible_id)
  end

  # @return true si la cible +cible_id+ existe dans le fichier
  # référence du livre
  def has_reference?(cible_id)
    data_refs.key?(cible_id.to_sym)
  end

  # @return [String] La référence à copier dans le texte
  def reference_to(cible_id)
    ref = ref_to(cible_id) || begin
      raise PrawnBuildingError.new(ERRORS[:references][:cross_ref_unfound] % [cible_id, self.id])
    end
    str = case pdfbook.recipe.num_page_format
    when 'parags'
      ref[:paragraph] ? "paragraphe #{ref[:paragraph]}" : "page #{ref[:page]}"
    when 'pages'
      "page #{ref[:page]}"
    when 'hybrid'
      ref[:hybrid]
    end
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


  # @return [String] Titre pour l’item de bibliographie
  # 
  # @note
  #   Je ne sais pas du tout pourquoi, mais ici, si j'utilise
  #   '@title ||=' pour mettre en cache la donnée titre, ça plante
  #   avec un cant' modify frozen string (à quel moment est-elle 
  #   gelée ?…)
  def title
    keytitle = biblio.respond_to?(:main_key) ? biblio.main_key.to_sym : :title
    data[keytitle] || raise(PFBFatalError.new(713, {id: self.id, tag:biblio.tag}))
  end

  # @return [String] Le titre, mais normalisé pour pouvoir servir de
  # clé de classement.
  def keysort
    @keysort ||= title.normalized.downcase
  end

  def temp_data
    data.merge(occ_list: occurrences_pretty_list)
  end

  # @return [Hash] Table de données de l'item bibliographique
  def data
  @data ||= begin
      case biblio.item_data_format.to_s
      when 'yaml' then
        if File.exist?(path_txt)
          # Si le fichier plus simple txt existe, on le préfère
          get_data_in_txt_file(path_txt)
        else
          # Sinon ça doit être un fichier .yaml normal
          YAML.load_file(path, **{aliases:true, symbolize_names:true})
        end
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

  def path_txt
    @path_txt ||= begin
      rf = nil
      id_min = id.dup.to_s.downcase
      id_plein = id.dup.to_s.gsub(/ /,'_')
      id_plein_min = id_min.dup.to_s.gsub(/ /,'_')
      rf_temp = File.join(biblio.folder, "%{idt}.txt").freeze
      [id, id_min, id_plein, id_plein_min].each do |idt|
        rf = rf_temp % {idt: idt}
        break if File.exist?(rf)
      end
      rf
    end
  end

  # Les données peuvent être aussi placées dans un simple fichier
  # texte. Dans ce cas, la première ligne est le :title, la suite
  # (pour le moment *toute* la suite) est la description.
  # 
  def get_data_in_txt_file(path_txt)
    lines = File.read(path_txt).split("\n")
    {
      title: lines.shift,
      description: lines.join("\n").strip
    }
  end

  # Les données recette pour cette bibliographie

  # @shortcut vers la recette
  def recipe
    @recipe ||= biblio.book.recipe
  end

  private

    # @return [Symbol] :page ou :paragraph en fonction du type de
    # numérotation.
    # 
    # @note
    # 
    #   Dans le mode hybride (page+paragraphe), page_number? retourne
    #   true puisqu'il faut écrire le numéro de page en pagination
    # 
    def key_numerotation
      @key_numerotation ||= recipe.references_key
    end

end #/class BibItem
end #/class Bibliography
end #/module Prawn4book
