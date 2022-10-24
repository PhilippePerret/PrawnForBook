module Prawn4book
class InitedThing

  # Création de la recette (livre ou collection)
  # 
  # @return true en cas de succès, false otherwise
  # 
  def proceed_build_recipe

    # TODO: étudier le cas où le livre est dans le dossier
    # d'une collection
    if book? && in_collection?
      puts "Je dois apprendre à demander quoi faire quand book in collection.".jaune
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

    # Copie du code propre au livre ou à la collection 
    fsource = File.join(Prawn4book::templates_folder, recipe_name)
    FileUtils.cp(fsource, recipe_path)
    # Ajout du code commun
    fcommun = File.join(Prawn4book::templates_folder,'recipe_communs.yaml')
    File.open(recipe_path,'a') { |f| f.puts File.read(fcommun) }

    #
    # Confirmation création
    # 
    return confirm_create_recipe
  end

  def keep_recipe_file_if_exist?
    return nil unless File.exist?(recipe_path)
    ask_what_to_do_with_file(recipe_path, 'fichier recette')
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
