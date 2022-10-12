require_relative 'generate_building_methods'
require_relative 'PdfBook_helpers'
require_relative 'Tdm'

module Prawn4book
class PdfBook

  # Pour exposer les données des pages (à commencer par les
  # paragraphes)
  attr_reader :pages

  ##
  # = main =
  # 
  # Méthode principale pour générer le PDF du livre
  # Elle prépare le document Prawn::Document (PrawnDoc) et boucle
  # sur tous les paragraphes du texte pour les formater et les
  # ajouter.
  # 
  # Rappel : PrawnDoc hérite de Prawn::Document
  # 
  def generate_pdf_book
    clear
    File.delete(pdf_path) if File.exist?(pdf_path)

    # 
    # Si l'option '--force' a été ajoutée et que le fichier
    # texte.yaml existe, on le détruit après confirmation
    # 
    if CLI.option(:force) && File.exist?(inputfile.data_paragraphes_path)
      unless Q.no?("Es-tu certain de vouloir détruire le fichier 'texte.yaml' ?\nIl contient peut-être des informations précieuses sur le\ntraitement du texte…)".jaune)
        File.delete(inputfile.data_paragraphes_path)
      end
    end
    
    #
    # Au lieu d'un PrawnDoc héritant de Prawn::Document avec ses
    # propres méthodes, on pourrait utiliser :
    #     Prawn::Document.extensions << CustomsMethodsModule
    # L'avantage serait de pouvoir des méthodes à la volée, dans le
    # fichier recette.
    #
    if module_formatage?
      require_module_formatage
      PrawnDoc.extensions << PdfBookFormatageModule
    end

    # 
    # Parser personnalisé (if any)
    # 
    require_module_parser if module_parser?

    #
    # Pour consigner les informations sur les pages, à commencer
    # par les paragraphes (numéros) s'ils sont numérotés
    # 
    @pages = {}

    #
    # On doit définir la configuration
    # C'est la propriété-méthode pdf_config qui s'en charge.
    # 
    PrawnDoc.generate(pdf_path, pdf_config) do |pdf|

      #
      # Y a-t-il une dernière page définie en options
      # 
      if CLI.options[:last]
        pdf.last_page = CLI.options[:last].to_i
      end

      # 
      # On définit les polices requises pour le livre
      # 
      # define_required_fonts(self.config[:fonts])
      pdf.define_required_fonts(book_fonts)

      # 
      # Initier une première page, si on a demandé de la sauter
      # au départ (on le demande pour qu'elle prennen en compte les
      # définitions de marge, etc.)
      # 
      pdf.start_new_page if skip_page_creation?

      #
      # Initier la table des matières (je préfère faire mon 
      # instance plutôt que d'utiliser l'outline de Prawn)
      # 
      tdm = PdfBook::Tdm.new(self, pdf)
      pdf.tdm = tdm


      pdf.start_new_page if page_de_garde?

      pdf.build_faux_titre(self) if page_faux_titre?
        
      pdf.build_page_de_titre(self) if page_de_titre?


      if table_des_matieres?

        # Pour savoir sur quelle page construire la table des
        # matière
        on_page = pdf.page_number
        pdf.font "Nunito", size: 20 # TODO À régler
        pdf.text "Table des matières"

        pdf.start_new_page

        pdf.start_new_page

      end

      # 
      # Pour commencer sur la belle page, on doit toujours ajouter
      # une page blanche
      # 
      pdf.start_new_page

      #
      # On se place toujours en haut de la page pour commencer
      #
      # pdf.move_cursor_to_top_of_the_page

      # interligne = recette[:interligne]

      # 
      # BOUCLE SUR TOUS LES PARAGRAPHES
      # ===============================
      # 
      # On boucle sur tous les paragraphes du fichier d'entrée
      # 
      # Note : chaque paragraphe est une instance de classe de
      # son type. Par exemple, les images sont des PdfBook::NImage,
      # les titres sont des PdfBook::NTitre, etc.
      # 
      # Note : 'with_index' permet juste de faire des essais
      # 
      green_point = '.'.vert
      clear
      suivi = 'Écriture du paragraphe #%{num}…'.vert
      inputfile.paragraphes.each_with_index do |paragraphe, idx|

        # STDOUT.write green_point

        paragraphe.page_numero = pdf.page_number

        if module_parser? && paragraphe.paragraph?
          __paragraph_parser(paragraphe)
        end

        pdf.insert(paragraphe)

        # On peut indiquer les pages sur lesquelles est inscrit le
        # paragraphe
        if paragraphe.paragraph?
          # 
          # Pour suivre le travail
          # 
          # write_at(suivi % {num: paragraphe.numero}, 0, 0)
          STDOUT.write green_point

          @pages[paragraphe.first_page] || begin
            @pages.merge!(paragraphe.first_page => {first_par:paragraphe.numero, last_par:nil})
          end
          @pages[paragraphe.last_page] || begin
            @pages.merge!(paragraphe.last_page => {first_par:paragraphe.numero, last_par:nil})
          end
          # On le met toujours en dernier paragraphe de sa première page
          @pages[paragraphe.first_page][:last_par] = paragraphe.numero
        end

        
        break if pdf.page_number === pdf.last_page
        
        if paragraphe.margin_bottom.nil?
          raise "Problème avec margin_bottom de : #{paragraphe.inspect}"
        end

        pdf.move_down( paragraphe.margin_bottom )

      end

      #
      # Écriture des pages supplémentaires obtenues par le 
      # parser, if any
      # 
      if module_parser?
        extend PrawnCustomBuilderModule
        __custom_builder(pdf)
      end

      # 
      # - Page infos ? -
      # 
      pdf.build_page_infos(self) if recette.page_info?

      # 
      # - TABLE DES MATIÈRES -
      # 
      tdm.output(on_page) if table_des_matieres?

      #
      # - PAGINATION -
      # 
      # Écriture des numéros de page ou numéros de paragraphes
      # En bas de toutes les pages qui le nécessitent.
      # 
      pdf.set_pages_numbers(@pages)


      if ParserParagraphModule.respond_to?(:report)
        ParserParagraphModule.report
      end

    end #/PrawnDoc.generate

    if File.exist?(pdf_path)
      puts "Le book PDF a été produit avec succès !".vert
      puts "(in #{pdf_path})".gris
      puts "\n"      
      open_book if CLI.option(:open)
    else
      puts "Malheureusement le book PDF ne semble pas avoir été produit.".rouge
    end
  end

  # --- Predicate Methods ---

  def table_des_matieres?     ;recette.table_of_content?    end
  def skip_page_creation?     ;recette.skip_page_creation?  end
  def page_de_garde?          ;recette.page_de_garde?       end
  def page_faux_titre?        ;recette.page_faux_titre?     end
  def page_de_titre?          ;recette.page_de_titre?       end

  # --- Configuration Pdf Methods ---

  # @prop Configuration pour le second argument de la méthode
  # #generate de Prawn::Document (en fait PdfBook::PrawnDoc)
  # TODO : la composer en fonction de la recette du livre ou de la
  # collection
  def pdf_config
    @pdf_config ||= begin
      {
        page_size:          proceed_unit(get_recipe(:dimensions)),
        page_layout:        get_recipe(:layout, :portrait),
        margin:             proceed_unit(get_recipe(:margin)),
        left_margin:        conf_margin(:left) ||conf_margin(:ext),
        right_margin:       conf_margin(:right)||conf_margin(:int),
        top_margin:         conf_margin(:top),
        bottom_margin:      conf_margin(:bot),
        background:         get_recipe(:background),
        default_leading:    get_recipe(:leading),
        optimize_objects:   get_recipe(:optimize_objects, true),
        compress:           get_recipe(:compress),
        # {Hash} Des variables (méta-propriété personnalisées)
        # (:title, :author, etc.)
        info:               get_recipe(:info),
        # Un fichier template
        template:           get_recipe(:template),
        text_formatter:     nil, # ?
      }
    end
  end

  # Fontes utilisées dans le boucle (définies dans le fichier de
  # recette du livre ou de la collection)
  def book_fonts
    @book_fonts ||= recette[:fonts]
  end

  def get_recipe(property, default_value = nil)
    recette[property] || default_value
  end

  # Retourne la configuration du livre pour la marge +side+
  def conf_margin(side)
    @marges ||= recette[:marges]
    mgs = 
      if @marges.is_a?(Hash)
        @marges[side]
      else
        @marges
      end
    proceed_unit(mgs)
  end


  # --- Formating Methods ---

  ##
  # Traitement du module de formatage propre au livre s'il existe
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
    if collection?
      pth = File.join(collection.folder, 'formater.rb')
      return pth if File.exist?(pth)
    end    
    pth = File.join(folder, 'formater.rb')
    return pth if File.exist?(pth)
  end

  # Parser propre au livre
  def module_parser?
    module_parser_path && File.exist?(module_parser_path)
  end
  def require_module_parser
    require module_parser_path
    extend ParserParagraphModule
  end
  def module_parser_path
    @module_parser_path ||= get_module_parser_path
  end
  def get_module_parser_path
    if collection?
      pth = File.join(collection.folder, 'parser.rb')
      return pth if File.exist?(pth)
    end    
    pth = File.join(folder, 'parser.rb')
    return pth if File.exist?(pth)    
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
