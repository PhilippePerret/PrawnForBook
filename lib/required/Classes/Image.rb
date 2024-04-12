# 
# Class Prawn4book::Image
# -----------------------
# Pour la gestion plus facile des images.
# 
# NOTER QUE SI C’EST LE PATH D’UNE IMAGE SVG QUI EST FOURNI, L’IMAGE
# EST AUTOMATIQUEMENT CONVERTIE EN SVG.
# 
# @usage
# 
#   #print_at(pdf, point)
# 
#     Écrit l’image dans +pdf+ à +point+
# 
#   #set_max_height(max_height)
# 
#       Fixe la hauteur maximum à max_height.
# 
require 'fastimage'
module Prawn4book
class Image

  attr_reader :path, :params

  def initialize(path, **params)
    @path   = path
    if File.extname(path) == '.svg'
      @path = self.class.convert_to_png(path, **params)
    end

    @params = params
    # @note : le width doit toujours être défini, pour que l’image
    # soit bien alignée. Si c’est params[:height] qui est défini,
    # il faut donc calculer la largeur
    calc_width_from_height if params[:height] && not(params[:width])
  end

  # Dessiner l’image au point +point+ dans le document +pdf+
  def print_at(pdf, point)
    self.at = point
    print(pdf)
  end

  def print(pdf)
    @data_prawn = nil
    calc_final_at(pdf)
    if svg?
      pdf.svg(IO.read(path), **data_prawn)
    else
      pdf.image(path, **data_prawn)
    end
  end

  def data_prawn
    @data_prawn ||= {
      at:     final_at,
      width:  width, 
      height: height,
    }
  end

  def svg?
    :TRUE == @issvg ||= true_or_false(File.extname(path).downcase == '.svg')
  end

  # Le :at, mais en tenant compte du fait que le :y de l’image, ici, 
  # est défini en partant du haut à gauche
  def final_at
    @final_at
  end
  def calc_final_at(pdf)
    @final_at = [at[0], pdf.bounds.height - at[1]]
    puts "\nfinal_at = #{final_at}"
  end

  def calc_width_from_height(h = nil)
    h ||= params[:height]
    @width = h * ratio
    puts "\n"
    puts "Image #{path}"
    puts "Natural width : #{natural_width}"
    puts "Natural height: #{natural_height}"
    puts "Ratio         : #{ratio}"
    puts "=> WIDTH : #{width} (#{@width}) (#{params[:height] * ratio} <= #{params[:height]} * #{ratio} <= height * ratio)"
  end

  def calc_height_from_width(w = nil)
    w ||= params[:width]
    @height = w / ratio
  end

  ##
  # Définit la position où il faut dessiner l’image
  # 
  def at=(point)
    @at = point
  end
  def at
    @at ||= params[:at] || [0,0]
  end

  ##
  # Pour rectifier le point de gravure de l’image
  # 
  # @return L’instance (pour le chainage)
  def delta_at(point)
    if point.is_a?(Array)
      at[0] += point[0]
      at[1] += point[1]
    elsif point.is_a?(Hash)
      at[0] += point[:x]
      at[1] += point[:y]
    else
      at[0] += point.x
      at[1] += point.y
    end
    return self
  end

  # Redéfinit si nécessaire la largeur pour une hauteur maximum
  # de +max_h+
  def set_max_height(max_h)
    if calculed_height > max_h
      @height = max_h
      @width  = nil
    end
  end

  def calculed_height
    @height || calc_height_from_width(width || natural_width)
  end

  def height
    @height ||= params[:height]
  end

  def width
    @width ||= params[:width]
  end

  # Ratio de l’image
  #   hauteur x ratio = largeur
  #   largeur / ratio = hauteur
  def ratio
    @ratio ||= natural_width.to_f / natural_height
  end

  def natural_width
    @natural_width ||= natural_size[:w]
  end

  def natural_height
    @natural_height ||= natural_size[:h]
  end

  def natural_size
    @size ||= begin
      s = FastImage.size(path)
      {w: s[0], h: s[1]}
    end

  end


  # -- CLASS --

  class << self

    ##
    # Convertit l’image SVG de chemin +pth+ en image PNG et
    # retourne le chemin d’accès au fichier PNG.
    # 
    # @params options [Hash]
    #   width:        Largeur de l’image PNG attendue, en pixels.
    #                 1024 pixels par défaut.
    #   keep_svg:     Mettre à true pour conserver l’image SVG. Sinon
    #                 elle est détruite.
    # 
    # @return [String] Le chemin d’accès absolu au fichier PNG
    # 
    def convert_to_png(pth, **options)
      width = options[:width] || 1024
      png_pth = File.join(File.dirname(pth),"#{File.basename(pth,File.extname(pth))}.png")
      unless File.exist?(png_pth)
        `inkscape -w #{width.to_i} "#{pth}" -o "#{png_pth}"`
        if File.exist?(png_pth) && not(options[:keep_svg])
          File.delete(pth)
        end
      end
      return png_pth
    end
  
  end

end #/class Image
end #/module Prawn4book
