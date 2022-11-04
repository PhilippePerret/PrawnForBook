=begin

  D'autres méthode de PdfBook peuvent être trouvées dans le 
  module général ainsi que dans le module build.rb de cette 
  commande.

  Les méthodes ci-dessous sont utilisées pour la construction du
  livre, pour accélérer les calculs très souvent.

=end
module Prawn4book
class PdfBook

  # --- Numérotation Paragraphes ---

  def num_parag_font
    @num_parag_font ||= num_parag_data[:font]
  end

  def num_parag_font_size
    @num_parag_font_size ||= num_parag_data[:font_size]
  end

  def num_parag_data
    @num_parag_data ||= begin
      tbl = recipe.get(:num_parag, {})
      tbl.key?(:font) || tbl.merge!(font: font_or_default("Bangla"))
      tbl.key?(:font_size) || tbl.merge!(font_size: 7)
      tbl
    end
  end


  # --- Predicate Methods ---

  def skip_page_creation?  ;recette.skip_page_creation?  end
  def page_de_garde?       ;recette.page_de_garde?       end
  def page_faux_titre?     ;recette.page_faux_titre?     end
  def page_de_titre?       ;recette.page_de_titre?       end

  # --- Configuration Pdf Methods ---

  # @prop Configuration pour le second argument de la méthode
  # #generate de Prawn::View (en fait PdfBook::PrawnView)
  # TODO : la composer en fonction de la recette du livre ou de la
  # collection
  def pdf_config
    @pdf_config ||= begin
      {
        skip_page_creation: skip_page_creation?,
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
