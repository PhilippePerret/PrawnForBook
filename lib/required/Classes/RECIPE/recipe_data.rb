#
# Le nouveau module pour obtenir les données de recette
# 
module Prawn4book
class Recipe


  # Pour "défautiser" une valeurs quelconque
  # 
  # @exemple
  #   On envoie une table [Hash] et des valeurs à trouver, dans
  #   +values+ et la méthode s’assure que soit elles sont définies
  #   dans la table, soit on les met.
  #   Par exemple, si 
  #     +foo+ = {a: "Première"} 
  #   et que 
  #     +values+ = {a: "First", b: "Deuxième"}
  #   alors
  #     defaultize retournera : {a:"Première", b:"Deuxième"}
  # 
  def defaultize(foo, values)
    case foo
    when Hash
      values.each do |k, v|
        foo[k] || foo.merge!(k => v)
      end
    else
      foo || values
    end
  end

  #
  # La table dans laquelle seront mises toutes les données récupérées
  # de tous les fichiers recette relevés, même les valeurs par
  # défaut. C'est dans cette table que toutes les données sont prises
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

  def level_error
    FATAL_LEVEL_ERROR
  end

  # --- Fonts Definitions ---

  # La fonte [Prawn4book::Fonte] à utiliser pour les notes de page
  # @rappel : les notes de page sont des notes comme les notes de bas
  # de page ou de fin d'ouvrage mais qui s'insèrent au fil du texte,
  # pour une lecture plus aisée.
  def note_page_fonte
    @note_page_fonte ||= Fonte.get_in(notes_page, **{size: default_font.size - 2}).or_default
  end

  def notes_page_borders
    @notes_page_borders ||= notes_page[:borders]
  end

  def notes_page
    @notes_page ||= format_text[:notes_page]
  end

  # 
  # --- TOUTES LES DONNÉES (DATA) ---
  # 

  # -- Le livre --

  def book_id
    @book_id ||= book_data[:id]
  end
  def title
    @title ||= book_data[:title]||book_data[:titre]
  end
  def subtitle
    @subtitle     ||= (book_data[:subtitle]||book_data[:sous_titre])&.gsub(/\\n/, "\n")
  end
  def authors
    @authors      ||= book_data[:auteurs]||book_data[:auteur]||book_data[:authors]||book_data[:author]
  end
  def isbn
    @isbn         ||= book_data[:isbn]
  end
  def depot_legal
    @depot_legal  ||= book_data[:depot_legal]
  end

  # -- Éditeur --

  def logo_path
    @logo_path ||= begin
      relp = publisher[:logo_path].freeze
      rp = relp.dup
      if rp
        File.exist?(rp) || begin
          File.exist?(rp = File.join(owner.folder, rp)) || begin
            rp = File.join(owner.folder, 'images', relp)
          end
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

  # :publishing ou :pdf
  def output_format
    @output_format ||= format_book[:format].to_sym
  end
  def output_format=(value) #tests
    @output_format = value
    Prawn4book::PdfBook::AnyParagraph.instance_variable_set("@remplacement_hyperlink", nil)
  end

  # [Symbol] Orientation de la page
  def page_layout
    @page_layout        ||= format_page[:orientation].to_sym
  end

  def page_background
    @page_background    ||= format_page[:background]
  end

  def top_margin
    @top_margin ||= get_margin(:top)
    # format_page[:margins][:top].proceed_unit
  end
  def ext_margin
    @ext_margin ||= get_margin(:ext)
  end
  def int_margin
    @int_margin ||= get_margin(:int)
  end
  def bot_margin
    @bot_margin ||= get_margin(:bot)
  end

  # Méthode générique pour obtenir les valeurs des marges
  def get_margin(side)
    if format_page[:margins] && format_page[:margins][side]
      format_page[:margins][side].to_pps
    else
      # Si on doit prendre une marge par défaut, c’est qu’une marge
      # n’est pas définie. On conseille à l’utilisateur de la définir
      # pour ne pas avoir ensuite de problèmes de mise en page.
      unless @message_missing_margins_done === true
        puts "\nJe n’ai pas donné le message".jaune
        sleep 1
        missings      = []
        margs_setting = {}
        if format_page[:margins]
          TERMS[:les_marges_] % [:top, :bot, :ext, :int].select do |s|
            v =
              if format_page[:margins][s].nil?
                missings << s
                default_margins[s]
              else
                format_page[:margins][s]
              end
            margs_setting.merge!(s => v)
          end
          missings = missings.join(', ')
        else
          # Les 4 sont manquantes
          missings = TERMS[:four_margins]
          margs_setting = default_margins.dup
        end
        puts "\nPFBError[11] : #{PFBError[11].inspect}".bleu
        sleep 2
        add_fatal_error(PFBError[11] % {
          missings: missings, margins: margs_setting.inspect
        }, nil)
        @message_missing_margins_done = true
      end
      default_margins[side]
    end
  end

  # Les marges par défaut en fonction de la taille du livre
  # 
  def default_margins
    @default_margins ||= Metrics.calc_margins_for(owner)
  end

  # -- Guillemets --

  def guillemets
    @guillemets ||= begin
      gu = format_text[:guillemets] || format_text[:quotes]
      # -- Correction de quelques erreurs typographiques --
      case gu[0]
      when '«'             then gu[0] = "#{gu[0]} "
      when '“ ', '“ ' then gu[0] = '“'
      end
      case gu[1]
      when '«' then gu[1] = " #{gu[1]}"
      when ' ”', ' ”' then gu[1] = '”'
      end
      gu
    end
  end

  # Pour les expressions régulières
  # 

  # Expression régulière pour attraper les guillemets qui ne
  # correspondent pas à ceux voulus
  # 
  def reg_guillemets
    @reg_guillemets ||= begin
      /[“«][  ]?(?<content>.+?)[  ]?[»”]/.freeze
    end
  end

  # Remplacement des guillemets
  def remp_guillemets
    @remp_guillemets ||= begin
      "%{before}#{guillemets[0]}%{content}#{guillemets[1]}%{after}".freeze
    end
  end

  # Expression régulière pour attraper les contre-guillemets
  # 
  def reg_contre_guillemets
    @reg_contre_guillemets ||= begin
      contre_guils = guillemets[0][0] == "« " ? ["“","”"] : ["«","»"]
      /#{contre_guils[0]}[  ]?(?<content>.+?)[  ]?#{contre_guils[1]}/.freeze
    end
  end

  # Remplacement des contre-guillemets
  # 
  def remp_contre_guillemets
    @remp_contre_guillemets ||= begin
      "#{guillemets[0]}%{content}#{guillemets[1]}".freeze
    end    
  end

  # Pour modifier les guillemets à la volée (surtout pour
  # le manuel et les tests)
  # 
  # @param paire [Symbol|Hash<String>]
  # 
  #   Soit la paire de guillemets (['“', '”'])
  #   Soit un symbole :
  #       :gc     Pour "guillemes courbes" => ['“', '”']
  #       :ch     Pour "chevrons", => ['« ', ' »']
  # 
  def define_guillemets(paire)
    case paire
    when :gc then @guillemets = ['“', '”']
    when :ch then @guillemets = ['« ', ' »']
    else @guillemets = paire
    end
    @reg_guillemets         = nil
    @remp_guillemets        = nil
    @reg_contre_guillemets  = nil
    @remp_contre_guillemets = nil
  end

  # -- Puce --

  def puce
    pu = format_text[:puce]
    fsize = pu[:size] if pu.is_a?(Hash)
    fsize ||= 12
    pu_default = {text:nil, vadjust: 1, hadjust: 0, left: 3.5.mm, size: 12}
    
    if pu.is_a?(Hash)
      if pu[:text].is_a?(String)
        if pu[:left] 
          pu[:left] = pu[:left].proceed_unit
        else
          pu.delete(:left)
        end
        return pu_default.merge(pu) 
      else
        pu_default.merge!(pu)
        pu = pu_default[:text]
      end
    end

    lettre = 
      case pu
      when :hyphen, :tiret  then '–'
      when :losange         then PUCE_TEMP % [fsize, 'M']
      when :black_losange   then PUCE_TEMP % [fsize, 'L']
      when :square          then PUCE_TEMP % [fsize, 'C']
      when :black_square    then PUCE_TEMP % [fsize, 'D']
      when :bullet          then PUCE_TEMP % [fsize, 'A']
      when :black_bullet    then PUCE_TEMP % [fsize, 'B']
      when :finger          then PUCE_TEMP % [fsize, 'F']
      when :black_finger    then PUCE_TEMP % [fsize, 'G']
      else '–'
      end
    data_puce = pu_default.merge(text: lettre)
    data_puce[:left] = data_puce[:left].proceed_unit
    return data_puce
  end

  PUCE_TEMP = '<font name="PictoPhil" size="%s">%s</font>'

  # -- Pagination --

  def pagination_format
    @pagination_format ||= format_page[:pagination_format]
  end

  def pagination_fonte
    @pagination_fonte ||= Fonte.get_in(format_page[:num_font]).or_default
  end

  def references_key
    @references_key ||= begin
      case page_num_type
      when 'hybrid' then :hybrid
      when 'pages'  then :page
      when 'parags' then :paragraph
      end
    end
  end

  # -- Format des références --

  def reference_page_format
    format_text[:references][:page_format]
  end
  def reference_paragraph_format
    format_text[:references][:paragraph_format]
  end
  def reference_hybrid_format
    format_text[:references][:hybrid_format]
  end

  # Type de numérotation (des pages et de tout)
  #   - 'pages'     Par page (normal)
  #   - 'parags'    Par paragraphe. Tous les paragraphes sont numérotés et le pied de page contient le numéro du premier et dernier paragraphe de la page
  #   - 'hybrid'    Par page et paragraphe. La pagination se fait par le numéro de page, et chaque paragraphe est numéroté en recommençant à 1 à chaque double-page.
  def page_num_type
    @page_num_type          ||= format_page[:numerotation]
  end

  # Fonte pour les numéros de paragraphes
  def parag_num_font
    @parag_num_font ||= Fonte.get_in(format_text[:parag_num_font]).or_default
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
    @text_indent      ||= begin
      if format_text[:indent].nil? || format_text[:indent] == 0
        nil
      else
        format_text[:indent].to_pps
      end
    end
  end

  def right_margin_with_floating_image
    @right_margin_with_floating_image ||= format_text[:right_margin_with_floating_image]
  end
  def left_margin_with_floating_image
    @left_margin_with_floating_image ||= format_text[:left_margin_with_floating_image]
  end

  # -- Polices --

  def default_font
    @default_font ||= begin
      if format_text[:default_font]
        Fonte.get_in(format_text[:default_font]).or_default
      else
        Fonte.default_fonte_times.dup
      end
    end
  end

  def default_font_name
    default_font.name
  end
  def default_font_size
    default_font.size
  end
  def default_font_style
    default_font.style
  end

  # --- Page d'index ---

  def index_canon_fonte
    @index_canon_fonte ||= begin
      tbl = page_index[:aspect] || {}
      tbl = tbl[:canon] || {}
      Fonte.get_in(tbl).or_default
    end
  end
  def index_number_fonte
    @index_number_fonte ||= begin
      tbl = page_index[:aspect] || {}
      tbl = tbl[:number] || {}
      Fonte.get_in(tbl).or_default
    end
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
    @format_text ||= book_format[:text]
  end

  def format_images
    @format_images ||= book_format[:images] || {}
  end

  def format_page
    @format_page ||= book_format[:page]
  end

  # ne pas confondre avec la clé :book_format de la recette
  # Ici, c'est [:book_format][:book], donc un sous-ensemble de
  # :book_format qui concerne seulement l'aspect du livre.
  def format_book 
    @format_book ||= book_format[:book] || raise(PFBFatalError.new(499, {data: "recipe>book_data>book>{Hash}"}))
  end

  def format_titles
    @format_titles ||= book_format[:titles]
  end

  # 
  # --- GROUPES PRINCIPAUX ---
  # 

  def book_format
    @book_format ||= DATA[:book_format]
  end

  def table_of_content
    @table_of_content   ||= DATA[:table_of_content]
  end

  def page_de_titre
    @page_de_titre ||= inserted_pages[:page_de_titre]||inserted_pages[:title_page]
  end

  def faux_titre
    @faut_titre ||= inserted_pages[:faux_titre] || inserted_pages[:half_title]
  end

  def page_index
    @page_index    ||= DATA[:page_index]||inserted_pages[:page_index]||inserted_pages[:index_page]
  end

  def copyright
    @copyright ||= inserted_pages[:copyright]
  end

  # Données de mise en forme pour la page de crédit
  # 
  # On met des valeurs par défaut, mais qui ne peuvent être prises de
  # la recette par défaut puisque la valeur est juste false.
  def credits_page
    @credits_page ||= begin
      tbl = inserted_pages[:credits_page]||inserted_pages[:page_credits]
      tbl = {} if tbl === true
      defaultize(tbl, {disposition: 'distribute'})
    end
  end


  def book_making
    @book_making ||= DATA[:book_making]
  end

  def book_data
    @book_data ||= DATA[:book_data]
  end

  def publisher
    @publisher ||= DATA[:publisher] || {}
  end

  def inserted_pages
    @inserted_pages ||= DATA[:inserted_pages]
  end

  def headers_footers
    @headers_footers ||= DATA[:headers_footers]
  end

  def bibliographies
    @bibliographies ||= DATA[:bibliographies] || {}
  end

  def collection
    @collection ||= begin
      DATA[:collection] || DATA[:collection_data] || {}
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
      DATA.deep_merge!(YAML.load_file(recipe_path, **YAML_OPTIONS)||{})
    end

end #/Class Recipe
end #/module Prawn4book
