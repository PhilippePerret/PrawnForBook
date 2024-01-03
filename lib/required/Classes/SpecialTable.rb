#
# ATTENTION
# =========
# Cette classe ne doit pas être confondue avec l’ancienne classe
# abstraite SpecialPage qui s’occupe encore des pages spéciales (mais
# de moins en moins).
# 
module Prawn4book
class PdfBook
class SpecialTable

  attr_reader :book
  attr_reader :pdf
  attr_reader :table_id # le type de table (table_of_content, illustrations, etc.)

  # Les propriétés à ne pas ré-initialiser avec #reset
  PROTECTED_PROPERTIES = []

  def initialize(book)
    @book     = book
    @table_id = (self.class.name.dup).split('::').last.decamelize.to_sym
    PROTECTED_PROPERTIES << :@book
    PROTECTED_PROPERTIES << :@table_id
    PROTECTED_PROPERTIES << :@pdf

  end

  def print(pdf, premier_tour = true)
    # Exposition
    @pdf = pdf

    # Réinitialisation de toutes les variables, sauf les variables
    # protégées
    reset

  end

  def reset
    self.instance_variables.each do |varname|
      next if PROTECTED_PROPERTIES.include?(varname)
      self.instance_variable_set("#{varname}", nil)
    end
  end

  # Return true si on doit afficher le glossaire
  def required?
    not(@is_not_required)
  end

  def title
    @title ||= recipe[:title] || TERMS["table_#{table_id}".to_sym]
  end

  def title_level
    @title_level ||= recipe[:title_level] || 2
  end

  def fonte
    @fonte ||= Fonte.get_in(recipe).or_default
  end


  # Données de la recette pour cette table
  # @requis
  #   @table_id doit être défini, qui contient le nom de la
  #   propriété dans les données recettes (nom de la méthode)
  # 
  def recipe
    @recipe ||= begin
      r = book.recipe.send(@table_id)
      @is_not_required = r === false
      r = {} if r === false
      r
    end
  end



end #/class SpecialTable
end #/class PdfBook
end #/module Prawn4book
