require_relative 'AnyParagraph'
require 'fastimage'

module Prawn4book
class PdfBook
class NImage < AnyParagraph

  # @public
  # 
  # Méthode qui parse le code contenu à l'intérieur d'un ![...]
  # dans le fichier source (ou IMAGE[...] pour la régression).
  # @note : ce code doit se trouve seul sur la ligne où l’image
  # doit être insérée
  # 
  # @param dimg [String] Intérieur de IMAGE[...]
  # 
  # @return [Hash] Les données pour l'image
  # 
  def self.parse(dimg)
    case dimg
    when NilClass
      {}
    when /^\{(.+)\}$/.freeze
      eval($1)
    else
      eval("{#{dimg}}")
    end
  end

  attr_reader :filename
  attr_reader :data
  attr_reader :pdf

  def initialize(book:, path:, data_str:, pindex:)
    super(book, pindex)
    @type = 'image'
    @data = NImage.parse(data_str)
    @filename = path
  end


  # --- Printer Methods ---

  def me
    @me ||= "Image #{filename} (#{legend.to_s.gsub('<br>',' ')}"
  end

  def reset
    @left   = nil
    @right  = nil
    @width  = nil
    @height = nil
  end

  ##
  # Méthode principale qui "imprime" le paragraphe dans le PDF
  # du livre
  # 
  # Reprise de la réflexion sur le calcul des mesures de l’image. 
  # Au maximum, on doit définir :
  #   - width       La largeur de l’image, en pt-ps, ou non
  #   - height      La hauteur de l’image, en pt-ps, ou non
  #   - left        La position gauche définie, ou par défaut (0)
  #   - right       La position droite définie ou non
  #   - top         La valeur verticale
  #     at: [left, top]
  # 
  # Si rien n’est défini, ni :width, ni :height n’ont à être définis
  # dans les données de l’image, que ce soit pour les images normales
  # ou les images svg
  # Si :width et :right sont définis, l’image peut être déformée, 
  # les valeurs doivent être définis dans les données de l’image
  # 
  # Les valeurs contextes susceptibles de modifier les valeurs :
  #   La largeur de la page qu’aucune image ne peut exéder (pour le
  #   moment, c’est-à-dire jusqu’au moment où on pourra "cadrer" une
  #   image — et donc ce sera le cadre qui sera important)
  # 
  def print(pdf)
    spy(:on) if first_turn?

    my = self # ATTENTION : pas "me"

    exist? || begin
      add_erreur(PFBError[250] % {filename:filename}) if Prawn4book.first_turn?
      return false
    end

    # Reset (surtout pour le second tour)
    reset

    # Exposer à toute l’instance
    @pdf = pdf

    # # 
    # Il faut mettre le style par défaut
    # 
    # pdf.font(pdf.default_font_name, **{style:pdf.default_font_style, size:pdf.default_font_size})
    pdf.font(Fonte.default_fonte, **{size:Fonte.default_fonte.size})

    # Table où seront consignés les données de l’image
    @data_image = {}

    # Rectifier les valeurs si elles sont définies et trop grandes
    rectify_height if height
    rectify_width
    rectify_height unless height

    # - Positionnement de l'image -
    
    if left > 0
      spy "left est défini et vaut #{left.inspect}".jaune
      @data_image.merge!(at: [left, pdf.cursor - pdf.line_height])
    elsif right > 0
      spy "right est défini et vaut #{right.inspect}".jaune
      left = pdf.bounds.width - (calc_width + right)
      @data_image.merge!(at: [left, pdf.cursor - pdf.line_height])
    else
      @data_image.merge!({
        position: @data[:align]||:center
      })
    end

    # - Passer à la page suivante s’il reste trop peu de hauteur -
    # Non, il n’y a rien à faire, ça se fait tout seul
    # car l’image va passer naturellement à la page suivante
    if calc_height > pdf.cursor
      spy "Il reste trop peu de hauteur pour mettre l’image"
      if @data_image.key?(:at)
        @data_image[:at][1] = pdf.bounds.top
      end
    end

    if svg?
      @data_image.merge!(color_mode: :cmyk)
    end

    spy "Image:       #{filename}".bleu
    spy "Légende:     #{legend}".bleu if legend
    spy <<~EOD.bleu
      (taille page : #{pdf.bounds.width.round(2)} x #{pdf.bounds.height.round(2)})
      Original W: #{original_width.inspect}
      Original H: #{original_height.inspect}
      Explicit W: #{width.inspect}
      Explicit H: #{height.inspect}
      Calc W:     #{calc_width} 
      Calc H:     #{calc_height} 
      Scale:      #{scale.inspect}
      left:       #{left.inspect}
      right:      #{right.inspect}
      position legend: #{position_legend}
      left legend: #{left_legend}
      -----------
      Data image: #{@data_image}
      EOD


    # Propriété à sortir (pour le scope dans pdf)
    # 
    img_path = path
    # mg_bottom = margin_bottom

    data_image = @data_image

    pdf.update do

      # On passe à la ligne, sauf quand l’image occupe toute la
      # page
      unless (my.calc_height + my.legend_height + my.vadjust) >= bounds.height
        final_line = line_height - line_height / 2
        move_down(final_line)
        data_image[:at][1] += final_line if data_image.key?(:at)
      end

      # S’il y a un ajustement vertical
      if my.vadjust > 0
        if data_image.key?(:at)
          data_image[:at][1] -= my.vadjust
        else
          move_down(my.vadjust)
        end
      end

      cursor_before = cursor.freeze

      #########################
      ###        IMAGE      ###
      #########################
      if my.svg?
        # Pour le moment, je ne sais pas gérer la rotation,
        # il faut tourner l’image d’origine et mettre la
        # bonne largeur/hauteur
        image = svg(IO.read(img_path), **data_image)
        # Hauteur prise par l'image
        image_height = image[:height]
        image_width  = image[:width]
      else
        image = image(img_path, **data_image)
        # Hauteur prise par l'image
        image_height = image.scaled_height
        image_width  = image.scaled_width
      end

      cursor_after = cursor.freeze

      if cursor_after == cursor_before
        move_down(image_height)
      elsif cursor_after < (cursor_before - image_height)
        puts "Le curseur n’est pas tout à fait en dessous pour #{my.me}".orange
      else
        # puts "Le curseur est bien placé#{he}".vert
      end

      #########################
      ###       LÉGENDE     ###
      #########################
      if my.legend
        # Calculer les options pour la légende
        my.legend_options({image_width:image_width})
        bounding_box(
          [my.left_legend, cursor - my.vadjust_legend], 
          position: my.position_legend,
          width: my.legend_options[:width]
        ) do
          text(my.legend, **my.legend_options)
        end
      end

      if my.svg?
        move_down(line_height)
      end        
    end #/pdf
    
    spy(:off) if first_turn?

  end #/print

  # --- Calcul Methods ---

  def rectify_width
    if calc_width > max_width
      @data_image.merge!(width: max_width)
      @data_image.delete(:height) unless height
    elsif width
      @data_image.merge!(width: width)
    elsif scale != 1.0
      @data_image.merge!(width: calc_width)
    end
  end

  def rectify_height
    if calc_height > max_height
      @data_image.merge!(height: max_height)
      @data_image.delete(:width) unless width
    elsif height
      @data_image.merge!(height: height)
    elsif scale != 1.0
      @data_image.merge!(height: calc_height)
    end
  end

  # @return [Float] La largeur calculée de l’image
  def calc_width
    width || begin
      @data_image.key?(:height) && @data_image[:height] / ratio 
    end || begin
      height && height / ratio
    end || begin
      original_width
    end
  end

  # @return [Float] La hauteur calculée de l’image
  # 
  def calc_height
    height || begin
      @data_image.key?(:width) && @data_image[:width] * ratio
    end || begin
      width && width * ratio
    end || begin
      original_height
    end
  end

  # @return [Float] La largeur max pour l’image
  # 
  def max_width
    page_width - (left + right)
  end

  # @return [Float] La hauteur max pour l’image
  # (en tenant compte de la légende)
  # 
  def max_height
    page_height - 10 - (vadjust + legend_height + vadjust_legend)
  end

  # w * ratio donnera la hauteur
  # h / ratio donnera la largeur
  def ratio
    @ratio ||= original_height.to_f / original_width
  end

  # @return [Float] La largeur actuelle de la page
  # 
  def page_width
    pdf.bounds.width.to_f
  end

  # @return [Float] la hauteur actuelle de la page
  # 
  def page_height
    pdf.bounds.height.to_f
  end

  # Hauteur que prendra la légende
  # TODO: Il faudrait affiner le calcul car la légend est moins 
  # large que la largeur de la page
  def legend_height
    @legend_height ||= begin
      if legend
        pdf.height_of(legend,**legend_options)
      else
        0
      end
    end
  end

  def position_legend
    (left > 0 && left) || @data_image[:position] || :center
  end

  def left_legend
    if @data_image[:position] == :right || right > 0
      pdf.bounds.width - (legend_width + right)
    else
      (left > 0 && left) || pdf.bounds.width / 2 - legend_width / 2
    end
  end

  # La légende occupe la moitié de la page ou la largeur de l’image
  # si elle est plus petite que la moitié de la page.
  def legend_width
    @legend_width ||= begin
      [pdf.bounds.width / 2, calc_width].min
    end
  end

  # Options text pour la légende (if any)
  def legend_options(params = nil)
    @legend_options ||= {
        align:  :center,
        style:  :italic,
        size:   Fonte.current.size - 1,
        width:  legend_width,
        inline_format: true,
      }
  end



  # --- Predicate Methods ---

  def first_turn?; Prawn4book.first_turn? end

  def image?    ; true  end
  def paragraph?; false end
  def printed?  ; true  end

  def exist?
    path && File.exist?(path)
  end

  def svg?
    :TRUE == @issvg ||= true_or_false(extname == '.svg')
  end

  # --- Image Data ---

  def original_width
    @original_width ||= original_size[:width] * scale
  end

  def original_height
    @original_height ||= original_size[:height] * scale
  end

  def original_size
    @original_size ||= begin
      width, height = FastImage.size(path)
      {width: width.to_f, height: height.to_f}
    end
  end

  # Width explicite
  def width
    @width ||= data[:width] && data[:width].to_pps(pdf.bounds.width)
  end

  # Heigh explicite
  def height
    @height ||= data[:height] && data[:height].to_pps(pdf.bounds.height)
  end

  def vadjust
    @vadjust ||= data[:vadjust] || 0.0
  end

  def left
    @left ||= begin
      data[:left].to_pps if data.key?(:left)
    end || 0.0
  end

  def right
    @right ||= begin
      data[:right].to_pps if data.key?(:right)
    end || 0.0
  end

  def scale
    @scale ||= data[:scale] || 1.0
  end

  def legend
    @legend ||= data[:legend] || data[:legende]
  end

  def vadjust_legend
    @vadjust_legend ||= data[:vadjust_legend] || 0.0
  end

  def extname
    @extname ||= File.extname(filename)
  end

  def path
    @path ||= PdfBook.current.image_path(filename)
  end

end #/class NImage
end #/class PdfBook
end #/module Prawn4book
