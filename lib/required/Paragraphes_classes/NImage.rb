require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class NImage < AnyParagraph

  attr_reader :data
  attr_accessor :page_numero

  def initialize(pdfbook, data)
    super(pdfbook)
    dispatch_style(data[:style]) if data.key?(:style)
    @data = data.merge!(type: 'image')
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
        image = image(img_path, dimage)
        # 
        # Hauteur prise par l'image
        # 
        image_height = image.scaled_height
        move_down(line_height + image_height)
      end
      # move_down(image_height + mg_bottom)
      # 
      # On saute toujours deux lignes
      # 
      move_down(line_height * 2)
      # text "Le curseur est à #{cursor.inspect}"
    end
    
  end #/print

  # --- Functional Methods ---

  def dispatch_style(style)
    style.split(';').each do |propval|
      prop, val = propval.split(':').map{|n|n.strip}
      self.instance_variable_set("@#{prop}", val)
    end
  end

  def pourcent_to_real_value(value, pdf)
    # 
    # Vérifier les valeurs en %
    # 
    if value.end_with?('%')
      pct = value[0...-1].strip.to_i
      value = (pdf.bounds.width * pct).to_f / 100
      # puts "new value = #{value}"
      # puts "pdf.width = #{pdf.bounds.width.inspect}"
      # puts "87mmm = #{87.mm}"
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
