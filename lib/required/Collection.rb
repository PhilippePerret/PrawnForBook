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
        # 
        # L'argument est l'instance du document PdfBook
        # Attention : ne pas utiliser arg.collection qui retourne
        # l'instance Prawn4book::Collection du livre (=> infinite loop)
        # 
        if arg.recette[:collection] === true
          # 
          # La donnée du PdfBook est TRUE, ce qui signifie que le
          # livre se trouve dans le dossier de la collection, au même
          # niveau que la recette de la collection.
          # 
          File.dirname(arg.folder)
        else
          # 
          # La donnée :collection du PdfBook est le chemin d'accès au
          # dossier de la collection
          # 
          arg.recette[:collection]
        end
      else
        # 
        # L'argument est le path au dossier de la collection
        # 
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

  def name            ; data[:name]             end

  def data
    @data ||= YAML.load_file(recipe_path, aliases: true)
  end

  # --- Path Methods ---

  def recipe_name ; 'recipe_collection.yaml' end

end #/class Collection
end #/module Prawn4book
