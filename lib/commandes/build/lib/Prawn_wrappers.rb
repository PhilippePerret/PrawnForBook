#
#  Prawn warppers
#  --------------
#
# Ces "warppers" permettent de connaitre précisément le contenu qui
# est ajoué aux pages.
# 
# De façon simple :
# 
#   Lorsque l'on appelle la méthode Prawn::Document#text pour ajouter
#   du texte, on appelle en vérité le wrapper de même nom défini ici
#   (avec les mêmes paramètres) qui enregistre la longueur de texte
#   dans la page courante puis appelle la méthode originale pour 
#   vraiment écrire dans le document PDF.
# 
# Ces wrappers existent pour les méthodes :
# 
#   Prawn::Document           #text
#   Prawn::Document           #draw_text
#   Prawn::Document           #image    (une image ajoute du contenu)
#   Prawn::Document           #formatted_text
#   Prawn::Document           #text_box
#   Prawn::Document           #formatted_text_box
#   Prawn::Table::Cell::Text  #draw_content
# 
# @notes
# 
#   - les titres (NTitre) ajoutent une propriété :is_title à true 
#     pour indiquer que ce sont des titres (ils ne sont pas comptabi-
#     lisés dans le contenu de la page)
# 

require 'prawn/table'
  class Prawn::Document
    
    def add_content_length_to_current_page(len)
      @pdfbook ||= Prawn4book::PdfBook.current
      @pdfbook.add_page(page_number) unless @pdfbook.pages[page_number]
      @pdfbook.pages[page_number][:content_length] += len
      @pdfbook.pages[page_number][:first_par] = 1 # sinon n'imprime pas le numéro
    end

    # #text utilise forcément formatted_text, donc c'est seulement
    # dans la seconde méthode qu'on regarde s'il faut ajouter du
    # contenu. Mais on garde quand même ce wrapper, au cas où, pour
    # l'avenir.
    alias_method :__real_text, :text
    def text(str, **params)
      __real_text(str, **params)
    end

    alias_method :__real_draw_text, :draw_text
    def draw_text(str, **params)
      # puts "-> draw_text".bleu
      add_content_length_to_current_page(str.to_s.length)
      __real_draw_text(str, **params)
    end
    alias_method :__real_formatted_text, :formatted_text
    def formatted_text(str, **params)
      # puts "-> formatted_text".bleu
      is_titre = params.delete(:is_title)
      add_content_length_to_current_page(str.to_s.length) unless is_titre
      __real_formatted_text(str, **params)
    end
    alias_method :__real_formatted_text_box, :formatted_text_box
    def formatted_text_box(str, **params)
      # puts "-> formatted_text_box".bleu
      add_content_length_to_current_page(str.to_s.length)
      __real_formatted_text_box(str, **params)
    end
    alias_method :__real_text_box, :text_box
    def text_box(str, **params)
      # puts "-> text_box".bleu
      add_content_length_to_current_page(str.to_s.length)
      __real_text_box(str, **params)
    end
    alias_method :__real_image, :image
    def image(ipath, **params)
      add_content_length_to_current_page(100)
      __real_image(ipath, **params)
    end
    # TODO IDEM AVEC : text_box, formatted_text,
    # formatted_text_box,
  end

  class Prawn::Table::Cell::Text
    alias_method :__real_draw_content, :draw_content
    def draw_content #(lines, **params, &block)
      # puts "On ajoute #{content.length} caractères dans la table : #{content.inspect}".bleu
      @pdf.add_content_length_to_current_page(content.length)
      __real_draw_content
      # super
    end
  end #/class Prawn::Table
