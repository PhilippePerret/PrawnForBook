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
  # Elle prépare le document Prawn::Document (PdfFile) et boucle
  # sur tous les paragraphes du texte pour les formater et les
  # ajouter.
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
    # Pour consigner les informations sur les pages, à commencer
    # par les paragraphes (numéros) s'ils sont numérotés
    # 
    @pages = {}

    #
    # On doit définir la configuration
    # C'est la propriété-méthode pdf_config qui s'en charge.
    # 
    PdfFile.generate(pdf_path, pdf_config) do |pdf|

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

      pdf.build_faux_titre(self) if faux_titre?
        
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
      inputfile.paragraphes.each_with_index do |paragraphe, idx|

        pdf.insert(paragraphe)

        # On peut indiquer les pages sur lesquelles est inscrit le
        # paragraphe
        if paragraphe.paragraph?
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
        
        pdf.move_down( paragraphe.margin_bottom )
      end

      # puts "pages : #{@pages.pretty_inspect}"


      # 
      # Écriture de la table des matières
      # 
      tdm.output(on_page)

      #
      # Définition des numéros de page ou numéros de paragraphes
      # 
      pdf.set_pages_numbers(@pages)


    end #/PdfFile.generate

    if File.exist?(pdf_path)
      puts "Le book PDF a été produit avec succès !".vert
      puts "(in #{pdf_path})".gris
    else
      puts "Malheureusement le book PDF ne semble pas avoir été produit.".rouge
    end
  end


  # --- Predicate Methods ---

  def table_des_matieres?
    pdf_config[:table_of_content] === true
  end
  def skip_page_creation?
    pdf_config[:skip_page_creation] === true
  end

  def page_de_garde?
    pdf_config[:page_de_garde] === true
  end

  # @return true s'il faut un faux titre
  # Rappel : le "faux-titre" est la première page imprimée du livre,
  # après la page de garde, qui contient JUSTE le titre du livre. 
  # Elle ne doit pas être confondu avec la "page de titre" qui 
  # contient les informations générales sur le livre.
  def faux_titre?
    pdf_config[:faux_titre] === true
  end

  def page_de_titre?
    pdf_config[:page_de_titre] === true
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
        page_layout:        get_config(:layout, :portrait),
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
        # (:title, :author, etc.)
        info:               get_config(:info),
        # Un fichier template
        template:           get_config(:template),
        text_formatter:     nil, # ?
        # Pour créer le document sans créer de première page
        skip_page_creation: get_config(:skip_page_creation, true),
        # --- Options propres à Praw4Book ---
        table_of_content:   get_config(:table_of_content, true),
        page_de_garde:      get_config(:page_de_garde, true),
        page_de_titre:      get_config(:page_titre, true),
        faux_titre:         get_config(:faux_titre, false),
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
    # if property == :dimensions
    #   puts "data du PdfBook : #{data.inspect}".bleu
    #   puts "data collection : #{collection.data.inspect}".mauve
    # end
    pdoc = data[property] || default_value # défini par la recette du livre
    if pdoc == :collection
      return (collection.data[property]||collection.data["book_#{property}".to_sym]) if collection?
    else
      return pdoc
    end
  end

  # Retourne la configuration du livre pour la marge +side+
  def conf_margin(side)
    @marges ||= data[:marges]
    mgs = if @marges.is_a?(Hash)
        proceed_unit(@marges[side])
      elsif @marges == :collection
        @marges_collection = collection.data[:marges]
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
