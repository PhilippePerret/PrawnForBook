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
  # Main méthode qui initie la chose (livre ou collection)
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
    #
    # Confirmation/message final
    # 
    confirmation_finale || return
  end

  def build_base_files
    if book?
      BuilderFile.new(self).build('texte.pfb.md') 
      BuilderFile.new(self).build('Notes.md')
    end
    BuilderFile.new(self).build('parser.rb')
    BuilderFile.new(self).build('formater.rb')
    BuilderFile.new(self).build('helpers.rb')
    BuilderFile.new(self).build('snippets/exemple_snippet.sublime-snippet')

  end

  def confirmation_finale
    puts MESSAGES[:assistant][:confirmation_init] % {folder: File.basename(folder)}
  end

  def ask_for_open_folder
    if Q.yes?((PROMPTS[:Open_in_editor] % {folder:of_the_thing}).jaune)
      `subl -n "#{folder}"`
    end    
  end

  def template_for(filename)
    File.join(Prawn4book::templates_folder, filename)
  end

end #/class InitedThing
end #/module Prawn4book
