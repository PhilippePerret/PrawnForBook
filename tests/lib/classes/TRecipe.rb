=begin
  Class TRecipe
  -------------
  Classe pour tester la recette

  @example

    rc = TRecipe.new(path/to/recipe)
    rc.has_data(data)
=end
require 'minitest'
require 'minitest/assertions'

module Minitest
class Test
class TRecipe
  include Minitest::Assertions
  attr_accessor :assertions

  attr_reader :path
  def initialize(path)
    @path = path
    self.assertions = 0
  end

###################       MÉTHODES DE TEST      ###################

  def has_data(dsearch, group_key = nil)
    should_exist
    dr = get_data
    if group_key
      assert dr.key?(group_key), "La recette devrait contenir la clé générale #{group_key.inspect}."
      dr = dr[group_key]
    end
    missing_data = []
    error_data   = []
    error_message = []
    unless missing_data.empty?
      error_message << "Des données sont manquantes : #{missing_data.pretty_join}"
    end
    unless error_data.empty?
      error_message << "Des données sont erronées :"
      error_data.each do |prop, expected, actual|
        error_message << "    La donnée #{prop.inspect} devrait valoir #{expected.inspect}, elle vaut #{actual.inspect}."
      end
    end
    error_message = error_message.join("\n")
    assert_empty(error_message, error_message)
  end

  def should_exist
    assert_equal(true, File.exist?(path), "Le fichier recette #{path.inspect} est introuvable.")
  end

#################       FUNCTIONAL METHODS      #################
  

  # @return [Hash] Les données du fichier actuel
  def get_data
    YAML.load_file(path, symbolize_names:true)
  end

end #/class TRecipe
end #/class Test
end #/module Minitest
