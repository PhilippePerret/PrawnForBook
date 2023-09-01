module Prawn4book
class Pages
class Bibliography

  # = main =
  #
  # Méthode principale construisant la/les page/s de bibliographie
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
    # Méthode formatage à utiliser pour les items de bibliographie
    # 
    item_formatage_method = 
      if biblio.custom_formating_method_for_biblio?
        biblio.method(biblio.custom_format_method_for_biblio)
      else
        Prawn4book::Bibliography.method(:default_formate_method)
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
      # str = Prawn4book::Bibliography.send(formate_method, bibitem)
      begin
        #
        # C'est peut-être une méthode utilisateur qui est utilisée
        # ici, il faut donc s'attendre au pire. On la protège.
        # 
        str = item_formatage_method.call(bibitem, pdf)
        # La méthode peut retourner nil si le code a été écrit 
        # directement dans le document pdf.
      rescue Exception => e
        raise FatalPrawForBookError.new(740, **{method: "#{item_formatage_method.name}", err: e.message, err_class: "#{e.class}"})
      end
      pdf.text(str, **options) unless str.nil?
      pdf.move_down(4)
    end
  end

end #/class Bibliography
end #/class Pages

class Bibliography
  def self.default_formate_method(bibitem, pdf)
    spy "Je dois imprimer l'item #{bibitem.title} avec la méthode par défaut des bibliographies.".jaune
    "#{bibitem.title} : #{bibitem.occurences_pretty_list}."
  end
end
end #/module Prawn4book
