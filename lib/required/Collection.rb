module Prawn4book
class Collection

  attr_reader :folder

  def initialize(arg)
    define_folder_from_arg(arg)
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
        if arg.data[:collection] === true
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
          arg.data[:collection]
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
  def book_dimensions ; data[:book_dimensions]  end
  def num_page_style  ; data[:num_page_style]   end
  def book_marges     ; data[:book_marges]      end
  def interligne      ; data[:interligne]       end
  def opt_num_parag   ; data[:opt_num_parag]    end
  def fonts           ; data[:fonts]            end
    

  def data
    @data ||= YAML.load_file(recipe_path, aliases: true)
  end

  # --- Path Methods ---

  def recipe_path
    @recipe_path ||= File.join(folder, 'recipe_collection.yaml')
  end

end #/class Collection
end #/module Prawn4book
