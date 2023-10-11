require_relative 'InitedThing'

module Prawn4book
class InitedBook < InitedThing
  def thing; "book" end
  def the_thing;"le livre" end
  def a_thing;"un livre" end
  def of_the_thing;"du livre" end
  def collection?; false end
  def book?; true end

  # @return true si le livre est dans une collection
  def in_collection?
    File.exist?(File.join(File.dirname(folder),'recipe_collection.yaml'))
  end

  # @return le path à un fichier de la collection (si le livre
  # appartient à une collection)
  def collection_file(filename)
    in_collection? && File.join(folder_collection, filename)
  end
  
  # @prop Dossier de la collection (si le livre appartient à une
  # collection)
  def folder_collection
    @folder_collection ||= begin
      in_collection? && File.dirname(folder)
    end
  end
  def recipe_name
    @recipe_name ||= 'recipe.yaml' 
  end
end #/class InitedBook
end #/module Prawn4book
