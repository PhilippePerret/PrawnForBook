require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class NImage < AnyParagraph

  # @public
  # 
  # Méthode qui parse le code contenu à l'intérieur d'un IMAGE[...]
  # dans le fichier source.
  # @note : ce code doit se trouve seul sur une ligne
  # 
  # @param dimg [String] Intérieur de IMAGE[...]
  # 
  # @return [Hash] Les données pour l'image
  def self.parse(dimg)
    case dimg
    when /^\{(.+)\}$/.freeze
      eval($1)
    when /\|/.freeze
      path, props = dimg.split('|').map {|s| s.strip }
      h = props.split(';').each { |p| k, v = p.split(':'); h.merge!(k.to_sym => v) }
      h.merge!(path: path)
    else
      {path: dim}
    end
  end

  def initialize(book:, data_str:, pindex:)
    super(book, pindex)
    @type = 'image'
    @data = NImage.parse(data_str)
  end


  # --- Printer Methods ---

  ##
  # Méthode principale qui "imprime" le paragraphe dans le PDF
  # du livre
  # 
  def print(pdf)
    @pdf = pdf
    dimage = {}

    # 
    # Il faut mettre le style par défaut
    # 
    # pdf.font(pdf.default_font_name, **{style:pdf.default_font_style, size:pdf.default_font_size})
    pdf.font(Fonte.default_fonte, **{size:pdf.default_font_size})

    #
    # Redimensionnement de l'image
    # 
    if width
      real_width = pourcent_to_real_value(width, pdf)
      dimage.merge!(width: real_width)
      if margin_left_raw.to_s.end_with?('%')
      end
    end

    # 
    # Positionnement de l'image
    # 
    dimage.merge!(at: [margin_left, pdf.cursor])
    
    # 
    # Propriété à sortir (pour le scope dans pdf)
    # 
    image_is_svg = svg?
    img_path = path
    # mg_bottom = margin_bottom

    pdf.update do
      # 
      # On passe toujours à la ligne
      # TODO : non, pas quand l'image occupe toute la page
      # 
      move_down(line_height)

      if image_is_svg
        dimage.merge!(color_mode: :cmyk)

        #
        # Pour le moment, je ne sais pas gérer la rotation,
        # il faut tourner l’image d’origine et mettre la
        # bonne largeur/hauteur
        # 
        image = svg(IO.read(img_path), dimage)

        # 
        # Hauteur prise par l'image
        # 
        image_height = image[:height]
      else
        image = image(img_path, **dimage)
        # 
        # Hauteur prise par l'image
        # 
        image_height = image.scaled_height
        move_down(line_height + image_height)
      end
      # move_down(image_height + mg_bottom)
      # 
      # On saute toujours deux lignes
      # TODO : Non, pas quand l'image prend toute la page, comme
      # un paradigme de Field par exemple
      # 
      move_down(line_height * 2)
      # text "Le curseur est à #{cursor.inspect}"
    end
    
  end #/print

  # --- Functional Methods ---

  def pourcent_to_real_value(value, pdf)
    # 
    # Vérifier les valeurs en %
    # 
    if value.end_with?('%')
      pct = value[0...-1].strip.to_i
      value = (pdf.bounds.width * pct).to_f / 100
    end
    return value
  end


  # --- Predicate Methods ---

  def paragraph?; false end

  def svg?
    :TRUE == @issvg ||= true_or_false(extname == '.svg')
  end

  # 
  def extname
    @extname ||= File.extname(filename)
  end

  def filename
    @filename ||= data[:path]
  end

  def path
    @path ||= PdfBook.current.image_path(filename)
  end

end #/class NImage
end #/class PdfBook
end #/module Prawn4book
