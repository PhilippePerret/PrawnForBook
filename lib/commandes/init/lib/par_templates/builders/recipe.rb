module Prawn4book
class InitedThing

  # Création de la recette (livre ou collection)
  # 
  # @return true en cas de succès, false otherwise
  # 
  def proceed_build_recipe

    if book? && in_collection?
      puts "
      Ce livre est dans une collection. Je ne dois mettre dans sa 
      recette que les propriétés propre à un livre.
      ".jaune
    end

    #
    # Que faut-il faire si un fichier recette existe déjà ?
    # 
    case keep_recipe_file_if_exist?
    when :keep    then return true
    when :cancel  then return false
    else
      # on continue
    end

    #
    # Assembler le fichier recette 
    #
    assemble_recipe

    #
    # Confirmation création
    # 
    return confirm_create_recipe
  end

  ##
  # Méthode qui construit le fichier recette
  # 
  def assemble_recipe
    # Copie du code propre au livre ou à la collection 
    fsource = template_for(recipe_name)
    FileUtils.cp(fsource, recipe_path)
    # Ajout du code commun (sauf si c'est un livre dans un collection)
    unless in_collection?
      fcommun = template_for('recipe_communs.yaml')
      File.open(recipe_path,'a') { |f| f.puts File.read(fcommun) }
    end
  end

  def keep_recipe_file_if_exist?
    return nil unless File.exist?(recipe_path)
    File.ask_what_to_do_with_file(recipe_path, 'fichier recette')
  end

  def confirm_create_recipe
    if File.exist?(recipe_path)
      puts "Fichier recette créé avec succès.".vert
      return true
    else
      puts "Fichier recette introuvable, bizarrement…".rouge
      return false
    end
  end

  def recipe_path
    @recipe_path ||= File.join(folder,recipe_name)  
  end
end #/class InitedThing
end #/module Prawn4book
