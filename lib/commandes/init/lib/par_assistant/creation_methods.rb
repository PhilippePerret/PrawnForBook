module Prawn4book
class PdfBook

  # --- CLASSE ---

  class << self
  end #/class << self


  # --- INSTANCE ---

  def create_recipe(data)

    # puts "data = #{data.pretty_inspect}"

    # 
    # Création du dossier
    # 
    @folder = File.join(data[:main_folder])
    mkdir(@folder)
    
    # 
    # Création du fichier recette
    # 
    @recipe_path = File.join(folder, 'recipe.yaml')
    File.write(recipe_path, data.to_yaml)

    #
    # On dépose le texte dans le dossier si nécessaire
    # 
    unless data[:text_path] === true
      FileUtils.cp(data[:text_path], text_path)
    end

    puts "Dossier du livre créé avec succès.".vert
  end


end #/class PdfBook
end #/module Prawn4book
