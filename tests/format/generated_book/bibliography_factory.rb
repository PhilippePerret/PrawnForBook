module Factory
class Bibliography

  attr_reader :path, :id, :book

  # @param [String] relpath Dossier du livre
  def initialize(book, biblio_id, relpath)
    @book = book
    @id   = @tag = biblio_id
    @path = mkdir(File.join(book.folder, relpath))
  end

  def make_items_with_props(props, nombre = 5)
    nombre.times.map do |indice|
      item_id = "item#{indice}"
      data = {id: item_id}
      props.each {|prop| data.merge!(prop => random_mot)}
      item_path = File.join(path, "#{item_id}.yaml")
      File.write(item_path, data.to_yaml)
      data # => map
    end
  end

  def add_item(item_data)
    item_path = File.join(path, "#{item_data[:id]}.yaml")
    File.write(item_path, item_data.to_yaml)
  end


  private

    def random_mot
      len = 5 + rand(10)
      mot = ""
      while mot.length < len
        if rand(10).odd?
          chr = (65 + rand(26)).chr
        else
          chr = (97 + rand(26)).chr
        end
        mot = "#{mot}#{chr}"
      end
      # puts "Mot généré : #{mot.inspect}"
      return mot
    end


end #/class Bibliography
end #/module Factory
