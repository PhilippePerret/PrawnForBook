#
# Méthodes utiles pour les tests "produce" qui fonctionne en 
# comparant un document PDF produit par l'application avec le
# document attendu (par le hash)
# 
require 'digest/md5'

# Produit le livre PDF et compare son hash à celui attendu
# 
def produce_book(rel_path, **options)
  # -- Chemin absolu vers le dossier du livre --
  book_path = File.join(TEST_FOLDER,'produce',rel_path)
  # -- On détruit le livre PDF s'il existe déjà --
  pdf_path = File.join(book_path,'book.pdf')
  File.delete(pdf_path) if File.exist?(pdf_path)
  # -- Fabrication (tentative) du livre --
  res = `cd "#{book_path}" && pfb build 2>&1`
  if res.match?(/(succès|success)/)
    if File.exist?(pdf_path)
      actual_hash = Digest::MD5.file(pdf_path).hexdigest
      # -- On prend le hash attendu --
      expected_hash = get_hash_file_in(book_path)
      expected_hash || begin
        clip("test:\n  hash_ruby: \"#{actual_hash}\"")
        raise(ERREUR_NO_HASH % {hash: actual_hash})
      end
      # -- CHECK --
      assert_equal(expected_hash, actual_hash)
      # -- Détruire le livre --
      File.delete(pdf_path) unless options[:keep]
      return true
    else
      raise "L'application a retourné un succès mais le PDF n'a pas été produit. Bizarre…"
    end
  else
    raise "Une erreur est survenue :\n#{res.strip}"
  end
end #/produce_book

# Erreur lorsque le hash attendu n'est pas défini
# 
ERREUR_NO_HASH = <<~EOT
Il faut définir le hash attendu dans la recette du livre :

  ---
  test: 
    hash_ruby: ...

Mettre la valeur %{hash} si le document qui vient d'être
produit est le bon.
(la valeur a été placée dans le presse papier, avec test: hash_ruby:, il 
 te suffit donc de te placer à la fin du fichier recette et de la coller)

EOT

# Retourne le hash attendu pour le document
# 
def get_hash_file_in(book_path)
  recipe_path = File.join(book_path,'recipe.yaml')
  File.exist?(recipe_path) || raise("Le fichier recette #{recipe_path.inspect} devrait existe…")
  data = YAML.load_file(recipe_path, **{symbolize_names:true})
  data || raise("Le fichier recette #{recipe_path} ne contient aucune données…")
  data[:test] || raise("Le fichier recette #{recipe_path} devrait définir la clé :test.")
  data[:test][:hash_ruby]
end
