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

class BigAllBooksTest < Minitest::Test

  def setup
    super
  end
  def teardown
    
  end

  def test_de_tous_les_livres_construits

    excludes = ['without_recipe']

    folder = File.join(TEST_FOLDER,'tested_books','books')
    Dir["#{folder}/*"].each do |book_folder|
      begin
        book_name = File.basename(book_folder)
        next if excludes.include?(book_name)
        Dir.chdir(book_folder) do
          puts "Constructrion du livre #{book_name}".bleu
          res = `pfb build`
          if res.match?(/\[0;91m/) # texte en rouge
            message {"Une erreur de construction"}
            puts "#ERR de construction : ".rouge
            puts res

          end
        end
      rescue Exception => e
        puts "#{e.message} avec le dossier #{book_name}".rouge
      end
    end

  end

  def test_de_toutes_les_livres_de_collection_construits
    folder = File.join(TEST_FOLDER,'tested_books','collections')
    
  end

end #/Minitest
