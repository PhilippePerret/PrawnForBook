module Prawn4book
class PdfBook
class << self

  def proceed_init_par_templates(cdata)
    @inited = case cdata[:what]
    when :book then InitedBook.new
    when :collection then InitedCollection.new
    end
    # 
    # On y va
    # 
    @inited.init
  end
end #/<< self
end #/class PdfBook
  
# @prop Dossier contenant tous les templates
def self.templates_folder
  @templates_folder ||= File.join(APP_FOLDER,'resources','templates')
end

# Class InitedThing
# -----------------
# Classe abstraite pour la chose à initier, livre ou collection
# 
class InitedThing
  def folder
    @folder ||= PdfBook.cfolder
  end
  ##
  # = main =
  # 
  # Main méthode qui initie la chose
  # 
  def init
    build_recipe || return
    if book?
      build_texte || return
    end
    build_parser
    build_formater
    build_helpers
    confirmation_finale
  end
  def build_recipe
    require_relative 'builders/recipe'
    return proceed_build_recipe
  end
  def build_parser
    proceed_build_file('parser.rb')
  end
  def build_formater
    proceed_build_file('formater.rb')
  end
  def build_helpers
    proceed_build_file('helpers.rb')
  end
  def build_texte
    proceed_build_file('texte.p4b.md')
  end

  def confirmation_finale
    puts "
    À présent, vous pouvez jouer ces commandes :
    
    #{'pfb open -e'.jaune}
        pour ouvrir le dossier dans l'éditeur et modifier la
        recette, les méthodes ou le texte

    #{'pfb build -open'.jaune}
        pour produire la première version du livre en PDF 
        prêt à l'impression.

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
