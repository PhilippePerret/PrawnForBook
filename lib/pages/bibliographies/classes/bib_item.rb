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

  ##
  # @return [String] Chemin d'accès à la fiche de l'item
  # 
  def path
    @path ||= File.join(biblio.folder, "#{id}.#{biblio.item_data_format}")
  end

end #/class BibItem
end #/class Bibliography
end #/module Prawn4book
