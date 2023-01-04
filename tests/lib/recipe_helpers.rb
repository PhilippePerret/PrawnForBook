module Minitest
class Test

  class InitRecipe
    attr_reader :recipe_path
    attr_reader :tosa
    # 
    # @param [String] path Chemin d'accès au fichier recette
    # @param [OSATest] tosa l'instance pour gérer l'interactivité (la simulation)
    def initialize(path, tosa)
      @recipe_path = path
      @tosa = tosa
    end

    def goto(what)
      tosa.fast [index_of_key(what).down, :RET]
    end

    def index_of_key(key)
      @value_to_index ||= begin
        require 'lib/commandes/init/lib/required/data_recipe.rb'
        Prawn4book::DATA2DEFINE_VALUE_TO_INDEX
      end
      return @value_to_index[key] + 1
    end
    
    ##
    # Pour choisir une fonte dans celles définies
    # @example
    #   InitRecipe.new(recipe_path).choose_font(tosa, "Geneva")
    # @note
    #   On doit être déjà dans la définition de la fonte
    def choose_font(font_name)
      font_name = font_name.to_sym # elles sont symbolisées
      index_font = (load_recipe[:fonts].keys + DEFAULT_FONTS_KEYS).index(font_name)
      index_font || raise("La police #{font_name.inspect} est inconnue.")
      if index_font > 0
        tosa.fast index_font.down
      end
      tosa << :RET
    end


    def load_recipe
      YAML.load_file(recipe_path, symbolize_names: true)
    end
  end

end #/class Test
end #/module Minitest
