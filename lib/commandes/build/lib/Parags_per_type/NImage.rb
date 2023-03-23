module Prawn4book
class PdfBook
class NImage < AnyParagraph


  # --- Helpers Methods ---

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
    pdf.font(pdf.default_fonte, **{size:pdf.default_font_size})

    #
    # Redimensionnement de l'image
    # 
    ratio_h = 1 # à appliquer à la hauteur si dimensions changées
    if width
      real_width = pourcent_to_real_value(width, pdf)
      dimage.merge!(width: real_width)
      if margin_left_raw.to_s.end_with?('%')
        ratio_h = round(margin_left_raw[0..-2].to_f / 100)
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
    mg_bottom = margin_bottom

    pdf.update do
      # 
      # On saute toujours une ligne
      # 
      move_down(line_height)

      if image_is_svg
        dimage.merge!(color_mode: :cmyk)
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

end #/class NImage
end #/class PdfBook
end #/class Prawn4book
