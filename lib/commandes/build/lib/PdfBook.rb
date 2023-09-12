=begin

  D'autres méthode de PdfBook peuvent être trouvées dans le 
  module général ainsi que dans le module build.rb de cette 
  commande.

  Les méthodes ci-dessous sont utilisées pour la construction du
  livre, pour accélérer les calculs très souvent.

=end
module Prawn4book
class PdfBook

  alias :recipe :recette
  
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


  # --- Modules personnalisés ---
   
  def custom_modules_prawn4book
    get_custom_modules('prawn4book')
  end

  # --- Formating Methods ---

  def custom_formater_paths
    get_custom_modules('formater')
  end

  def custom_parser_paths
    get_custom_modules('parser')
  end

  def custom_helper_paths
    get_custom_modules('helper') + get_custom_modules('helpers')
  end
  ##

  ##
  # @return [Array<String>] Liste des modules livre ou/et collection trouvés, de type +type+
  # 
  # @param [String] type Le type de module, 'formater','parser' ou 'helper'
  # 
  def get_custom_modules(type)
    module_name = "#{type}.rb"
    mds = []
    if in_collection?
      pth = File.join(collection.folder, module_name)
      mds << pth if File.exist?(pth)
    end    
    pth = File.join(folder, module_name)
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
