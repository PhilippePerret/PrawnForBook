=begin
  
  Méthodes communes pour la gestion des données de la page et
  notamment :
  - les données par défaut
  - les données dans le fichier recette du livre courant

=end
module Prawn4book
class SpecialPage


  # @return [Any] Valeur pour la clé +simple_key+ défini dans le
  # fichier recette ou par défaut dans les données PAGE_DATA
  # 
  # @note
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
    cval = DATA_PAGE
    while key = dkey.shift
      cval = cval[key]
    end
    return cval
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
    code     = raw_code
    new_data = {tag_name.to_sym => new_data}
    inserted = new_data.to_yaml
    inserted = inserted[4..-1].strip if inserted.start_with?("---")
    tag_in  = "#<#{tag_name}>"
    tag_out = "#</#{tag_name}>"
    dec_in  = code.index(tag_in)
    dec_out = code.index(tag_out)
    if dec_in.nil?
      # 
      # Dans le cas d'une balise introuvable, on met le code à la 
      # fin, en ajoutant la balise. On vérifie quand même qu'aucune
      # balise de fin
      # 
      code = [code, tag_in, inserted.strip, tag_out].join("\n")
      dec_out.nil? || begin
        puts <<~TXT.orange
          Attention, une balise de fin (#{tag_out}) existe dans le fichier
          recette (sans balise de début). Il faudrait la supprimer pour
          ne pas avoir de problème.
        TXT
        sleep 4
      end
    else
      # 
      # Quand la balise d'ouverture a été trouvée
      # 
      dec_in += tag_in.length
      # 
      # Note : si on a trouvé la balise d'ouverture, il faut impérativement
      # trouver la balise de fermeture
      # 
      dec_out || raise("La balise '</#{tag_name}>' est introuvable.")
      dec_out > dec_in || begin
        dec_out = code.index(tag_out, dec_in)
        if dec_out.nil?
          raise("Une balise '</#{tag_name}>' a été trouvée, mais avant la balise de début…")
        else
          puts <<~TXT.orange
            Attention : une balise de fin a été trouvée avant la balise
            de début. Il faudrait la supprimer.
            (je poursuis quand même en tenant compte de la deuxième)
          TXT
          sleep 4
        end
      end
      dec_out -= 1
      code = [code[0..dec_in].strip, inserted.strip, code[dec_out..-1].strip].join("\n")
    end
    File.write(recipe_path, code)
  end



  def raw_code
    File.exist?(recipe_path) ? File.read(recipe_path) : "---\n"
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
