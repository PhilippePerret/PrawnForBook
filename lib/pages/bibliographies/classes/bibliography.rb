module Prawn4book
class Bibliography
###################       CLASSE      ###################
  
class << self
  # @prop Table des bibliographies
  attr_reader :items

  # @prop {Symbol} :page ou :paragraph en fonction du type de
  # pagination du livre.
  attr_accessor :page_or_paragraph_key

  ##
  # Appelé en bas de ce fichier
  # 
  def init
    @items = {}
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
###################       INSTANCE      ###################


  attr_reader :pdfbook 
  alias :book :pdfbook
  attr_reader :id

  ##
  # Instanciation d'une bibliographie
  # 
  # @param [Prawn4book::PDFBook] pdfbook Le livre en train d'être traité.
  # @param [String] biblio_id Identifiant singulier de la bibliographie, par exemple 'livre' ou 'film'.
  # 
  def initialize(pdfbook, biblio_id)
    @pdfbook  = @book = pdfbook
    @id       = biblio_id
  end

end

##
# Au chargement du module, on initialise la classe
# 
Bibliography.init

end #/module Prawn4book
