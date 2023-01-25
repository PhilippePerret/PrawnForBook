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
  def initialize(biblio, bibitem_id)
    @biblio = biblio
    @id     = bibitem_id
  end

  # --- Predicate Methods ---

  ##
  # @return [Boolean] true si l'item est bien défini
  def defined?
    exist? && begin

    end
  end

  ##
  # @return [Boolean] true si l'item existe (sa fiche, donc)
  # 
  def exist?
    File.exist?(path)
  end

  # --- Méthode pour cross-reference (quand livre) ---

  # @return [Boolean] true si la cible +cible_id+ existe dans le
  # livre.
  def cible?(cible_id)
    crossable? && reference_exist?(cible_id)
  end

  # @return true si la cible +cible_id+ existe dans le fichier
  # référence du livre
  def has_reference?(cible_id)
    data_refs.key?(cible_id.to_sym)
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
      pth = File.join(pth, 'references.yaml') unless File.exists?(pth)
      File.exist?(pth) || begin
        # Le chemin peut être relatif
        pth = File.join(biblio.book.folder, pth_ini)
        pth = File.join(pth, 'references.yaml') if File.exist?(File.join(pth, 'references.yaml'))
      end
      File.exist?(pth) || raise(PrawnBuildingError.new( (ERRORS[:biblio][:uncrossable] % id.to_s) + ERRORS[:biblio][:crossable_refs_path_unfound] % pth_ini))
      pth
    end
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
    @path ||= File.join(biblio.folder, "#{id}.#{biblio.item_data_format}")
  end

end #/class BibItem
end #/class Bibliography
end #/module Prawn4book
