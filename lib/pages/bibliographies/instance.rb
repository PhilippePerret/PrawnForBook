module Prawn4book
class Pages
class Bibliography

  # [Prawn4book::Bibliography]
  attr_reader :biblio

  # [Prawn4book::PdfBook]
  attr_reader :book

  # Instanciation spéciale de la bibliographie, pour disposer de
  # l'instance Prawn4Book::Bibliography
  # 
  def initialize(book, biblio)
    super(book)
    @book   = book
    @biblio = biblio
  end

  # - Predicate Methods -

  # @return true s'il n'y a pas d'item
  def empty?
    biblio.items.empty?
  end

  # @return [Symbol] La méthode de formatage propre à cette
  # bibliographie.
  def formate_method
    @format_method ||= begin
      meth = "biblio_#{biblio.tag}".to_sym
      if Prawn4book::Bibliography.respond_to?(meth)
        meth
      else
        :default_formate_method
      end
    end
  end


  def font_name
    @font_name ||= begin
      if recipe_data[:font] then
        recipe_data[:font]
      else
        'Times-Roman'
      end
    end
  end

  def font_size
    @font_size ||= begin
      if recipe_data[:size] then
        recipe_data[:size]
      else
        10
      end
    end
  end

  def font_style
    @font_style ||= begin
      if recipe_data[:style] then
        recipe_data[:style]
      end
    end
  end

  # @return [Hash] Table des données recette pour la bibliographie
  # courante
  def recipe_data
    @recipe_data ||= book.recipe.bibliographies[:biblios][biblio.id.to_sym]
  end
  
end #/class Bibliography
end #/class Pages
end #/module Prawn4book
