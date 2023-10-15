module Prawn4book
class Pages
  PAGE_FAKED_LENGTH = 500000
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
      add_notice(MESSAGES[:biblio][:no_occurrence] % [biblio.title])
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
    # Si une méthode est à appeler avant de commencer, il faut
    # l'appeler
    # 
    if biblio.method_pre_building
      biblio.send(biblio.method_pre_building)
    end

    # 
    # Inscription du TITRE DE LA BIBLIOGRAPHIE
    # 
    ititre = PdfBook::NTitre.new(book, text:biblio.title, level:biblio.title_level)
    ititre.print(pdf)
    # 
    # Application de la fonte
    # 
    bib_font  = Fonte.new(name:font_name, size:font_size, style: font_style)
    pdf.font(bib_font)
    # - Calcul du leading à utiliser -
    leading   = bib_font.leading(pdf, pdf.line_height)
    # 
    # Les options à appliquer
    # 
    options = {inline_format: true, leading: leading}
    #
    # Page de départ
    # 
    page_number_at_start = pdf.page_number
    if book.pages[page_number_at_start].nil?
      # puts "La page du lexique n'est pas connue.".rouge
      book.add_page(page_number_at_start) # impossible, normalement
    end
    if book.pages[page_number_at_start][:content_length] == 0
      # On met toujours une valeur, car si le texte est écrit 
      # directement dans le livre, on ne peut pas connaitre la
      # longueur de texte ajouté.
      # -- valeur fictive --
      book.pages[page_number_at_start][:content_length] = PAGE_FAKED_LENGTH
    end
    if book.pages[page_number_at_start][:first_par].nil?
      book.pages[page_number_at_start][:first_par] = 1
    end
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
        raise FatalPrawnForBookError.new(740, **{method: "#{item_formatage_method.name}", err: e.message, err_class: "#{e.class}"})
      end
      unless str.nil?
        #
        # Si le texte n'a pas été écrit directement dans le 
        # livre
        # 
        pdf.text(str, **options)
        if  book.pages[page_number_at_start][:content_length] == PAGE_FAKED_LENGTH
          # -- valeur fictive retirée --
          book.pages[page_number_at_start][:content_length] = 0
        end
        book.pages[page_number_at_start][:content_length] += str.length
        pdf.move_down(4)
      end
    end
  end

end #/class Bibliography
end #/class Pages

class Bibliography
  def self.default_formate_method(bibitem, pdf)
    spy "Je dois imprimer l'item #{bibitem.title} avec la méthode par défaut des bibliographies.".jaune
    "#{bibitem.title} : #{bibitem.occurrences_pretty_list}."
  end
end
end #/module Prawn4book
