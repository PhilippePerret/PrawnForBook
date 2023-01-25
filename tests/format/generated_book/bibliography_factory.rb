module Factory
class Bibliography

  attr_reader :path, :id, :book

  # @param [String] path Dossier du livre
  def initialize(book, biblio_id, relpath)
    @book = book
    @id   = @tag = biblio_id
    @path = mkdir(File.join(book.folder, relpath))
    build_formater_rb
  end

  ##
  # Pour construire le fichier requis formater.rb dans le
  # dossier du livre
  # TODO Gérer aussi pour la collection
  def build_formater_rb
    formater_path = File.join(book.folder, 'formater.rb')
    File.write(formater_path, DEFAULT_FORMATER_CODE % {tag: id})
  end

  def add_item(item_data)
    item_path = File.join(path, "#{item_data[:id]}.yaml")
    File.write(item_path, item_data.to_yaml)
  end


DEFAULT_FORMATER_CODE = <<-RUBY
module FormaterBibliographiesModule
  def biblio_%{tag}(item)
    # Ici pour la mise en forme de l'+item+
  end
end
RUBY

end #/class Bibliography
end #/module Factory
