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
  #               tant l'appel. En cas de référence croisée, cette
  #               instance permet d'ajouter un élément bibliographi-
  #               que aux livres.
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

  def call_to(ref, cross_book_title = nil)
    ref = pdfbook.page_number? ? ref[:page] : ref[:paragraph]
    ref = pdfbook.page_number? ? "page #{ref}" : "paragraphe #{ref}"
    ref = "#{ref} de <i>#{cross_book_title.upcase}</i>" if cross_book_title
    # TODO : AJOUTER À LA LISTE DES LIVRES (BIBLIOGRAPHIE)
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
  # @param paragraph {NTextParagraph} Cf. l'explication dans #get
  # 
  # @return {String} Le texte à écrire dans la page.
  # 
  def get_cross_reference(ref_id, paragraph)
    book_id, ref_id = ref_id.split(':')
    ref_id  = ref_id.to_sym
    book_id = book_id.to_sym
    @cross_references[book_id] || begin
      get_book_id_cross_reference(book_id) || return
    end
    # 
    # Soit la références existe et on la prend simplement,
    # soit on signale une erreur
    # 
    dcross_book = @cross_references[book_id]
    dcross_book[:references][ref_id] || begin
      puts (ERRORS[:references][:cross_ref_undefined] % [ref_id, book_id]).rouge
      exit 0
    end
    # 
    # Tout est OK, on ajoute un élément bibliographique
    # 
    Bibliography.add_occurrence_book(book_id, paragraph)

    return call_to(dcross_book[:references][ref_id], dcross_book[:title])
  end


  ##
  # Vérification de la définition du book_id +book_id+ pour une
  # cross-référence
  # 
  # Met dans la table @cross_references les données du livre, mais
  # seulement après procédé à une vérification en règle de l'exis-
  # tence des données du livre.
  # 
  # @return true si le livre existe bien et qu'il contient un fichier
  # de référence
  def get_book_id_cross_reference(book_id)
    # 
    # La bibliographye pour les livres doit être définie pour ce 
    # livre ou cette collection.
    # 
    unless Bibliography::Livres.exist?
      raise ERRORS[:references][:bib_livre_not_defined]
    end
    # 
    # Le livre doit être défini dans la bibliographie du livre 
    # courant
    # 
    bib_book_item = Bibliography::Livres.get(book_id)
    if bib_book_item.nil?
      raise ERRORS[:references][:book_undefined_in_bib_livre] % [book_id]
    end
    # 
    # Les données du livre doivent être définies de telle sorte 
    # qu'on puisse avoir ses références
    # 
    bib_book_item.valid_for_cross_references? || return
    # 
    # Le livre et le fichier des références existent, on peut les
    # charger
    # 
    dcross_book = {
      id: book_id,
      title: bib_book_item[:title],
      references: YAML.load_file(book_data_ref, aliases: true)
    }
    # 
    # Les données du livre sont définies, on peut les enregistrer 
    # dans la table des cross-références
    # 
    @cross_references.merge!(book_id => dcross_book)

    # Les données du livre définies dans le fichier recette
    dcross_book_path = data[:cross_references][book_id]
    if dcross_book_path.nil?
      raise ERRORS[:references][:cross_path_undefined] % [book_id]
    end
    dcross_book_path = File.expand_path(dcross_book_path)
    unless File.exist?(dcross_book_path)
      raise ERRORS[:references][:cross_book_unfound] % [book_id, dcross_book_path]
    end
    book_data_ref = File.join(dcross_book_path,'references.yaml')
    unless File.exist?(book_data_ref)
      raise ERRORS[:references][:cross_book_data_unfound] % [File.basename(dcross_book_path), book_id]
    end

  rescue Exception => e
    err_msg = "\n#{e.message}\nJe ne peux pas retourner la référence croisée."
    spy "ERREUR FATALE : #{err_msg}".rouge
    erreur_fatale err_msg
  else
    return true
  end

  # --- Path Methods ---

  def path
    @path ||= File.join(pdfbook.folder,'references.yaml')
  end

end #/class ReferencesTable
end #/class PdfBook
end #/module Prawn4book
