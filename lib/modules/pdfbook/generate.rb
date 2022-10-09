module Prawn4book
class PdfBook


  ##
  # = main =
  # 
  # Méthode principale pour générer le PDF du livre
  #
  # Rappel : PdfFile hérite de Prawn::Document
  # 
  def generate_pdf_book
    clear
    File.delete(pdf_path) if File.exist?(pdf_path)
    
    #
    # Au lieu d'un PdfFile héritant de Prawn::Document avec ses
    # propres méthodes, on pourrait utiliser :
    #     Prawn::Document.extensions << CustomsMethodsModule
    # L'avantage serait de pouvoir des méthodes à la volée, dans le
    # fichier recette.
    #
    if module_formatage?
      require_module_formatage
      PdfFile.extensions << PdfBookFormatageModule
    end

    #
    # On doit définir la configuration
    # C'est la propriété-méthode pdf_config qui s'en charge.
    # 
    PdfFile.generate(pdf_path, pdf_config) do |pdf|


      # 
      # DES CODES À ESSAYER
      # 
      if pdf.page_count == 4
        puts "pdf.page = #{pdf.page.inspect}"
        puts "pdf.page.margins = #{pdf.page.margins.inspect}"
        puts "pdf.bounds = #{pdf.bounds.inspect}"
        puts "pdf.bounds.top = #{pdf.bounds.top.inspect}"
        puts "pdf.bounds.width = #{pdf.bounds.width.inspect}"
        puts "pdf.bounds.absolute_bottom = #{pdf.bounds.absolute_bottom.inspect}"

        puts "pdf.page_count = #{pdf.page_count.inspect}"
        puts "pdf.page_number = #{pdf.page_number.inspect}"
        pdf.delete_page(2)
        puts "pdf.delete_page(2)"
        puts "pdf.page_count = #{pdf.page_count.inspect}"
        puts "pdf.page_number = #{pdf.page_number.inspect}"

        puts "pdf.x = #{pdf.x.inspect}"
        puts "pdf.y = #{pdf.y.inspect}"

        puts "pdf.width_of('Bonjour vous') = #{pdf.width_of('Bonjour vous').inspect}"

        # Apparemment pour se rendre sur une page
        # pdf.go_to_page <num page>

        # Apparemment pour marquer le nombre de pages :
        # pdf.number_pages '<page> <number>', page_filter: ..., start_count_at: ...

        # ?
        # pdf.page_match?(:all|:odd|:even, i)


        # Annotation ? 
        pdf.annotate(
          Rect: [0, 0, 10, 10],
          Subtype: :Text,
          Contents: 'Une annotation ?',
          # Type: :Bogus, # ?
        )
        rect = [10,10,20,20]
        content = "Avec text_annotation"
        pdf.text_annotation(rect, content, Open: true, Subtype: :Bogus)
        # Il y a aussi : pdf.link_annotation avec la propriété :Dest qui 
        # peut contenir 'home' (dans l'exemple)

        # À quoi correspond ?
        # pdf.add_dest 'candy', 'chocolate'
        # pdf.dests.data.size
      end

      # 
      # On définit les polices requises pour le livre
      # 
      # define_required_fonts(self.config[:fonts])
      pdf.define_required_fonts(book_fonts)
      #
      # Définition des numéros de page
      # 
      pdf.set_pages_numbers
      #
      # On se place toujours en haut de la page pour commencer
      #
      pdf.move_cursor_to_top_of_the_page

      interligne = recette[:interligne] # TODO : à mettre dans la recette

      # 
      # On boucle sur tous les paragraphes du fichier d'entrée
      # 
      # Note : chaque paragraphe est une instance de classe de
      # son type. Par exemple, les images sont des PdfBook::NImage,
      # les titres sont des PdfBook::NTitre, etc.
      # 
      # Note : 'with_index' permet juste de faire des essais
      # 
      inputfile.paragraphes.each_with_index do |paragraphe, idx|
        pdf.insert(paragraphe)
        break if pdf.page_number == 24
        pdf.move_down( paragraphe.margin_bottom )
      end
    end #/PdfFile.generate

    if File.exist?(pdf_path)
      puts "Le book PDF a été produit avec succès !".vert
      puts "(in #{pdf_path})".gris
    else
      puts "Malheureusement le book PDF ne semble pas avoir été produit.".rouge
    end
  end

  # --- Configuration Pdf Methods ---

  # @prop Configuration pour le second argument de la méthode
  # #generate de Prawn::Document (en fait PdfBook::PdfFile)
  # TODO : la composer en fonction de la recette du livre ou de la
  # collection
  def pdf_config
    @pdf_config ||= begin
      {
        page_size:          proceed_unit(get_config(:dimensions)),
        page_layout:        get_config(:layout),
        margin:             proceed_unit(get_config(:margin)),
        left_margin:        conf_margin(:left) ||conf_margin(:ext),
        right_margin:       conf_margin(:right)||conf_margin(:int),
        top_margin:         conf_margin(:top),
        bottom_margin:      conf_margin(:bot),
        background:         get_config(:background),
        default_leading:    get_config(:leading),
        optimize_objects:   get_config(:optimize_objects, true),
        compress:           get_config(:compress),
        # {Hash} Des variables (méta-propriété personnalisées)
        info:               get_config(:info),
        # Un fichier template
        template:           get_config(:template),
        # Pour créer le document sans créer de première page
        skip_page_creation: get_config(:skip_page_creation),
      }
    end
  end

  # Fontes utilisées dans le boucle (définies dans le fichier de
  # recette du livre ou de la collection)
  def book_fonts
    @book_fonts ||= begin
      if recette[:fonts].nil? && not(collection?)
        nil
      elsif recette[:fonts] == :collection
        collection.data[:fonts]
      else
        recette[:fonts]
      end
    end
  end

  def get_config(property, default_value = nil)
    if property == :dimensions
      puts "data du PdfBook : #{data.inspect}".bleu
      puts "data collection : #{collection.data.inspect}".mauve
    end
    pdoc = data[property] # défini par la recette du livre
    if pdoc.nil? || pdoc == :collection
      return (collection.data[property]||collection.data["book_#{property}".to_sym]) if collection?
    else
      return pdoc
    end
    return default_value
  end

  # Retourne la configuration du livre pour la marge +side+
  def conf_margin(side)
    @marges ||= data[:marges]
    mgs = if @marges.is_a?(Hash)
        proceed_unit(@marges[side])
      elsif @marges == :collection
        @marges_collection = collection.data[:book_marges]
        proceed_unit(@marges_collection[side])
      else
        @marges
      end
    proceed_unit(mgs)
  end

  # --- Formating Methods ---

  ##
  # Traitement du module de formatage propre au live s'il existe
  # 
  def require_module_formatage
    module_formatage_path && require(module_formatage_path)
  end
  def module_formatage?
    module_formatage_path && File.exist?(module_formatage_path)
  end
  def module_formatage_path
    @module_formatage_path ||= get_module_formatage
  end
  def get_module_formatage
    pth = File.join(folder, 'module_formatage.rb')
    return pth if File.exist?(pth)
    if collection?
      pth = File.join(collection.folder, 'module_formatage.rb')
      return pth if File.exist?(pth)
    end    
  end

  # Reçoit une valeur ou une liste de valeur avec des unités et
  # retourne la valeur correspondante en nombre grâce aux méthodes
  # de Prawn::Measurements
  def proceed_unit(foo)
    return if foo.nil?
    return foo if foo.is_a?(Integer) || foo.is_a?(Float)
    valeur_string_seule = foo.is_a?(String)
    foo = [foo] if valeur_string_seule
    foo = foo.map do |n|
      if n.is_a?(String)
        unite   = n[-2..-1]
        nombre  = n[0..-3].to_f
        nombre.send(unite.to_sym)
      else
        n
      end
    end

    if valeur_string_seule
      foo.first
    else
      foo
    end
  end

end #/class PdfBook
end #/module Prawn4book
