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

  def skip_page_creation?   ;recipe.skip_page_creation?  end
  def page_de_garde?        ;recipe.page_de_garde?       end
  def page_de_titre?        ;recipe.page_de_titre?       end
  def credits_page?         ;recipe.credits_page?        end

  # --- Configuration Pdf Methods ---

  # @return [Hash] La configuration qui sert de second argument pour 
  # la méthode #generate de Prawn::View (en fait PdfBook::PrawnView)
  # Donc il ne faut pas y mettre n'importe quoi, mais seulement les
  # valeurs attendues par la méthode, qu'on peut trouver ici :
  #   https://prawnpdf.org/api-docs/2.3.0/Prawn/Document.html#generate-class_method
  #   (chercher VALID_OPTIONS)
  def pdf_config
    @pdf_config ||= {
        # Options qu'on trouve dans [1]
        skip_page_creation: skip_page_creation?,
        page_size:          recipe.page_size, # p.e. "a4"
        page_layout:        recipe.page_layout,
        margin:             recipe.top_margin,
        left_margin:        recipe.ext_margin,
        right_margin:       recipe.int_margin,
        ext_margin:         recipe.ext_margin,
        int_margin:         recipe.int_margin,
        top_margin:         recipe.top_margin,
        bot_margin:         recipe.bot_margin,
        compress:           true, # fixe pour le moment
        optimize_objects:   true, # fixe, pour le moment
        background:         recipe.page_background,
        info:               nil, # ?
        text_formatter:     nil, # ?
        print_scaling:      nil, # ?
        # Autres options
        default_leading:    recipe.text_leading,
        infos:              recipe.credits_page,
        template:           recipe.template,
      }.tap do |h|
        spy "options pour #generate : #{h.pretty_inspect}"
      end
  end

  # Fontes utilisées dans le boucle (définies dans le fichier de
  # recette du livre ou de la collection)
  def book_fonts
    @book_fonts ||= recipe.fonts_data
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



end #/class PdfBook
end #/module Prawn4book
