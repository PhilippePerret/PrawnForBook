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

  # Méthode publique permettant de choisir ou de créer une nouvelle
  # bibliographie.
  # 
  # @return [Prawn4book::Bibliography] L'instance bibliographie
  # créée.
  # 
  # @api public
  # 
  def choose_or_create(book)
    fprec = File.join(BIB_TMP_FOLDER,'choose_biblio')
    choix = precedencize(choices_biblios(book), fprec) do |q|
      q.question (PROMPTS[:choose_la] % TERMS[:bibliography]).jaune
      q.add_choice_cancel
    end
    case choix
    when NilClass         then return nil # arrêter
    when 'create_biblio'  then assiste_creation(book) # return bibliographie
    else new(book, choix)
    end
  end
  def choices_biblios(book)
    idlivres = book.recipe.biblio_book_identifiant.to_s
    [
      {name:(PROMPTS[:biblio][:biblio_name] % "#{idlivres.titleize}s"), value: idlivres}
    ] + data_biblios(book).map do |btag, bdata|
      {name: "#{bdata[:title]}", value: btag.to_s}
    end + [
      {name: (PROMPTS[:creer_une] % TERMS[:bibliography]).bleu, value: 'create_biblio'},
    ]
  end

  ##
  # Retourne les données bibliographies (:biblios) telles que définies
  # dans la recette du livre ou de la collection.
  # 
  def data_biblios(book = nil)
    @data_biblios = nil unless book.nil?
    @data_biblios ||= book.recipe.bibliographies[:biblios] || {}  
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
    add_occurrence_to(book.recipe.biblio_book_identifiant.to_s, book, {page: paragraph.first_page, paragraph: paragraph.numero})
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
end #/ class Bibliography

##
# Au chargement du module, on initialise la classe
# 
Bibliography.init

end #/module Prawn4book