module Prawn4book
class Command
  def proceed
    PdfBook.current.generate_pdf_book
  end
end #/Command
class PdfBook

  # Pour exposer les données des pages (à commencer par les
  # paragraphes)
  attr_reader :pages

  # @prop Instance {Prawn4book::PdfHelpers}
  attr_reader :pdfhelpers

  ##
  # = main =
  # 
  # Méthode principale pour générer le PDF du livre
  # Elle prépare le document Prawn::View (PrawnView) et boucle
  # sur tous les paragraphes du texte pour les formater et les
  # ajouter au PDF en les parsant/helpant/formatant.
  # 
  # Rappel : PrawnView hérite de Prawn::View (comme conseillé par
  #          le code de Prawn)
  # 
  def generate_pdf_book
    clear unless debug?
    
    # 
    # Détruire le fichier PDF final s'il existe déjà
    # 
    File.delete(pdf_path) if File.exist?(pdf_path)

    # 
    # Si l'option '--force' a été ajoutée et que le fichier
    # texte.yaml existe, on le détruit après confirmation
    # @DEPRECATED Maintenant, on ne compte plus faire un fichier
    # texte.yaml, on compte ajouter des marques au fichier texte
    # du livre (texte.p4b.md/txt)
    # L'option '--force' (si on ne change pas son nom) permettra
    # donc d'ignorer ces précisions dans les paragraphes.
    # 
    if CLI.option(:force) && File.exist?(inputfile.data_paragraphes_path)
      unless Q.no?("Es-tu certain de vouloir détruire le fichier 'texte.yaml' ?\nIl contient peut-être des informations précieuses sur le\ntraitement du texte…)".jaune)
        File.delete(inputfile.data_paragraphes_path)
      end
    end

    #
    # Avec Prawn::View au lieu d'étendre Prawn::Document
    # 
    pdf = PrawnView.new(self, pdf_config)

    
    #
    # S'il existe un module de formatage propre au livre (ou à la
    # collection) il faut le charger.
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
    # Helpers personnalisées (if any)
    # 
    require_modules_helpers(pdf) if module_helpers?

    #
    # Pour consigner les informations sur les pages, à commencer
    # par les paragraphes (numéros) s'ils sont numérotés
    # 
    @pages = {}

    # 
    # On définit les polices requises pour le livre
    # 
    # define_required_fonts(self.config[:fonts])
    pdf.define_required_fonts(book_fonts)

    #
    # Y a-t-il une dernière page définie en options
    # 
    pdf.last_page = CLI.options[:last].to_i if CLI.options[:last]

    # 
    # Initier une première page, si on a demandé de la sauter
    # au départ (on le demande pour qu'elle prennen en compte les
    # définitions de marge, etc.)
    # 
    pdf.start_new_page if skip_page_creation?

    # # 
    # # Calcul de la table de références (pour les lignes de référence)
    # # 
    # pdf.table_reference_grid

    # # 
    # # Calcul de leading par défaut 
    # # 
    # pdf.define_default_leading

    #
    # Initier la table des matières (je préfère faire mon 
    # instance plutôt que d'utiliser l'outline de Prawn)
    # 
    tdm = PdfBook::Tdm.new(self, pdf)
    pdf.tdm = tdm


    pdf.start_new_page if page_de_garde?


    pdf.build_faux_titre if page_faux_titre?
      
    pdf.build_page_de_titre if page_de_titre?


    pdf.build_table_des_matieres if table_des_matieres?

    # 
    # Pour commencer sur la belle page, on doit toujours ajouter
    # une page blanche
    # 
    pdf.start_new_page

    # 
    # ========================
    # - TOUS LES PARAGRAPHES -
    # ========================
    # 
    # cf. modules/pdfbook/generate_builder/paragraphes.rb
    # 
    pdf.print_paragraphs(inputfile.paragraphes)

    #
    # - PAGES SUPPLÉMENTAIRES -
    # 
    # Note : la page d'index s'appelle directement dans le
    # texte par la marque '(( index ))'
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
    pdf.build_page_infos if recette.page_info?

    # 
    # - TABLE DES MATIÈRES -
    # 
    tdm.output(pdf.tdm_page) if table_des_matieres?

    #
    # - PAGINATION -
    # 
    # Écriture des numéros de page ou numéros de paragraphes
    # En bas de toutes les pages qui le nécessitent.
    # 
    pdf.set_pages_numbers(@pages)


    if module_parser? && ParserParagraphModule.respond_to?(:report)
      ParserParagraphModule.report
    end

    # end #/PrawnDoc.generate
    pdf.save_as(pdf_path)

    if File.exist?(pdf_path)
      puts "\n\nLe book PDF a été produit avec succès !".vert
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
        # --- Extra definitions ---
        default_font:       get_recipe(:default_font),
        default_font_size:  get_recipe(:default_font_size),
        default_font_style: get_recipe(:default_font_style, :normal),
        # default_baseline:  get_recipe(:default_baseline),
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

  # TODO: Mettre ces deux méthode dans Prawn4book::PdfHelper pour
  # appeler une bonne fois pour toutes les fichiers candidats
  def require_modules_helpers(pdf)
    @pdfhelpers = PdfHelpers.create_instance(self, pdf)
  end
  def module_helpers?
    PdfHelpers.modules_helpers?(self)
  end

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
