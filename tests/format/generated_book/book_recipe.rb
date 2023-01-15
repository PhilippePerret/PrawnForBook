require_relative 'abstract_recipe'
module GeneratedBook
class Book
class Recipe < AbstractRecipe


attr_reader :book
def initialize(book)
  super
  @book = book
end

def recipe_name; 'recipe.yaml' end

end #/class Recipe
end #/class Book
end #module GeneratedBook
