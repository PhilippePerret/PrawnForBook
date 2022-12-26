=begin
  
  Méthodes communes pour la construction

=end
module Prawn4book
class SpecialPage

  # [String] Le dossier dans lequel on se trouve.
  attr_reader :folder

  ##
  # Instanciate la page
  # 
  # @param [String] path Dossier courant (où a été lancé la commande)
  # 
  def initialize(path)
    @folder = path
    @thing  = thing  
  end

  # @return [Prawn4book::Pages::<Any>] La classe fille
  # @example
  #   Prawn4book::Pages::PageDeTitre
  def klasse
    @klasse || self.class
  end

  # @return [String] Le nom de la page concernée, tirée de sa classe
  def page_name
    @page_name ||= klasse.to_s.split('::').last.decamelize.titleize.gsub(/_/,' ')
  end


  def thing
    @thing ||= begin
      if File.exist?(book_recipe_path)
        Prawn4book::PdfBook.new(folder)
      elsif File.exist?(collection_recipe_path)
        Prawn4book::Collection.new(folder)
      else
        puts ERRORS[:require_a_book_or_collection].rouge
        exit
      end
    end
  end

end #/class SpecialPage
end #/module Prawn4book
