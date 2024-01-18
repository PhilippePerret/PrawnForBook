# USAGE
# -----
# 
# Dans la définition de la feature, il faut mettre :
# 
# #real_texte
#   Contenu exact du fichier texte.pfb.md
# 
# @note
#   C’est à partir du moment où #real_texte est invoqué que
#   le programme sait qu’il s’agit d’un real book
# 
#   real_texte <<~EOT
#     <ici le code réel à interpréter>
#     EOT
# 
# #real_recipe
#   Contenu exact du fichier recipe.yaml (et entièrement,
#   en tenant compte du code de la collection)
# 
#   real_recipe <<~EOT
#     ---
#     # ...
#     EOT
# 
# #sample_texte
#   N’a pas besoin d’être défini, car c’est toujours le code défini
#   dans @real_texte qui sera repris et échappé.
# 
# #texte
#   Définit ce qui sera utilisé dans le manuel, et principalement
#   quelle(s) images et avec quel(s) texte(s)
#
#   C’est par rapport aux codes ’![page-<x>]’ qu’on déterminera
#   les pages à changer en images. Ce qui signifie que seules les
#   images définies dans @texte seront produites.
#   Astuce : il suffit de mettre le code entre ’<!-- ... -->’ pour
#   que l’image soit produite sans être insérée dans le document.
#   Cela permet de produire l’image pour un autre endroit du manuel
# 
#   Dans le texte ci-dessous, les ’page-<x>’ seront automatiquement
#   remplacé par la bonne adresse de l’image, dans le dossier
#   RealBooksCollection/<dossier du livre>/
# 
#   texte <<~EOT
#     On pourra voir l’image suivante :
#     ![page-1](width:'100%')
#     EOT
# 
#   Retour du programme de construction
#   -----------------------------------
#   Dans ’texte’, on peut écrire le retour du message de construction
#   du livre (lorsqu’on travaille le fichier) grâce à la marque
#   “_building_resultat_“ qu’on place à l’endroit voulu.
# 
#   Journal de construction
#   -----------------------
#   À l’avenir, il faudrait aussi une marque qui permette de charger
#   directement dans le livre le journal de construction.
# 
# ===========================================================
# 
# class Prawn4book::RealBook
# 
# Cette classe permet de faire des essais réels de livre et
# d’extraire des images.
# 
# @USAGE
#   Cf. ci-dessus   
# 
module Prawn4book
class RealBook

  # Pour produire le livre PDF
  PRODUCTION_COMMAND = '/Users/philippeperret/Programmes/Prawn4book/prawn4book.rb build'.freeze
  # Pour extraire une page du livre en image JPEG
  EXTRACTION_COMMAND = '/opt/homebrew/bin/convert -density 300 "book.pdf[%{page}]" "page-%{numero}.jpg";convert "page-%{numero}.jpg" -bordercolor grey -border 8 "page-%{numero}.jpg"'.freeze

  IMAGE_STACK = []

  class << self

    # Méthode qui attend que toutes les images soient prêtes
    # 
    # @note
    #   Le Timeout est adapté au nombre d’images.
    # 
    def wait_for_images_ready
      # Si toutes les images sont prêtes, on peut s’en retourner
      return true if images_ready?
      # Log
      logif "On doit attendre sur les images suivantes : #{IMAGE_STACK.inspect}"
      # - Calcul du timeout -
      # On le fixe en comptant 2 secondes pour produire chaque 
      # image, et on ajoute encore 10 secondes au total, ce qui est
      # normalement largement assez
      # 
      time_out = IMAGE_STACK.count * 2 + 10
      # - On n’ira pas au-delà de ce temps -
      max_time = Time.now.to_i + time_out
      # - Message d’attente -
      puts "\nAttente préparation des images des real books…".jaune
      sleep 1
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

  attr_reader :name
  alias :affixe :name

  # Retour de construction
  attr_reader :building_resultat

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
    logif("- Production du real-book ’#{name}’") # dans le loginfile principal
    delete_all # pdf et images
    Dir.chdir(folder) do
      res = `#{PRODUCTION_COMMAND} 2>&1`
      @building_resultat = res
      if res.match('produit avec succès')
        # OK
      else
        puts "Erreur au cours de la conversion du real-book #{name} :".rouge
        raise "Retour de la commande build du real-book) =\n#{res.inspect}".jaune
        exit 16
        # return false
      end
    end
    return true
  end


  # = main =
  # 
  # Méthode principale qui extrait les images voulues du livre
  # dès que le book est prêt.
  # 
  # @note
  #   On ne le fait que :
  #   1) lorsque l’image n’existe pas encore
  #   2) lorsque l’image est plus vieille que le book
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
    wait_until_exist
    image_fullpath = "#{folder}/page-#{numero_page}.jpg"
    return if File.exist?(image_fullpath) && (last_time < ctime_image(image_fullpath))
    index_page = numero_page - 1
    cmd = EXTRACTION_COMMAND % {
      page:   index_page, 
      numero: numero_page,
    }
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

  def ctime_image(ipath)
    File.stat(ipath).ctime
  end

  # @return true si le real-book n’a pas changé
  # 
  def up_to_date?(last_modified_time)
    return false if Prawn4book.force?
    exist? && last_modified_time < last_time
  end

  def exist?
    File.exist?(book_pdf_path)
  end

  # Time de la dernière fabrication du PDF
  def last_time
    File.stat(book_pdf_path).ctime
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

  def delete_all
    File.delete(book_pdf_path) if exist?
    delete_all_images
  end

  def delete_all_images
    Dir["#{folder}/page-*.jpg"].each{|fn|File.delete(fn)}  
  end


end #/class RealBook
end #/module Prawn4book
