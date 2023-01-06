=begin

  L'idée de ce module de test est de tester en une seule fois toutes
  les situations possibles.

  Fonctionnement
  --------------
  On place dans le dossier ./tests/tested_books/ tous les dossiers des
  livres et des collections qui doivent être testés. Chaque livre
  définit un texte particulier, en commençant simple avec un livre
  ne contenant que 'Bonjour tout le monde !'.

  On lance la construction du livre, puis on analyse le résultat.

  Dans l'idéal (ça n'est pas encore réalisé quand j'écris ces lignes)
  le dossier du livre définit tous les tests qu'il faut lui appliquer
  soit de façon explicite, soit peut-être plutôt avec des données 
  comme :
  :assert_equal, '1', 'book.nombre_pages'
  :assert_equal, '2', 'book.nombre_textes'
  etc.
  avec chaque élément qui serait évalué pour connaitre la valeur.

=end
require 'test_helper'
require_relative 'lib/TestedBook'

# 
# INCLUSIONS ET EXCLUSIONS DE FICHIERS
# (à partir du nom du dossier)
# 
EXCLUDES_BY_NAME  = []
# EXCLUDES_IF_MATCH = /position/
# INCLUDES_IF_MATCH = /font/



#
# Mettre à true si on veut un message d'erreur plus complet
# (à true, la construction est lancée avec l'option -x/--debug)
# 
OPTION_DEBUG = false



###################       TESTS PRINCIPAUX      ###################


class BigAllBooksTest < Minitest::Test

  def setup
    super
  end
  def teardown
    
  end

  def self.define_test_method_for_book(book_folder)
    begin

      bookname = File.basename(book_folder)
      return if defined?(EXCLUDES_BY_NAME) && EXCLUDES_BY_NAME.include?(bookname)
      return if defined?(EXCLUDES_IF_MATCH) && bookname.match?(EXCLUDES_IF_MATCH)
      return if defined?(INCLUDES_IF_MATCH) && not(bookname.match?(INCLUDES_IF_MATCH))

      book = TestedBook.new(book_folder)

      puts "Construction de la méthode \"test_book_#{book.name}\"".jaune
      sleep 2

      define_method "test_book_#{book.name}".to_sym do

        Dir.chdir(book_folder) do
          STDOUT.write "\nConstructrion du livre #{book.name}... ".bleu
          book.delete_pdf
          res = `pfb build#{OPTION_DEBUG ? ' -x' : ''}`
          # sleep 2
          refute_match(/\[0;91m/, res, "La construction n'aurait pas du produire d'erreur. Elle a produit :\n#{res}")
          book.check
        end
      end #/define method
    
    rescue Exception => e
      puts "#{e.message} avec le dossier #{book.name}".rouge
    end    
  end


  # excludes = [] # ['without_recipe']

  folder = File.join(__dir__,'books')
  Dir["#{folder}/*"].each do |book_folder|
    define_test_method_for_book(book_folder)
  end


  folder = File.join(__dir__,'collections')
  Dir["#{folder}/*/*"].each do |book_folder|
    next unless File.directory?(book_folder)
    define_test_method_for_book(book_folder)
  end

end #/Minitest
