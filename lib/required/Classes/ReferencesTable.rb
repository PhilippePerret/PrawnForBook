module Prawn4book
class PdfBook
class ReferencesTable

  REG_CIBLE_REFERENCE = /^<\-\((.+?)\)$/.freeze
  REG_LIEN_REFERENCE = /^\->\((.+?)\)$/.freeze

  attr_reader :book
  attr_reader :table

  def initialize(book)
    @book = book
  end

  ##
  # Initialisation
  # 
  def init
    @table = {}
    @cross_references   = {}
    # - Références non trouvées au premier tour -
    # En clé : le ticket de poissonnerie attribué pour le texte et
    # en valeur l'identifiant de la référence qu'on doit retrouver
    # par <self>.get(ref_id) et qui retourne la référence à coller 
    # dans le texte.
    @wanted_references  = {}
  end


  # -raccourci -
  def second_turn?
    Prawn4book.second_turn?
  end

  def third_turn? # encore possible ?
    Prawn4book.turn == 3
  end

  ##
  # Ajout d'une référence interne rencontrée au cours du parsing
  # du texte (du paragraphe ou autre — titre, cellule de table, etc.)
  # 
  # @note
  #   Il s'agit uniquement des références croisées "internes", c'est
  #   à dire dans le même livre. Pour les références à d'autres li-
  #   vres, voir la méthode suivante.
  # 
  # @param ref_id {String} IDentifiant de la référence
  # @param ref_data {Hash} Données de la référence, contient
  #         {:page, :paragraph, :hybrid}
  # 
  def add(ref_id, ref_data)
    return if second_turn?
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
  # Il sert aussi à gérer les références ultérieures
  # 
  # Au premier tour, si elle n'est pas définie, on indique qu'il
  # faudra recommencer un tour.
  # 
  # @param ref_id [String] 
  # 
  #   L'ID de la référence. En cas de référence à un autre livre, 
  #   on a "IDBOOK:ref_id"
  # 
  # @param paragraph [NTextParagraph] 
  # 
  #   Instance du paragraphe contetant l'appel.
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
      # - Référence non définie -
      # On passe ici quand la référence cible n'est pas encore défi-
      # ni (parce qu'elle se trouve plus loin, peut-être même dans le
      # paragraphe suivant). Dans ce cas, on prend un "ticket de
      # poissonnerie" en attendant dans la référence, qu'on remplace-
      # ra au second tour.
      ticket_boucherie = "->_REF_#{@wanted_references.count.to_s.rjust(3,'0')}" 
      @wanted_references.merge!(ticket_boucherie => ref_id )
      paragraph.has_unknown_target(ticket_boucherie, ref_id)
      return ticket_boucherie # -- pour le remplacer au second tour
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
    case book.recipe.page_num_type
    when 'pages'
      "#{ref[:page]}"
    when 'parags'
      ref[:paragraph] ? "§ #{ref[:paragraph]}" : "#{ref[:page]}"
    when 'hybrid'
      ref[:hybrid] # "p. XXX § XX"
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
  def appels_sans_reference?
    @wanted_references.any?
  end


  # --- Path Methods ---

  def path
    @path ||= File.join(book.folder,'references.yaml')
  end

end #/class ReferencesTable
end #/class PdfBook
end #/module Prawn4book
