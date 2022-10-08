module Prawn4book
class Collection

  attr_reader :folder

  def initialize(cfolder)
    @folder = cfolder
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
