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
    dimage = {}

    # Si la largeur est définie, elle ne doit pas excéder la largeur
    # de la page. On tient compte de la valeur :left, toujours au 
    # moins égale à 0 et de la valeur :right, nil par défaut
    # rectifier_width_if_too_big(width||original_width) if height.nil?

    # Si la hauteur est définie, elle ne doit pas excéder la hauteur
    # de la page. On tient compte de la légende qui existe peut-être
    # calc_height = width && width * ratio
    # rectifier_height_if_too_big(height||calc_height||original_height) if height || calc_height || width.nil?

    # Dans un deuxième temps, si soit :width soit :height est défini,
    # il faut vérifier que l’autre valeur, quand elle n’est pas 
    # définie, va produire. C’est-à-dire la valeur réelle de :height
    # quand seul :width est défini, est inversement.
    # if width && height.nil?
    #   rectifier_height_if_too_big(dimage[:width].to_f * ratio)
    # elsif height && width.nil?
    #   rectifier_width_if_too_big(dimage[:height].to_f / ratio)
    # end

    width_page  = pdf.bounds.width
    height_page = pdf.bounds.height

    # Si une échelle est déterminée, il faut tout de suite modifier
    # les valeurs qu’on a, c’est-à-dire :width et/ou :height si défini 
    # ou alors toujours :original_width et original_height
    # Donc, comprendre que dans tous les cas, :scale ne sera pas 
    # utilisé.
    if scale

    end

    # Quand ni width, ni height sont définis, il faut voir si l’image
    # "fit", en hauteur comme en largeur
    w = (width || original_width || (height && height.to_f / ratio)).dup
    if left + w + (right||0) > width_page
      dimage.merge!(width: width_page - (left + (right||0)))
      calc_height = dimage[:width] * ratio
      if calc_height + legend_height > height_page
        dimage.delete(:width)
        dimage.merge!(height: height_page - (legend_height + pdf.line_height))
      end
    else
      # - Si la largeur est bonne -
      h = (height || original_height || (width && width.to_f * ratio)).dup
      if h + legend_height > height_page
        dimage.merge!(height: height_page - (legend_height + pdf.line_height))
      end
    end

    
    # La largeur qu’aura l’image, que cette largeur soit définie ou
    # non.
    calc_width = dimage[:width] || begin
      # La largeur calculée par rapport à la hauteur
      dimage[:height] && (dimage[:height].to_f / ratio)
    end || begin
      # Sinon la largeur naturelle de l’image
      original_width
    end

    # La hauteur qu’aura l’image, que cette hauteur soit définie ou
    # non.
    calc_height = dimage[:height] || begin
      # La hauteur calculée par rapport à la largeur
      dimage[:width] && (dimage[:width].to_f * ratio)
    end || begin
      # Sinon la hauteur naturelle de l’image
      original_height
    end


    # - Positionnement de l'image -
    
    if left > 0
      spy "left est défini et vaut #{left.inspect}".jaune
      dimage.merge!(at: [left, pdf.cursor - pdf.line_height])
    elsif (right || 0) > 0
      spy "right est défini et vaut #{right.inspect}".jaune
      left = pdf.bounds.width - (calc_width + right)
      dimage.merge!(at: [left, pdf.cursor - pdf.line_height])
    else
      dimage.merge!({
        position: @data[:align]||:center
      })
    end

    # - Passer à la page suivante s’il reste trop peu de hauteur -
    # Non, il n’y a rien à faire, ça se fait tout seul
    if (calc_height + legend_height) > pdf.cursor
      spy "Il reste trop peu de hauteur pour mettre l’image"
      pdf.start_new_page
      if dimage.key?(:at)
        dimage[:at][1] = pdf.cursor
      end
    end

    if svg?
      dimage.merge!(color_mode: :cmyk)
    end

    spy "Image:       #{filename}".bleu
    spy "Légende:     #{legend}".bleu if legend
    spy <<~EOD.bleu
      (taille page : #{pdf.bounds.width.round(2)} x #{pdf.bounds.height.round(2)})
      width defined:  #{width.inspect}
      height defined: #{height.inspect}
      Actual Width:   #{dimage[:width].inspect}
      Actual Height:  #{dimage[:height].inspect}
      Ori Width:      #{original_width.inspect}
      Ori Height:     #{original_height.inspect}
      Calc width:     #{calc_width} 
      Calc height:    #{calc_height} 
      Scale:          #{scale.inspect}
      left:           #{left.inspect}
      right:          #{right.inspect}
      Data image:     #{dimage}
      EOD


    # Propriété à sortir (pour le scope dans pdf)
    # 
    img_path      = path
    # mg_bottom = margin_bottom

    pdf.update do
      # On passe à la ligne, sauf quand l’image occupe toute la
      # page
      unless (calc_height + my.legend_height) >= bounds.height
        final_line = line_height - line_height / 2
        move_down(final_line)
        dimage[:at][1] += final_line if dimage.key?(:at)
      end

      # S’il y a un ajustement vertical
      if my.vadjust
        if dimage.key?(:at)
          dimage[:at][1] -= my.vadjust
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
        image = svg(IO.read(img_path), **dimage)
        # Hauteur prise par l'image
        image_height = image[:height]
        image_width  = image[:width]
      else
        image = image(img_path, **dimage)
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
        bounding_box([pdf.bounds.width / 4, cursor], position: :center, width: my.legend_options[:width]) do
          text(my.legend, **my.legend_options)
        end
      end

      if my.svg?
        move_down(line_height)
      end        
    end #/pdf
    
    spy(:off) if first_turn?

  end #/print

  # Options text pour la légende (if any)
  def legend_options(params = nil)
    @legend_options ||= {
        align:  :center,
        style:  :italic,
        size:   Fonte.current.size - 1,
        width:  pdf.bounds.width / 2,
        inline_format: true,
      }
  end

  def rectifier_width_if_too_big(w)
    if left + w + (right||0) > pdf.bounds.width
      @width = pdf.bounds.width - ( left + (right||0) )
    end
  end
  def rectifier_height_if_too_big(h)
    if ( h + legend_height ) > pdf.bounds.height
      @height = pdf.bounds.height - legend_height
    end      
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
    @original_width ||= original_size[:width]
  end

  def original_height
    @original_height ||= original_size[:height]
  end

  # w * ratio donnera la hauteur
  # h / ratio donnera la largeur
  def ratio
    @ratio ||= original_height.to_f / original_width
  end

  def original_size
    width, height = FastImage.size(path)
    {width: width, height: height}
  end

  def actual_left;  left  || 0 end
  def actual_right; right || 0 end

  # Width expected
  def width
    @width ||= data[:width] && data[:width].to_pps(pdf.bounds.width)
  end

  # Heigh expected
  def height
    @height ||= data[:height] && data[:height].to_pps(pdf.bounds.height)
  end

  def vadjust
    @vadjust ||= data[:vadjust]
  end

  def left
    @left ||= begin
      data[:left].to_pps if data.key?(:left)
    end || 0
  end

  def right
    @right ||= begin
      data[:right].to_pps if data.key?(:right)
    end
  end

  def scale
    @scale ||= data[:scale]
  end

  def legend
    @legend ||= data[:legend] || data[:legende]
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
