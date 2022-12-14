module Prawn4book

# @prop Dossier contenant tous les templates
def self.templates_folder
  @templates_folder ||= File.join(APP_FOLDER,'resources','templates')
end

# Class InitedThing
# -----------------
# Classe abstraite pour la chose à initier, livre ou collection
# 
class InitedThing
  attr_reader :owner
  def initialize(owner, folder_path = nil)
    @folder = folder_path
    @owner  = owner
  end
  def folder
    @folder ||= PdfBook.cfolder
  end
  ##
  # = main =
  # 
  # Main méthode qui initie la chose
  # 
  def init
    # 
    # Fabrication de la recette
    # 
    require_relative 'builders/recipe'
    build_recipe || return
    # 
    # Fabrication des fichiers de base
    # 
    build_base_files    || return
    confirmation_finale || return
  end

  def build_base_files
    BuilderFile.new(self).build('parser.rb')
    BuilderFile.new(self).build('formater.rb')
    BuilderFile.new(self).build('helpers.rb')
    BuilderFile.new(self).build('texte.pfb.md') if book?
  end

  def confirmation_finale
    puts "
    À présent, vous pouvez jouer ces commandes :
    
    #{'pfb open -e'.jaune}
        pour ouvrir le dossier dans l'éditeur et modifier la
        recette, les méthodes ou le texte

    #{'pfb build -open'.jaune}
        pour produire la première version du livre en PDF 
        prêt à l'impression (et l'ouvrir pour le lire).

    ".bleu
    
  end

  def ask_for_open_folder
    if Q.yes?("Dois-je ouvrir le dossier #{of_the_thing} dans l’éditeur ?".jaune)
      `subl -n "#{folder}"`
    end    
  end

  def template_for(filename)
    File.join(Prawn4book::templates_folder, filename)
  end

end #/class InitedThing

class InitedBook < InitedThing
  def thing; "book" end
  def the_thing;"le livre" end
  def a_thing;"un livre" end
  def of_the_thing;"du livre" end
  def collection?; false end
  def book?; true end

  # @return true si le livre est dans une collection
  def in_collection?
    File.exist?(File.join(File.dirname(folder),'recipe_collection.yaml'))
  end

  # @return le path à un fichier de la collection (si le livre
  # appartient à une collection)
  def collection_file(filename)
    in_collection? && File.join(folder_collection, filename)
  end
  
  # @prop Dossier de la collection (si le livre appartient à une
  # collection)
  def folder_collection
    @folder_collection ||= begin
      in_collection? && File.dirname(folder)
    end
  end
  def recipe_name
    @recipe_name ||= 'recipe.yaml' 
  end
end

# 
# Pour une collection
# 
class InitedCollection < InitedThing
  def thing; "collection" end
  def the_thing; "la collection" end
  def a_thing; "une collection" end
  def of_the_thing;"de la collection" end
  def collection?; true end
  def in_collection?; false end
  def book?; false end
  
  def recipe_name
    @recipe_name ||= 'recipe_collection.yaml' 
  end
end

end #/module Prawn4book
