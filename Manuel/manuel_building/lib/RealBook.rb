#
# Cette classe permet de faire des essais réels de livre et
# d’extraire des images.
# 
module Prawn4book
class RealBook

  IMAGE_STACK = []

  class << self

    # Méthode qui attend que toutes les images soient prêtes
    def wait_for_images_ready
      # - Calcul du timeout -
      # On le fixe en comptant 2 secondes pour produire chaque 
      # image, et on ajoute encore 10 secondes au total, ce qui est
      # normalement largement assez
      # 
      time_out = IMAGE_STACK.count * 2 + 10
      # - On n’ira pas au-delà de ce temps -
      max_time = Time.now.to_i + time_out
      # - Message d’attente -
      STDOUT.write "Attente de préparation des images “real books”…".jaune
      # - Attente des images -
      while not(images_ready?) && Time.now.to_i < max_time
        sleep 0.5
      end
      STDOUT.write "\r" # + " "*50 # il va y avoir des points verts
      return true if images_ready?
      puts "Les images suivantes ne sont pas prêtes : ".rouge
      raise IMAGE_STACK.join("\n").rouge
    end

    # Méthode qui retourne true quand toutes les images sont
    # prêtes
    def images_ready?
      images = IMAGE_STACK.dup.freeze
      IMAGE_STACK.clear
      images.each do |image_fullpath|
        unless File.exist?(image_fullpath)
          IMAGE_STACK << image_fullpath
        end
      end
      IMAGE_STACK.empty?
    end

    def add_image_in_stack(image_path)
      IMAGE_STACK << image_path
    end

  end #/ class << self

  EXTRACTION_COMMAND = '/opt/homebrew/bin/convert -density 300 "book.pdf[%{page}]" "page-%{numero}.jpg"'.freeze
  PRODUCTION_COMMAND = '/Users/philippeperret/Programmes/Prawn4book/prawn4book.rb build'.freeze

  attr_reader :name
  alias :affixe :name

  def initialize(data)
    @data = data
    @name = data[:name] || raise("Il faut le nom du dossier de l’image")
  end

  # = main =
  # 
  # Préparation du livre
  # 
  def prepare(texte, recette)
    `mkdir -p "#{folder}"`
    File.write(text_file_path, texte)
    File.write(recipe_file_path, recette)
  end

  # = main =
  # 
  # Méthode principale qui produit le livre avec PFB
  # 
  def produce
    File.delete(book_pdf_path) if exist?
    delete_all_images
    Dir.chdir(folder) do
      res = `#{PRODUCTION_COMMAND} 2>&1`
      if res.match('produit avec succès')
        # OK
      else
        puts "Erreur au cours de la conversion du real-book #{name} :".rouge
        puts "res = #{res.inspect}".rouge
        return false
      end
    end
    return true
  end


  # = main =
  # 
  # Méthode principale qui extrait les images voulues du livre
  # 
  def extract_pages(numeros)
    # Il faut d’abord attendre que le fichier PDF exist
    wait_until_exist || return
    numeros.each do |num|
      continuer = extract_page(num)
      break unless continuer
    end
  end

  # Extraction de l’image +numero_page+
  # 
  def extract_page(numero_page)
    image_fullpath = "#{folder}/page-#{numero_page}.jpg"
    index_page = numero_page - 1
    cmd = EXTRACTION_COMMAND % {page: index_page, numero: numero_page}
    Dir.chdir(folder) do
      res = `#{cmd} 2>&1`
      if res.match?('Requested FirstPage is greater than the number of pages')
        add_erreur("Page introuvable : #{numero_page} de #{name}.")
        return false
      else
        RealBook.add_image_in_stack(image_fullpath)
      end
    end
    return true # pour passer à l’image suivante
  end


  def exist?
    File.exist?(book_pdf_path)
  end

  # Time de la dernière fabrication du PDF
  def last_time
    File.stat(book_pdf_path).mtime
  end


  def recipe_file_path
    @recipe_file_path ||= File.join(folder, 'recipe.yaml')
  end

  def text_file_path
    @text_file_path ||= File.join(folder, 'texte.pfb.md')
  end

  def book_pdf_path
    @book_pdf_path ||= File.join(folder, 'book.pdf')
  end

  def folder
    @folder ||= File.join(REALBOOKS_FOLDER, self.name)
  end


  private

  MAX_TIMEOUT = 15
  def wait_until_exist
    max_time = Time.now.to_i + MAX_TIMEOUT
    while Time.now.to_i < max_time
      return true if exist?
      sleep 1
    end
    puts "[Timeout] Le PDF de #{name} n’a pas été produit…".rouge
    return nil # erreur
  end

  def delete_all_images
    Dir["#{folder}/page-*.jpg"].each{|fn|File.delete(fn)}  
  end


end #/class RealBook
end #/module Prawn4book
