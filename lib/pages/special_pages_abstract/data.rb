=begin
  
  Méthodes communes pour la gestion des données de la page et
  notamment :
  - les données par défaut
  - les données dans le fichier recette du livre courant

=end
module Prawn4book
class SpecialPage

  # Pour le :values d'une donnée true/false
  def yes_no_answers
    [
      {name: 'Oui', value: 'true'},
      {name: 'Non', value: 'false'}
    ]
  end

  # Pour la :values d'une donnée de type select
  def police_names(default_name = nil)
    (get_data_in_recipe[:fonts]||polices_default).map do |font_name, dfont|
      {name: font_name, value: font_name}
    end
  end
  def polices_default
    {'Times' => true, 'Helvetica' => true, 'Courier' => true}
  end


  # @return [Any] Valeur pour la clé +simple_key+ défini dans le
  # fichier recette ou par défaut dans les données PAGE_DATA
  # 
  # @note
  #   Alias très partique : v
  #   Méthode utilisée particulièrement par le builder pour 
  #   construire la page. Elle renvoie donc toujours une valeur.
  # 
  # @param [String] simple_key Clé "simple", c'est-à-dire une clé
  #   de premier niveau (mise à plat de la table des données dans la
  #   recette). Par exemple, si la recette définit data[:sub_title][:size]
  #   alors la clé simple sera "sub_title-size"
  # 
  def get_value(simple_key)
    get_current_value_for(simple_key) || default_value_for(simple_key)
  end
  alias :v :get_value

  # @return [Any] value pour +simple_key+ ou nil si aucune
  # 
  # @param [String] simple_key La clé de l'élément ramenée au premier
  #                 degré, pour gérer la hiérarchie. Par exemple, si,
  #   dans la donnée YAML, l'élément se trouve à [:sub_title][:size]
  #   alors la clé simple sera 'sub_title-size'
  # 
  def get_current_value_for(simple_key)
    dkey = simple_key.split('-').map {|n| n.to_sym}
    cval = recipe_data
    while key = dkey.shift
      cval = cval[key] || return # non définie
    end
    return cval
  end

  # @return [Any] value pour +simple_key+ ou nil si aucune
  # 
  # @param [String] simple_key La clé de l'élément ramenée au premier
  #                 degré, pour gérer la hiérarchie. Par exemple, si,
  #   dans la donnée YAML, l'élément se trouve à [:sub_title][:size]
  #   alors la clé simple sera 'sub_title-size'
  # 
  def default_value_for(simple_key)
    dkey = simple_key.split('-').map {|n| n.to_sym}
    cval = klasse::PAGE_DATA
    while key = dkey.shift
      cval = cval[key]
      # puts "cval = #{cval.inspect} (simple key #{simple_key})"
    end
    cval || begin
      puts "La valeur par défaut pour #{simple_key.inspect} n'est pas définie…".rouge
      return nil
    end
    cval[:default]
  end

  def set_current_value_for(simple_key, value)
    dkey = simple_key.split('-').map {|n| n.to_sym}
    cprop = recipe_data
    while key = dkey.shift
      cprop.key?(key) || cprop.merge!(key => {})
      if dkey.empty?
        cprop[key] = value
      else
        cprop = cprop[key]
      end
    end
    # puts "Nouvelle recette : #{recipe_data.inspect}"
  end

  # En fin de définition, on peut sauver la recette
  def save_recipe_data
    set_data_in_recipe(recipe_data)
    puts "Données recette pour #{page_name.downcase} enregistrées avec succès.".vert
  end

  # @return [String] The tag name for comments in the recipe
  # yaml file.
  # @example
  #    For class PageDeTitre # => 'page_de_titre'
  def tag_name
    @tag_name ||= self.class.name.to_s.split('::').last.decamelize
  end

  def book?
    :TRUE == @isbook ||= true_or_false(thing.instance_of?(Prawn4book::PdfBook))
  end


  # @return [Hash] Les données recette POUR CETTE PAGE
  def recipe_data
    @recipe_data ||= get_data_in_recipe[tag_name.to_sym] || {}
  end

  # @return [Hash] Les données de la page dans le fichier de
  # données ou une table vide en cas d'absence de données
  def get_data_in_recipe
    if File.exist?(recipe_path)
      YAML.load_file(recipe_path, aliases: true, symbolize_names: true)
    else
      {}
    end
  end

  ##
  # Définit les données dans le fichier de données
  # 
  # @note
  #   On fonctionne toujours par balise pour pouvoir garder les 
  #   commentaires du fichier
  # 
  def set_data_in_recipe(new_data)
    owner.recipe.insert_bloc_data(tag_name, new_data)
  end
  
  # @return [String] Le fichier recette en fonction du fait qu'on
  # gère un livre ou une collection
  def recipe_path
    @recipe_path ||= send(:"#{book? ? 'book' : 'collection'}_recipe_path")
  end

  # @return [String] Le fichier recette du livre courant
  # 
  def book_recipe_path
    @recipe_path ||= File.join(folder, 'recipe.yaml')
  end

  # @return [String] Le fichier recette de la collection 
  # courante (if any)
  def collection_recipe_path
    @collection_recipe_path ||= File.join(folder, 'recipe_collection.yaml')
  end

end #/class SpecialPage
end #/module Prawn4book
