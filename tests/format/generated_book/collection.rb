=begin
  
  Quand le livre généré pour et par les tests est dans une collection
  ce module gère l'instance Generated::Collection de la collection.

=end
module GeneratedBook
class Collection


  def self.erase_if_exist
    FileUtils.rm_rf(folder) if File.exist?(folder)
  end

  # --- Chemins d'accès utiles ---
  #
  def self.folder
    @@folder ||= mkdir(File.join(__dir__, '_generated_collection'))
  end

  def recipe
    @recipe ||= Recipe.new(self)
  end

  def folder
    @folder ||= self.class.folder
  end
end #/class Collection
end #/module GeneratedBook
