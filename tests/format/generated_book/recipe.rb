module GeneratedBook
class Book
class Recipe
attr_reader :book
def initialize(book)
  @book = book
  @data = get_recipe_data
end


##
# = main =
# 
# Construit la recette du livre avec les propriétés +props+ en
# respectant les options +options+
# 
# @note
#   [1] +prop+ peut être une tale de premier niveau seulement, pour
#       faciliter les modifications. Les propriétés seront ensuite
#       bien rangées à leur place avant l'enregistrement. Par ex.,
#       le leading peut être défini avec props = {leading: 4} mais
#       ensuite on le mettra à sa place dans book_format:text:leading
# 
# @param [Hash] props Table des propriétés à mettre dans la recette du livre avant de le construire.
# @param [Hash] options
# @option options [Boolean] keep Si true, on garde les données actuelles et on leur ajoute simplement les nouvelles.
def build_with(props, **options)
  # 
  # On met les options par défaut
  # 
  options = defaultize_options(options)
  # 
  # On range correctement les propriétés (voir [1])
  # 
  props = realize_properties(props)
  # puts "props = #{props.inspect}"
  # 
  # On peut enregistrer les propriétés
  # 
  if options[:keep]
    @data.merge!(props)
  else
    @data = props
  end
  save
end

def path
  @path ||= File.join(book.folder,'recipe.yaml')
end

private

  ##
  # Enregistrement des données dans le fichier recette
  # @api
  def save
    @data.merge!(last_updated: Time.now.jj_mm_aaaa)
    File.write(path, @data.to_yaml)
  end

  REAL_PATH_DATA = {
    leading:      [:book_format, :text],
    line_height:  [:book_format, :text],
  }
  # @api private
  def realize_properties(props)
    real_props = {}
    props.each do |key, value|
      dpath = REAL_PATH_DATA[key] || []
      la = real_props
      dpath.each do |sk|
        la.merge!(sk => {}) unless la.key?(sk)
        la = la[sk]
      end
      la.merge!(key => value)
    end

    return real_props
  end

  # @api private
  def defaultize_options(opts)
    opts ||= {}
  end

  # @api private
  def get_recipe_data
    if File.exist?(path)
      YAML.load_file(path, **{aliases:true, symbolize_name:true})
    else
      {}
    end
  end

end #/class Recipe
end #/class Book
end #module GeneratedBook
