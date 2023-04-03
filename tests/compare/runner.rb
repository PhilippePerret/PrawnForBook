=begin

  Runner principal qui lance tous les tests par comparaison.

  @usage
  ------

      1. Ouvrir un Terminal au dossier de Prawn-for-book
      2. Jouer 'rake test TEST=tests/compare/runner.rb'

=end
require 'timeout'
require 'test_helper'
# require_relative 'lib/required'

#
# Pour ne lancer que les tests ci-dessous
# 
# INCLUDES = ['simple_table']
# INCLUDES = /cross_references/
INCLUDES = nil unless defined?(INCLUDES)
# 
# Tests à exclure (nom du dossier)
# EXCLUDES = /^references/
EXCLUDES = []
#
# Pour jouer un ou des dossiers de collection précis
# 
# FOLDERS = ['tables']

class PourLancerTestDeComparaion < Minitest::Test
  def setup
    super
  end

  def test_runner
    TestPerCompare.tests_run(self)
  end

  def compare(exp, act)
    assert(itest.as_expected?, itest.error_message)
  end
end

class TestPerCompare

  # Lancement général des tests par comparaison
  def self.tests_run(instance_test)
    if defined?(FOLDERS)
      if FOLDERS.is_a?(Array)
        FOLDERS.each do |folder|
          run_tests_in_folder("#{tests_folder}/#{folder}/**/texte.pfb.md",instance_test)  
        end
      else
        run_tests_in_folder("#{tests_folder}/#{FOLDERS}/**/texte.pfb.md",instance_test)
      end
    else
      run_tests_in_folder("#{tests_folder}/**/texte.pfb.md",instance_test)
    end
  end

  def self.run_tests_in_folder(dossier, instance_test)
    Dir[dossier].each do |fpath|
      next if exclude?(fpath)
      itest = new(fpath)
      puts "\n\n"
      instance_test.resume(itest.resume)
      if itest.run
        if itest.has_expected_book?
          instance_test.assert(itest.as_expected?, itest.error_message)
          instance_test.mini_success(itest.message_success)
        else
          instance_test.refute(true, "Le test #{itest.designation} n'a pas encore de livre à comparer (expected.pdf)…")
        end
      end
    end
  end

  # Return true s'il faut exclure ce test des tests
  def self.exclude?(fpath)
    tname = File.basename(File.dirname(fpath))
    case EXCLUDES
    when Array
      return true if EXCLUDES.include?(tname)
    when Regexp
      return true if tname.match?(EXCLUDES)
    when String
      return true if tname == EXCLUDES
    end
    case INCLUDES
    when NilClass then return false
    when Array 
      return not(INCLUDES.include?(tname))
    when Regexp
      return not(tname.match?(INCLUDES))
    when String
      return not(tname == INCLUDES)
    end
    return false
  end

  # Dossier contenant tous les tests par comparaison
  def self.tests_folder
    @@tests_folder ||= File.expand_path(File.join(__dir__,'tests'))
  end


###################       INSTANCE      ###################
  
  attr_reader :texte_path
  def initialize(path)
    @texte_path = path
  end

  def run
    delete_book
    res = `cd "#{folder}";pfb build`
    # res = `cd "#{folder}";pfb build -debug`
    raise res if res.match?(/ERR/)

    Timeout.timeout(5) { sleep 0.2 until File.exist?(actual_book) }
    if book_exist?
      return true
    else
      raise "Le livre n'a pas pu être construit."
    end
  end

  def resume
    @resume ||= begin
      if data
        data[:description]||data[:resume]
      else
        "Construction du #{designation}"
      end
    end
  end

  def designation
    @designation ||= begin
      "livre " + if data
        data[:name]
      else
        folder_name
      end.inspect
    end
  end
  def message_success
    "Le #{designation} a été produit conformément aux attentes."
  end
  # @return [String] Le message d'erreur quand le livre ne
  # correspond pas à ce qui était attendu.
  def error_message
    "Le fichier #{folder_name}/book.pdf ne correspond pas au fichier attendu (cf. #{folder_name}/expected.pdf)"
  end

  def delete_book
    File.delete(actual_book) if File.exist?(actual_book)
  end

  # @return true si le test possède un livre à comparer
  def has_expected_book?
    File.exist?(expected_book)
  end

  # @return true si le livre actual.pdf correspond exactement au
  # livre expected.pdf
  def as_expected?
    FileUtils.identical?(expected_book, actual_book)
  end


  def book_exist?
    File.exist?(actual_book)
  end
  def actual_book
    @actual_book ||= File.join(folder,'book.pdf')
  end
  def expected_book
    @expected_book ||= File.join(folder,'expected.pdf')
  end

  def data
    @data ||= begin
      YAML.load_file(data_path,**{symbolize_names:true}) if File.exist?(data_path)
    end
  end
  def data_path
    @data_path ||= File.join(folder,'data-test.yaml')
  end
  def folder_name
    @folder_name ||= File.basename(folder)
  end
  def folder
    @folder ||= File.dirname(texte_path)
  end
end
