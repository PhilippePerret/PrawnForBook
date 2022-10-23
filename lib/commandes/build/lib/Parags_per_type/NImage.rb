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
    # Redimensionnement de l'image
    # 
    ratio_h = 1 # à appliquer à la hauteur si dimensions changées
    if width
      dimage.merge!(width: width)
      if margin_left_raw.to_s.end_with?('%')
        ratio_h = round(margin_left_raw[0..-2].to_f / 100)
      end
    end

    # 
    # Positionnement de l'image
    # 
    dimage.merge!(at: [margin_left, pdf.cursor - margin_top])
    # box_width = pdf.bounds.width - (margin_left + margin_right)
    # boite = [margin_left, pdf.cursor]
    
    # 
    # Propriété à sortir (pour le scope dans pdf)
    # 
    image_is_svg = svg?
    img_path = path
    mg_bottom = margin_bottom

    pdf.update do
      # bounding_box(boite, width:box_width, height: 100) do
        if image_is_svg
          dimage.merge!(color_mode: :cmyk)
          image = svg(IO.read(img_path), dimage)
          # 
          # Hauteur prise par l'image
          # 
          image_height = image[:height] * ratio_h
        else
          image = image(img_path, dimage)
          # 
          # Hauteur prise par l'image
          # 
          image_height = image.scaled_height
        end

        move_down(image_height + mg_bottom + line_height)
      end
    # end #/bounding_box
  end #/pdf

end #/class NImage
end #/class PdfBook
end #/class Prawn4book
