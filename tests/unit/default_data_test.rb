require 'test_helper'
class DefaultDataTest < Minitest::Test

  require 'lib/required/Recipe.rb'
  require 'lib/pages/book_format/data.rb' # => PAGE_DATA
  PAGE_DATA = page_data = Prawn4book::Pages::BookFormat::PAGE_DATA

  def test_peuple_with_default_data_respond
    assert_respond_to Prawn4book::Recipe, :peuple_with_default_data
  end

  def test_book_data_all_default
    # ===> Test <===
    dd = Prawn4book::Recipe.peuple_with_default_data({}, PAGE_DATA)
    # puts "dd = #{dd.inspect}"
    # --- Vérifications ---
    assert_equal([:book, :page, :text],PAGE_DATA.keys)
    PAGE_DATA.each do |prop, dv| # p.e. :page
      assert dd.key?(prop), "La table des données devrait définir la clé #{prop.inspect}."
      dv.each do |sp, sdv|
        if sdv.key?(:default)
          assert dd[prop].key?(sp), "La clé #{prop.inspect} de la table des données devrait définir la clé #{sp.inspect}"
          assert dd[prop][sp], "dd[:#{prop}][:#{sp}] ne devrait pas être nil…"
        else
          sdv.each do |ssp, ssdv|
            assert dd[prop][sp].key?(ssp), "La clé [:#{prop}][:#{sp}] de la table des données devrait définir la clé #{ssp.inspect}"
            assert dd[prop][sp][ssp], "dd[:#{prop}][:#{sp}][:#{ssp}] ne devrait pas être nil"
          end
        end
      end
    end 
  end

  # Test avec quelques valeurs définies
  # Elle ne doivent pas être écrasées par les valeurs par défaut
  def test_book_data_default_not_all
    dd = {book: {height: '400m'}}
    new_dd = Prawn4book::Recipe.peuple_with_default_data(dd, PAGE_DATA)
    assert_equal '400m', new_dd[:book][:height], "La méthode de peuplement ne devrait pas avoir remplacé la valeur :book:height par la valeur par défaut…"
  end

end #/class Minitest
