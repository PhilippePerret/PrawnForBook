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
    real_path =
      case path
      when Prawn4book::PrawnView  then path.book.folder
      when Prawn4book::PdfBook    then path.folder
      when String                 then path
      else raise "Je ne sais pas comment transformer #{path.inspect}::#{path.class} en path:String…"
      end
    @folder = real_path
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

  #
  # @return [Prawn4book::PdfBook|Prawn4book::Collection] La chose concernée.
  # @note
  #   On peut aussi utiliser l'alias #owner
  # 
  def thing
    @thing ||= begin
      if File.exist?(book_recipe_path)
        PdfBook.current || PdfBook.new(folder)
      elsif File.exist?(collection_recipe_path)
        Collection.new(folder)
      else
        # Si aucun fichier recette n'est défini, on considère que
        # c'est d'un livre dont il s'agit.
        PdfBook.new(folder)
      end
    end
  end
  alias :owner :thing

  def recipe
    @recipe ||= owner.recipe # collection ou livre
  end

end #/class SpecialPage
end #/module Prawn4book
