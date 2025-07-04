module Prawn4book
class Collection

  attr_reader :folder

  def initialize(arg)
    define_folder_from_arg(arg)
  end

  def is_collection?
    true
  end

  ##
  # Définit le dossier de la collection en fonction de
  # l'argument transmis en argument à l'instantiation
  # 
  def define_folder_from_arg(arg)
    @folder = 
      case arg
      when Prawn4book::PdfBook
        # L'argument de l'instanciation est un livre de la collection
        File.dirname(arg.folder)
      else
        # L'argument est le path au dossier de la collection
        arg
      end
  end

  ##
  # Sauver la recette de la collection
  # 
  def save
    File.write(recipe_path, data.to_yaml)
  end


  # --- Data Methods ---
  # 

  def collection_data
    @collection_data ||= begin
      data.key?(:collection_data) || raise(RecipeError.new("Il faut définir la clé :collection_data dans le fichier recette (de la collection, avec les données de la collection."))
      data[:collection_data].is_a?(Hash) || raise(RecipeError.new("Les données de la collection (:collection_data), dans le fichier recette de la collection, devraient être une table (dictionnaire)."))
      data[:collection_data]
    end
  end

  def name 
    collection_data[:name] || raise(RecipeError.new("Les données de la collection (:collection_data) doivent impérativement définir le nom (:name) de la collection."))
  end

  def data
    @data ||= YAML.load_file(recipe_path, **{aliases: true, symbolize_names:true})
  end

  # --- Path Methods ---

  def recipe_name ; 'recipe_collection.yaml' end

end #/class Collection
end #/module Prawn4book
