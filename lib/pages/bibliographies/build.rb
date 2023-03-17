module Prawn4book
class Pages
class Bibliography

  # = main =
  #
  # Méthode principale construisant la page
  # 
  def build(pdf)
    # 
    # Si aucun item n'a été collecté, on n'inscrit pas cette
    # bibliographie
    # 
    if empty?
      spy "Aucun item bibliographique pour #{biblio.title.inspect}".orange
      puts (MESSAGES[:biblio][:no_occurrence] % [biblio.title]).orange
      return
    end
    # 
    # Inscription du TITRE DE LA BIBLIOGRAPHIE
    # 
    ititre = PdfBook::NTitre.new(book, text:biblio.title, level:biblio.title_level)
    ititre.print(pdf)
    # 
    # Application de la fonte
    # 
    font_props = {size: font_size}
    font_props.merge!(style: font_style) if font_style
    pdf.font(font_name, **font_props)
    # 
    # Calcul du leading à utiliser
    # 
    bib_font = Fonte.new(font_name, **{size:font_size, style: font_style})
    leading = pdf.font2leading(bib_font, font_size, pdf.line_height)
    # leading = 0
    # 
    # Les options à appliquer
    # 
    options = {inline_format: true, leading: leading}
    # 
    # On écrit tous les items de cette bibliographie
    # 
    biblio.items.values.sort_by do |bibitem|
      # - Classement des items -
      bibitem.keysort
    end.each do |bibitem|
      ##############################
      ###                        ###
      ### - Écriture des items - ###
      ###                        ###
      ##############################
      pdf.move_cursor_to_next_reference_line
      str = Prawn4book::Bibliography.send(formate_method, bibitem)
      pdf.text "#{str} : #{bibitem.occurrences_as_displayed_list}.", **options
      pdf.move_down(4)
    end
  end

end #/class Bibliography
end #/class Pages

class Bibliography
  def self.default_formate_method(bibitem)
    spy "Je dois imprimer l'item #{bibitem.title} avec la méthode par défaut des bibliographies.".jaune
    bibitem.title
  end
end
end #/module Prawn4book
