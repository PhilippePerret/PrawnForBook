module Prawn4book
class PdfBook
class ReferencesTable

  REG_CIBLE_REFERENCE = /^<\-\((.+?)\)$/.freeze
  REG_LIEN_REFERENCE = /^\->\((.+?)\)$/.freeze

  attr_reader :pdfbook
  attr_reader :table

  attr_accessor :second_turn

  def initialize(pdfbook)
    @pdfbook = pdfbook
  end

  ##
  # Initialisation
  # 
  def init
    @table = {}
    @cross_references = {}
  end

  ##
  # Ajout d'une référence interne rencontrée au cours du parsing
  # du texte (du paragraphe ou autre — titre, cellule de table, etc.)
  # 
  # @note
  #   Il s'agit uniquement des références internes. Pour les références
  #   croisées, voir la méthode suivante.
  # 
  # @param ref_id {String} IDentifiant de la référence
  # @param ref_data {Hash} Données de la référence, contient
  #         {:page, :paragraph, :hybrid}
  # 
  def add(ref_id, ref_data)
    return if second_turn
    ref_id = ref_id.to_sym
    if table.key?(ref_id)
      raise "Reference '#{ref_id}' already exists."
    else
      table.merge!(ref_id => ref_data)
    end
  end

  ##
  # Traitement d'une référence croisée.
  # 
  # Méthode appelée lors du parse d'un texte (de paragraphe ou autre)
  # lorsqu'une référence croisée est rencontrée. Elle permet en même
  # temps de vérifier la pertinence de la référence (son existence)
  # et de renvoyer le texte à écrire.
  # 
  # @return [String] Le texte pour remplacer l'appel à la cible
  # 
  # @oaram [String] book_id   L'identifiant du livre dans la bibliographie
  # @param [String] cible     L'identifiant de la cible dans le livre
  # 
  def add_and_get_cross_reference(book_id, cible_id)
    book = Bibliography::Livres.get(book_id) || begin
      # - quand le livre n'existe pas -
      raise PrawnBuildingError.new(ERRORS[:references][:cross_book_undefined] % book_id)
    end
    book.cible?(cible_id) || begin
      # - quand la cible n'existe pas (ou le livre) -
      PrawnBuildingError.new(ERRORS[:references][:cross_ref_unfound] % [cible_id, book_id])
    end
    
    return book.reference_to(cible_id)
  end

  ##
  # Appel d'une référence
  # ---------------------
  # C'est la méthode qui retourne l'appel vers la destination 
  # voulu. Le paragraphe est fourni car, en cas de référence croisée
  # il faut ajouter une entrée dans la bibliographie des livres.
  # 
  # Au premier tour, si elle n'est pas définie, on indique qu'il
  # faudra recommencer un tour.
  # 
  # @param ref_id {String} L'ID de la référence. En cas de référence
  #               croisée, on a "IDBOOK:ref_id"
  # @param paragraph {NTextParagraph} Instance du paragraphe conte-
  #               tant l'appel.
  # 
  def get(ref_id, paragraph)
    #
    # Traitement particulier des références croisées
    # 
    return get_cross_reference(ref_id, paragraph) if ref_id.match?(':')
    # 
    # Sinon, une référence simple dans le livre
    # 
    ref_id = ref_id.to_sym
    ref = table[ref_id] || begin
      set_un_appel_sans_reference
      {page:"xx", paragraph:'xxx', hybrid:'xx-xxx'}
      return "(( ->(#{ref_id}) ))" # -- pour essayer que la seconde fois il soit corrigé
    end
    call_to(ref)
  end


  ##
  # Enregistrement des la liste des références
  # 
  # @rappel 
  # 
  #   Cette table enregistrée dans un fichier ne sert que pour les
  #   références croisées. Pour un livre, elles sont recalculées 
  #   chaque fois.
  # 
  def save
    File.write(path, table.to_yaml)
  end

  # --- Helpers Methods ---

  # @return [String] la texte qui doit remplacer la balise target 
  # dans le texte
  # @note
  #   Les références croisées utilisent une autre méthode.
  # 
  def call_to(ref)
    case pdfbook.recipe.page_num_type
    when 'pages'
      "page #{ref[:page]}"
    when 'parags'
      ref[:paragraph] ? "paragraphe #{ref[:paragraph]}" : "page #{ref[:page]}"
    when 'hybrid'
      ref[:hybrid]
    end
  end

  # --- Predicate Methods ---

  # @return true Si le livre contient des références
  # 
  def any?
    table.count > 0
  end

  # @return true si un appel est resté sans référence
  # (cela se produit quand un appel de référence se trouve avant
  # la référence en question — donc sur une page ou un paragraphe 
  # avant)
  def has_one_appel_sans_reference?
    :TRUE == @hasoneappelsansref
  end
  # Quand on trouve un appel de référence sans référence
  # définie.
  def set_un_appel_sans_reference
    @hasoneappelsansref = :TRUE
  end

  # --- Path Methods ---

  def path
    @path ||= File.join(pdfbook.folder,'references.yaml')
  end

end #/class ReferencesTable
end #/class PdfBook
end #/module Prawn4book
