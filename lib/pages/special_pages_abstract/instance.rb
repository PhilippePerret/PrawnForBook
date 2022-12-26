=begin
  
  Méthodes communes pour la construction

=end
module Prawn4book; class PrawnView; end; end
module Prawn4book
class Pages

  #
  # Pour lancer un assistant avec :
  #   Prawn4book::Pages.run_assistant('page-de-titre')
  # 
  def self.run_assistant(which)
    classe = self.const_get(which.gsub(/\-/,'_').camelize)
    page = classe.new(File.expand_path('.'))
    page.define
  end
  
end #/ class Pages
class SpecialPage

  # [String] Le dossier dans lequel on se trouve.
  attr_reader :folder

  ##
  # Instanciate l'assistant
  # 
  # @param [String|Prawn4book::PrawnView] path Dossier courant (où a été lancé la commande) ou le PrawnView du document traité
  #      
  def initialize(path)
    path = path.pdfbook.folder if path.instance_of?(Prawn4book::PrawnView)
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
