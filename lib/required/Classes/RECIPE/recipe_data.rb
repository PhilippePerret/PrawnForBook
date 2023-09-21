#
# Le nouveau module pour obtenir les données de recette
# 
module Prawn4book
class Recipe

  #
  # La table dans laquelle seront mises toutes les données récupérées
  # de tous les fichiers recette relevés, même les valeurs par
  # défaut.
  # 
  DATA = {}

  attr_reader :owner # le pdfbook, normalement (ou la collection ?)

  def initialize(owner)
    @owner = owner
    get_all_data # => peuple DATA
  end

  public

  def [](key)
    get(key)
  end

  def get(key, default = nil)
    DATA[key] || default
  end

  # 
  # --- TOUTES LES DONNÉES (DATA) ---
  # 

  # -- Le livre --

  def book_id
    @book_id      ||= book_data[:id]
  end
  def title
    @title        ||= book_data[:title]
  end
  def subtitle
    @subtitle     ||= book_data[:subtitle]&.gsub(/\\n/, "\n")
  end
  def auteurs
    @auteurs      ||= book_data[:auteurs]||book_data[:auteur]||book_data[:authors]||book_data[:author]
  end
  def isbn
    @isbn         ||= book_data[:isbn]
  end
  def depot_legal
    @depot_legal  ||= book_data[:depot_legal]
  end

  # -- Éditeur --

  def logo_defined?
    not(publishing[:logo_path].nil?)    
  end
  def logo_path
    @logo_path ||= begin
      rp = publishing[:logo_path]
      if rp
        File.exist?(rp) || begin
          rp = File.join(owner.folder, rp)
        end
        rp
      end
    end
  end

  # -- Pages --

  # @return soit une dimension de page représentée par "a4", etc.
  # soit un Array contenant la largeur et la hauteur. Les dimensions
  # ont été évaluées
  def page_size
    @page_size ||= begin
      format_book[:taille] || begin
        [book_width, book_height]
      end
    end
  end

  def book_height
    @book_height      ||= format_book[:height].proceed_unit
  end

  def book_width
    @book_width       ||= format_book[:width].proceed_unit
  end

  # [Symbol] Orientation de la page
  def page_layout
    @page_layout        ||= format_page[:orientation].to_sym
  end

  def page_background
    @page_background    ||= format_page[:background]
  end

  def top_margin
    @top_margin         ||= format_page[:margins][:top].proceed_unit
  end
  def ext_margin
    @ext_margin         ||= format_page[:margins][:ext].proceed_unit
  end
  def int_margin
    @int_margin         ||= format_page[:margins][:int].proceed_unit
  end
  def bot_margin
    @bot_margin         ||= format_page[:margins][:bot].proceed_unit
  end

  def pagination_format
    @pagination_format      ||= format_page[:pagination_format]
  end

  def pagination_font_n_style
    @pagination_font_n_style ||= begin
      "#{pagination_font_name}/#{pagination_font_style}"
    end
  end
  def pagination_font_name
    @pagination_font_name   ||= format_page[:num_font_name]
  end
  def pagination_font_size
    @pagination_font_size   ||= format_page[:num_font_size]
  end
  def pagination_font_style
    @pagination_font_style   ||= format_page[:num_font_style]
  end

  # -- Paragraphes --

  def references_key
    @references_key ||= begin
      case page_num_type
      when 'hybrid' then :hybrid
      when 'pages'  then :page
      when 'parags' then :paragraph
      end
    end
  end

  # Type de numérotation (des pages et de tout)
  #   - 'pages'     Par page (normal)
  #   - 'parags'    Par paragraphe. Tous les paragraphes sont numérotés et le pied de page contient le numéro du premier et dernier paragraphe de la page
  #   - 'hybrid'    Par page et paragraphe. La pagination se fait par le numéro de page, et chaque paragraphe est numéroté en recommençant à 1 à chaque double-page.
  def page_num_type
    @page_num_type          ||= format_page[:numerotation]
  end
  def parag_num_font_name
    @parag_num_font_name    ||= format_text[:parag_num_font]
  end
  def parag_num_font_size
    @parag_num_font_size    ||= format_text[:parag_num_size]
  end
  def parag_num_font_style
    nil
  end
  def parag_num_vadjust
    @parag_num_vadjust      ||= format_text[:parag_num_vadjust]
  end
  def parag_num_strength
    @parag_num_strength     ||= format_text[:parag_num_strength]
  end

  # @return [Integer] Distance entre le texte et le numéro de paragraphe
  # (si les paragraphes sont numérotés)
  def parag_num_distance_from_text
    @parag_num_distance_from_text ||= format_text[:parag_num_dist_from_text]
  end

  def text_leading
    @text_leading     ||= format_text[:leading]
  end

  def line_height
    @line_height      ||= format_text[:line_height]
  end

  def text_indent
    @text_indent      ||= format_text[:indent]
  end

  # -- Polices --

  def default_font_n_style
    @default_font_n_style       ||= format_text[:default_font_n_style]
  end
  def default_font_name
    @default_font_name          ||= format_text[:default_font]
  end
  def default_font_size
    @default_font_size          ||= format_text[:default_size]
  end
  def default_font_style
    @default_font_style         ||= format_text[:default_style]
  end

  # --- Page d'index ---

  def index_canon_font_n_style
    @index_canon_font_n_style ||= page_index[:aspect][:canon][:font_n_style]
  end
  def index_canon_font_size
    @index_canon_font_size ||= page_index[:aspect][:canon][:size]
  end
  def index_number_font_n_style
    @index_number_font_n_style ||= page_index[:aspect][:number][:font_n_style]
  end
  def index_number_font_size
    @index_number_font_size ||= page_index[:aspect][:number][:size]
  end

  # -- Headers & Footers --

  def headers_footers
    @headers ||= get(:headers_footers)
  end

  # -- Modèle --

  # Pas de modèle définissable pour le moment
  # TODO: Voir à quoi ça correspond
  def template
    nil
  end

  # -- Bibligraphies --

  def biblio_book_identifiant
    @biblio_book_identifiant ||= bibliographies[:book_identifiant]
  end

  #
  #
  # --- SOUS-GROUPES PRINCIPAUX ---
  # 
  # 

  def format_text
    @format_text        ||= DATA[:book_format][:text]
  end

  def format_page
    @format_page        ||= DATA[:book_format][:page]
  end

  # ne pas confondre avec la clé :book_format de la cette
  def format_book 
    @format_book        ||= DATA[:book_format][:book] || raise(FatalPrawnForBookError.new(499, {data: "recipe>book_data>book>{Hash}"}))
  end

  def format_titles
    @format_titles      ||= DATA[:book_format][:titles]
  end

  # 
  # --- GROUPES PRINCIPAUX ---
  # 

  def book_format
    @book_format        ||= DATA[:book_format]
  end

  def table_of_content
    @table_of_content   ||= DATA[:table_of_content]
  end

  def page_de_titre
    @page_de_titre      ||= DATA[:page_de_titre]
  end

  def page_index
    @page_index         ||= DATA[:page_index]
  end

  def page_infos
    @page_infos         ||= DATA[:page_infos]
  end

  def book_data
    @book_data          ||= DATA[:book_data]
  end
  def publishing
    @publishing         ||= DATA[:publishing]
  end

  def inserted_pages
    @inserted_pages     ||= DATA[:inserted_pages]
  end

  def bibliographies
    @bibliographies ||= begin
      DEFAULT_BIBLIOGRAPHIES.deep_merge(DATA[:bibliographies]||{})
    end
  end


  def fonts_data
    @fonts_data ||= DATA[:fonts] || {}
  end
  alias :fonts :fonts_data


  private

    # Méthode principale qui relève toutes les données recette
    # qu'on peut trouver en remontant 4 dossiers depuis le owner 
    # courant.
    # 
    # Finit également par mettre les valeurs par défaut à partir du
    # fichier recipe_default.yaml au même niveau que ce module.
    # 
    def get_all_data
      #
      # Les valeurs par défaut
      # 
      get_data_in_recipe(File.join(__dir__,'RECIPE_DEFAULT.yaml'))
      #
      # Les valeurs dans les recettes en remontant les dossiers. Les
      # données lointaines sont toujours écrasées par les données
      # proches.
      # 
      dir = owner.pdf_path
      4.times.collect do
        dir = File.dirname(dir) || break
      end.reverse_each do |dossier|
        ['recipe', 'recipe_collection'].each do |affixe|
          get_data_in_recipe(File.join(dossier, "#{affixe}.yaml"))
        end
      end
    end

    def get_data_in_recipe(recipe_path)
      return unless File.exist?(recipe_path)
      DATA.deep_merge!(YAML.load_file(recipe_path, **options_yaml)||{})
    end

    def options_yaml
      @options_yaml ||= {symbolize_names:true, aliases: true, permitted_classes: [Date, Symbol]}.freeze
    end


  DEFAULT_BIBLIOGRAPHIES = {
    book_identifiant: :livre,
    biblios: {
      livre: {
        path: './livres.yaml'
      }
    }
  }

end #/Class Recipe
end #/module Prawn4book
