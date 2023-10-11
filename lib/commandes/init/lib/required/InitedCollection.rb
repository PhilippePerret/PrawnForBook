require_relative 'InitedThing'

module Prawn4book
class InitedCollection < InitedThing
  def thing; "collection" end
  def the_thing; "la collection" end
  def a_thing; "une collection" end
  def of_the_thing;"de la collection" end
  def collection?; true end
  def book?; false end
  def in_collection?; false end
  
  def recipe_name
    @recipe_name ||= 'recipe_collection.yaml' 
  end
end #/class Inited Collection
end #/module Prawn4book
