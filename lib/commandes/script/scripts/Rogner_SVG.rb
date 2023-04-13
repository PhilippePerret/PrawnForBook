#!/usr/bin/env ruby -wU
=begin

  Script permettant de rogner l'image SVG

  @usage

    - jouer en console 'pfb script rogner ./images/mon.svg'
    - c'est fait !


  TODO 

    * Si l'image n'est pas fournie, au lieu de produire une erreur,
      donner le liste des images du livre (et de la collection) et
      demander de la choisir.

=end
clear

BOOK_FOLDER = 
  if defined?(Prawn4book::PdfBook)
    Prawn4book::PdfBook.current.folder
  else
    ARGV[0]
  end

class SVGRogneur

ROGN_CMD = "inkscape -l -D -o \"%{rname}\" \"%{iname}\"".freeze

class << self

  ##
  # @main
  #
  # Méthode principale qui rogne l'image
  #
  def rogne(image_ref)
    puts "Dossier du livre : #{File.basename(BOOK_FOLDER).inspect}".bleu
    svg = SVGImage.new(image_ref)
    if svg.exist?
      puts "Image à rogner : #{svg.name}".bleu
      svg.delete_rogned_if_exists
      command = ROGN_CMD % {rname: svg.rogned_name, iname: svg.name}
      Dir.chdir(svg.folder) do
        res = `#{command} 2>&1`
        if res && res != ""
          puts "Une erreur est survenue : #{res.inspect}".rouge
        end
      end
      if svg.rogned_exist?
        puts "L'image rognée #{svg.rogned_name.inspect} a été produite avec succès.".vert
      else
        puts "Bizarrement, l'image rognée n'a pas pu être produite…".rouge
      end
    else
      puts "L'image SVG est introuvable.".rouge
    end
  end

end #/ << self SVGRogneur

class SVGImage
  attr_reader :relpath
  def initialize(relpath)
    @relpath = relpath
  end

  def delete_rogned_if_exists
    File.delete(path_rogned) if rogned_exist?    
  end

  def exist?
    path && File.exist?(path)
  end

  def rogned_exist?
    path && File.exist?(path_rogned)
  end

  def rogned_name
    @rogned_name ||= "#{affixe}-rogned.svg"
  end

  def path
    @path ||= search_path
  end

  def path_rogned
    @path_rogned ||= File.join(folder, rogned_name)
  end

  def name
    @name ||= File.basename(path)
  end

  def affixe
    @affixe ||= File.basename(path,File.extname(path))  
  end

  def folder
    @folder ||= File.dirname(path)
  end

  # Pour déterminer le chemin d'accès complet (et existant) du 
  # fichier SVG
  # 
  # @return [String] Le chemin d'accès à l'image
  def search_path
    if relpath && File.exist?(File.join(BOOK_FOLDER,relpath))
      # 
      # L'image se trouve dans le dossier du livre
      # 
      return File.join(BOOK_FOLDER,relpath)
    elsif relpath && File.exist?(File.join(BOOK_FOLDER,'..',relpath))
      #
      # L'image se trouve dans le dossier de la collection
      # 
      File.expand_path(File.join(BOOK_FOLDER,'..',relpath))
    elsif relpath
      #
      # L'image a été définie par un nom partiel. On la cherche
      # dans le dossier du livre et de la collection
      # 
      self.class.choose_correspondance_image(relpath) || begin
        puts "Aucun correspondance n'a été trouvée avec #{relpath.inspect}".rouge
        nil
      end
    else
      self.class.choose_image_svg
    end
  end


  ###################       CLASSE      ###################
  class << self

    # @return [String] Le chemin d'accès au fichier image
    def choose_image_svg
      Q.select("Image à rogner :".jaune, data_images, {filter:true, per_page:console_height - 5, show_help:false})
    end

    ##
    # Cherche l'image qui peut correspondre à +partial_name+
    # 
    # @return [String|Nil] Le chemin d'accès complet au fichier image
    # 
    def choose_correspondance_image(partial_name)
      regexp = /#{partial_name}/i.freeze
      data_images.each do |dimage|
        return dimage[:value] if dimage[:name].match?(regexp)
      end
      return nil
    end

    ##
    # @return [Array<Hash>] Liste des données des images trouvées
    # dans le dossier du livre.
    # 
    # Chaque élément est un choix Tty-prompt conforme, donc avec
    # :name et :value (path)
    def data_images
      @data_images ||= begin
        Dir["#{BOOK_FOLDER}/**/*.svg"].map do |fpath|
          nfile = File.basename(fpath)
          next if nfile.match?(/\-rogned\.svg/)
          {name:nfile, value:fpath}
        end.compact + data_images_collection
      end
    end

    def data_images_collection
      @data_images_collection ||= begin
        dossier = File.expand_path(BOOK_FOLDER,'..')
        Dir["#{dossier}/**/*.svg"].map do |fpath|
          nfile = File.basename(fpath)
          next if nfile.match?(/\-rogned\.svg/)
          {name:nfile, value:fpath}
        end.compact
      end
    end
  end #/ << self SVGImage
end #/SVGImage
end #/ SVGRogneur

SVGRogneur.rogne(ARGV[1])

exit 1


#
# === Ne rien toucher ci-dessous ===
#

folder = File.dirname(IMG_SRC)
affixe = File.basename(IMG_SRC, File.extname(IMG_SRC))
NAME_ROGNED = "#{affixe}-rogned.svg"
IMG_ROGNED = File.join(folder, NAME_ROGNED)

puts "Commande jouée : #{ROGN_CMD}"
`#{ROGN_CMD}`


if File.exist?(IMG_ROGNED)
  puts "L'image #{affixe.inspect} a été rognée avec succès.".vert
  code_image = "IMAGE[images/#{NAME_ROGNED}|width:100\\\%\\\]"
  clip(code_image)
  puts "À tout hasard, j'ai mis le code #{code_image.inspect} dans le presse-papier".bleu
else
  puts "Bizarrement, l'image rognée de #{affixe.inspect} n'a pas été produit…".rouge
end
