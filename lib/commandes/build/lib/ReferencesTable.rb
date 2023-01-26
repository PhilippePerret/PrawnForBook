module Prawn4book
class PdfBook
class ReferencesTable

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
  # Ajout d'une référence rencontrée
  # 
  # @param ref_id {String} IDentifiant de la référence
  # @param ref_data {Hash} Données de la référence, contient
  #         {:page, :paragraph}
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
      {page:"xx", paragraph:'xxx'}
    end
    call_to(ref)
  end


  ##
  # Enregistrement des la liste des références
  # 
  # Rappel : cette table enregistrée ne sert que pour les références
  # croisées. Pour un livre, elles sont recalculées chaque fois.
  def save
    File.write(path, table.to_yaml)
  end

  # --- Helpers Methods ---

  # @return [String] la texte qui doit remplacer la balise target 
  # dans le texte
  # @note
  #   Les références croisées utilisent une autre méthode.
  def call_to(ref)
    ref = pdfbook.page_number? ? "page #{ref[:page]}" : (ref[:paragraph] ? "paragraphe #{ref[:paragraph]}" : "page #{ref[:page]}")
    return ref
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

  # --- CROSS-REFERENCES TREATMENT ---

  ##
  # Retourne la référence à un autre livre
  # Dans ce cas, +ref_id+ contient "<book id>:<ref id>"
  # 
  # @param ref_id {Symbol} Cf. l'explication dans #get
  # 
  # @return {String} Le texte à écrire dans la page.
  # 
  def get_cross_reference(ref_id, paragraph)
    book_id, ref_id = ref_id.split(':')
    extbook = Bibliography::Livres.get(book_id)
    # 
    # Tout est OK, on ajoute un élément bibliographique
    # 
    Bibliography.add_occurrence_book(extbook, paragraph)
    # 
    # On retourne le texte à placer dans le texte
    # 
    return extbook.reference_to(ref_id, pdfbook)
  end

  # --- Path Methods ---

  def path
    @path ||= File.join(pdfbook.folder,'references.yaml')
  end

end #/class ReferencesTable
end #/class PdfBook
end #/module Prawn4book
