=begin

  Class abstraite Prawn4Book::PrawnOwner

  Pour les "propriétaires", c'est-à-dire :
  - un livre (Prawn4Book::PdfBook)
  - une collection (Prawn4Book::Collection)

=end
module Prawn4book
class PrawnOwner

  def ensured_title
    @ensured_title ||= title || File.basename(folder)
  end

  def titre       ; recette.title     end
  alias :title :titre
    
  ##
  # Première fonte définie (pour valeur par défaut de certains
  # texte majeurs)
  # 
  def first_font
    @first_font ||= Fonte.default_fonte
  end
  alias :default_font :first_font

  # @prop Seconde fonte définie (ou première si une seule) pour 
  # valeur par défaut de certains texte mineurs.
  def second_font
    @second_font ||= Fonte.fontes[1] || first_font
  end

  # @prop Instance {PdfBook::Recipe} de la recette du livre
  # @usage
  #   <book>.recette[key] # => valeur dans la recette du livre
  #                       #    ou la recette de la collection
  def recipe
    @recipe ||= Prawn4book::Recipe.new(self)
  end
  alias :recette :recipe

  def recipe_path
    @recipe_path ||= File.join(folder, recipe_name)
  end

  def image_path(relpath)
    if File.exist?(relpath)
      relpath
    elsif in_collection? 
      if File.exist?(pth = File.join(collection.folder, relpath))
        return pth
      elsif File.exist?(pth = File.join(collection.folder,'images',relpath))
        return pth
      end
    elsif File.exist?(pth = File.join(folder, relpath))
      return pth
    elsif File.exist?(pth = File.join(folder_images, relpath))
      return pth
    else
      nil
    end
  end

  def folder_fonts
    @folder_fonts ||= File.join(folder,'fonts')
  end

  def folder_images
    @folder_images ||= File.join(folder,'images')
  end

  # @return [String] Le path au dossier. Normalement, il est
  # défini à l'instanciation, par le dossier dans lequel est
  # ouverte la fenêtre de Terminal.
  def folder
    @folder ||= recette[:main_folder].tap do |pth|
      File.exist?(pth) || begin
        if recette[:main_folder].nil?
          raise ERRORS[:recipe][:main_folder_not_defined]
        else
          raise ERRORS[:unfound_folder] % recette[:main_folder]
        end
      end
    end
  end

end #/ class PrawnOwner
end #/ module Prawn4book
