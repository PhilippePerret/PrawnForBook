=begin
  
  class HeadersFooters::Disposition::BookPage

  Gestion des données de pages pour les headers et footers

=end
module Prawn4book
class HeadersFooters
class BookPage

  attr_reader :data

  ##
  # Instanciation
  # 
  # @param [Hash] data Données de la page
  # @option data [Integer] :numero Numéro de la page (1-based)
  # @option data [String|Nil] :title1   Nouveau grand titre
  # @option data [String|Nil] :current_title1 Grand titre courant (commencé sur une page précédente)
  # @option data [String|Nil] :title2   Nouveau titre de niveau 2 inauguré sur la page
  # @option data [String|Nil] :current_title2 Titre de niveau 2 courant (inauguré sur une page précédente)
  # @option data [String|Nil] :title3   Nouveau titre de niveau 3 inauguré sur la page
  # @option data [String|Nil] :current_title3 Titre de niveau 3 courant (inauguré sur une page précédente)
  # @option data [Integer|Nil] :first_par Indice du premier paragraphe de la page (if any)
  # @option data [Integer|Nil] :last_par Indice du dernier paragraphe de la page (if any)
  def initialize(data)
    @data = data
  end

end #/class BookPage
end #/class HeadersFooters
end #/module Prawn4book
