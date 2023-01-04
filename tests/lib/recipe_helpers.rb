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
      case what
      when :titres
        tosa.fast [*3.down, :RET]
      when :inserted_pages
        tosa.fast [*4.down, :RET]
      when :publisher
        tosa.fast [*5.down, :RET]
      when :infos
        tosa.fast [*6.down, :RET]
      end
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
