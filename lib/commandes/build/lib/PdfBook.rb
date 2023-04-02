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
    @num_parag_font ||= recipe.parag_num_font_name
  end

  def num_parag_font_size
    @num_parag_font_size ||= recipe.parag_num_font_size
  end

  # --- Predicate Methods (shortcuts) ---

  def skip_page_creation?   ;recette.skip_page_creation?  end
  def page_de_garde?        ;recette.page_de_garde?       end
  def page_faux_titre?      ;recette.page_faux_titre?     end
  def page_de_titre?        ;recette.page_de_titre?       end
  def page_infos?           ;recette.page_infos?          end
  def page_number?          ;recette.page_number?         end

  # --- Configuration Pdf Methods ---

  # @return [Hash] La configuration qui sert de second argument pour 
  # la méthode #generate de Prawn::View (en fait PdfBook::PrawnView)
  # Donc il ne faut pas y mettre n'importe quoi, mais seulement les
  # valeurs attendues par la méthode, qu'on peut trouver ici :
  #   https://prawnpdf.org/api-docs/2.3.0/Prawn/Document.html#generate-class_method
  #   (chercher VALID_OPTIONS)
  def pdf_config
    @pdf_config ||= begin
      {
        # Options qu'on trouve dans [1]
        skip_page_creation: skip_page_creation?,
        page_size:          proceed_unit(recipe.dimensions), # p.e. "a4"
        page_layout:        recipe.book_format[:book][:orientation].to_sym,
        margin:             conf_margin(:top),
        left_margin:        conf_margin(:ext),
        right_margin:       conf_margin(:int),
        ext_margin:         conf_margin(:ext),
        int_margin:         conf_margin(:int),
        top_margin:         conf_margin(:top),
        bot_margin:         conf_margin(:bot),
        compress:           get_recipe(:compress),
        background:         get_recipe(:background),
        info:               nil, # ?
        text_formatter:     nil, # ?
        print_scaling:      nil, # ?
        # Autres options
        default_leading:    recipe.book_format[:text][:interligne],
        optimize_objects:   get_recipe(:optimize_objects, true),
        infos:              recipe.page_infos,
        template:           get_recipe(:template, nil),
        # --- Extra definitions ---
        default_font:       recipe.default_font,
        default_font_and_style:  recipe.default_font_and_style,
        default_font_size:  recipe.default_font_size,
      }.tap do |h|
        spy "options pour #generate : #{h.pretty_inspect}"
      end
    end
  end

  # Fontes utilisées dans le boucle (définies dans le fichier de
  # recette du livre ou de la collection)
  def book_fonts
    @book_fonts ||= recipe.fonts_data
  end

  def get_recipe(property, default_value = nil)
    recette[property] || default_value
  end

  # Retourne la configuration du livre pour la marge +side+
  def conf_margin(side)
    proceed_unit(recipe.book_format[:page][:margins][side])
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
    module_formatage_paths.each do |md| require(md) end
  end
  def module_formatage?
    not(module_formatage_paths.empty?)
  end
  def module_formatage_paths
    @module_formatage_paths ||= get_modules_formatage
  end
  ##
  # On relève les modules de formatage (de la collection — if any —
  # et du livre). Ce sont les modules formater.rb
  def get_modules_formatage
    mds = []
    if in_collection?
      pth = File.join(collection.folder, 'formater.rb')
      mds << pth if File.exist?(pth)
    end    
    pth = File.join(folder, 'formater.rb')
    mds << pth if File.exist?(pth)
    return mds
  end

  # Parser propre au livre
  def module_parser?
    not(module_parser_paths.empty?)
  end
  def require_module_parser
    spy "Chargement des parsers/formaters".jaune, true
    module_parser_paths.each { |md| require md }
    extend ParserParagraphModule
    # self.class.current = self
    spy "self respond to :parser_formater ? #{PdfBook.current.respond_to?(:parser_formater).inspect}".bleu,true
    spy "Fin des chargements des parsers/formaters".jaune,true
  end
  def module_parser_paths
    @module_parser_paths ||= get_module_parser_paths
  end
  def get_module_parser_paths
    mds = []
    if in_collection?
      pth = File.join(collection.folder, 'parser.rb')
      mds << pth if File.exist?(pth)
    end    
    pth = File.join(folder, 'parser.rb')
    mds << pth if File.exist?(pth)
    return mds
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
        if n.numeric?
          n.to_f
        else
          unite   = n[-2..-1]
          nombre  = n[0..-3].to_f
          nombre.send(unite.to_sym)
        end
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
