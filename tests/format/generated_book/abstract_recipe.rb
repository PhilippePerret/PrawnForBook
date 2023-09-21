module GeneratedBook
class AbstractRecipe

  ##
  # Table de correspondance, servant pour les livres et la collection,
  # entre la clé de premier niveau utilisée par les tests et la clé
  # hiérarchique dans le fichier recette de la collection ou du 
  # livre. Par exemple, la clé :leading définie par les tests  conduira
  # à la clé <recipe>[:book_format][:text][:leading] dans le fichier
  # recette du livre ou de la collection
  # @note
  #   Bien noter que cette donnée sert autant pour la recette de la
  #   collection que pour la recette du livre.
  # 
  REAL_PATH_DATA = {
    # -- Données de la collection --
    collection_name:    [:collection_data, :name],
    # -- Données du livre --
    book_titre:         [:book_data, :title],
    titre_livre:        [:book_data, :title],
    book_sous_titre:    [:book_data, :subtitle],
    book_auteur:        [:book_data, :auteurs],
    book_auteurs:       [:book_data, :auteurs],
    isbn:               [:book_data, :isbn],
    # -- Éditeur --
    publisher_name:     [:publisher, :name],
    publisher_contact:  [:publisher, :contact],
    publisher_mail:     [:publisher, :mail],
    publisher_siret:    [:publisher, :siret],
    publisher_url:      [:publisher, :url],
    logo:               [:publisher, :logo_path],
    logo_height:        [:page_de_titre, :logo, :height],
    # -- Format du livre --
    leading:      [:book_format, :text, :leading],
    line_height:  [:book_format, :text, :line_height],
    font_size:    [:book_format, :text, :default_size],
    indent:       [:book_format, :text, :indent],
    book_height:  [:book_format, :book, :height],
    page_height:  [:book_format, :book, :height],
    book_width:   [:book_format, :book, :width],
    page_width:   [:book_format, :book, :width],
    height:       [:book_format, :book, :height],
    margin_top:   [:book_format, :page, :margins, :top],
    top_margin:   [:book_format, :page, :margins, :top],
    margin_left:  [:book_format, :page, :margins, :left],
    left_margin:  [:book_format, :page, :margins, :left],
    margin_bot:   [:book_format, :page, :margins, :bot],
    bot_margin:   [:book_format, :page, :margins, :bot],
    margin_bottom:[:book_format, :page, :margins, :bot],
    margin_right: [:book_format, :page, :margins, :right],
    right_margin: [:book_format, :page, :margins, :right],
    numerotation: [:book_format, :page, :numerotation],
    pagination_format:[:book_format, :page, :pagination_format],
    no_num_if_empty: [:book_format, :page, :no_num_if_empty],
    num_only_if_num: [:book_format, :page, :num_only_if_num],
    numpag_ifno_numpar: [:book_format, :page, :num_page_if_no_num_parag],
    # - les pages à insérer -
    page_de_titre:  [:inserted_pages, :page_de_titre],
    page_de_garde:  [:inserted_pages, :page_de_garde],
    faux_titre:     [:inserted_pages, :faux_titre],
    page_infos:     [:inserted_pages, :page_infos],
    # - les titres -
    titre1_on_next_page:  [:titles, :level1, :next_page],
    titre1_on_belle_page: [:titles, :level1, :belle_page],
    titre1_lines_before:  [:titles, :level1, :lines_before],
    titre1_lines_after:   [:titles, :level1, :lines_after],
    titre1_font_size:     [:titles, :level1, :size],
    titre2_lines_before:  [:titles, :level2, :lines_before],
    titre2_lines_after:   [:titles, :level2, :lines_after],
    titre2_font_size:     [:titles, :level2, :size],
    # - Headers et Footers
    dispositions:         [:headers_footers, :dispositions],
    headfooters:          [:headers_footers, :headfooters], 
    # - les infos -
    concepteur:           [:page_infos, :conception, :patro],
    concepteur_name:      [:page_infos, :conception, :patro],
    concepteur_mail:      [:page_infos, :conception, :mail],
    metteur_en_page:      [:page_infos, :mise_en_page, :patro],
    metteur_en_page_mail: [:page_infos, :mise_en_page, :mail],
    cover:                [:page_infos, :cover, :patro],
    couverture:           [:page_infos, :cover, :patro],
    couverture_mail:      [:page_infos, :cover, :mail],
    correcteur:           [:page_infos, :correction, :patro],
    correctrice:          [:page_infos, :correction, :patro],
    correcteur_mail:      [:page_infos, :correction, :mail],
    correctrice_mail:     [:page_infos, :correction, :mail],
    disposition_infos:    [:page_infos, :aspect, :disposition],
    font_label_infos:     [:page_infos, :aspect, :libelle, :font],
    style_label_infos:    [:page_infos, :aspect, :libelle, :style],
    size_label_infos:     [:page_infos, :aspect, :libelle, :size],
    color_label_infos:    [:page_infos, :aspect, :libelle, :color],
    font_infos:           [:page_infos, :aspect, :value, :font],
    size_infos:           [:page_infos, :aspect, :value, :size],
    disposition:          [:page_infos, :aspect, :disposition],
    depot_legal:          [:page_infos, :depot_legal],
    imprimerie:           [:page_infos, :printing, :name],
    imprimerie_ville:     [:page_infos, :printing, :lieu],
    # - La page d'index -
    index_canon_font_name:    [:page_index, :aspect, :canon,   :name],
    index_canon_font_size:    [:page_index, :aspect, :canon,   :size],
    index_canon_font_style:   [:page_index, :aspect, :canon,   :style],
    index_number_font_name:   [:page_index, :aspect, :number,  :name],
    index_number_font_size:   [:page_index, :aspect, :number,  :size],
    index_number_font_style:  [:page_index, :aspect, :number,  :style],
    # - Bibliographies -
    # (telles quelles)
    bibliographies:       [:bibliographies],
  }


# Pour pouvoir être utilisé de l'extérieur avec 
#   GeneratedBook::AbstractRecipe.copy_logo_to(logo_path)
def self.copy_logo_to(dst, src_name = 'logo.jpg')
  src = File.join(__dir__, 'images', src_name)
  mkdir(File.dirname(src))
  FileUtils.cp(src, dst)
end


attr_reader :owner
def initialize(owner)
  @owner  = owner
  @data   = get_recipe_data
end

##
# = main =
# 
# Construit la recette du livre avec les propriétés +props+ en
# respectant les options +options+
# 
# @note
#   [1] +prop+ est une table de premier niveau seulement, pour
#       faciliter les modifications. Les propriétés seront ensuite
#       bien rangées à leur place avant l'enregistrement. Par ex.,
#       le leading peut être défini avec props = {leading: 4} mais
#       ensuite on le mettra à sa place dans book_format:text:leading
# 
# @param [Hash] props Table des propriétés à mettre dans la recette du livre avant de le construire.
# @param [Hash] options
# @option options [Boolean] keep Si true, on garde les données actuelles et on leur ajoute simplement les nouvelles.
def build_with(props, **options)
  # 
  # On met les options par défaut
  # 
  options = defaultize_options(options)
  # 
  # On range correctement les propriétés (voir [1])
  # 
  props = realize_properties(props)
  # puts "props = #{props.inspect}"
  # 
  # On peut enregistrer les propriétés
  # 
  if options[:keep]
    @data.merge!(props)
  else
    @data = props
  end
  save
  #
  # Si un logo est défini, il faut le mettre dans le dossier
  # @note
  #   Le fichier original se trouve toujours dans le dossier 'images'
  #   du dossier
  logo_path = props[:publisher] && props[:publisher][:logo_path]
  if logo_path
    self.class.copy_logo_to(File.join(book.folder, logo_path))
  end

rescue Exception => e
  puts "ERROR: #{e.message}".rouge
  puts e.backtrace.join("\n").rouge
end

def path
  @path ||= File.join(mkdir(owner.folder), recipe_name)
end

private

  ##
  # Enregistrement des données dans le fichier recette
  # @api
  def save
    @data.merge!(last_updated: Time.now.jj_mm_aaaa)
    File.write(path, @data.to_yaml)
  end

  # Transforme la table de propriété fournie, à un niveau, en table
  # pour le fichier recette recipe.yaml
  # 
  # @return [Hash] la table pour les données de recette
  # 
  # @api private
  def realize_properties(props)
    self.class.realize_properties(props)
  end
  def self.realize_properties(props)
    real_props = {}
    # 
    # Si les fonts ont été fournies "normalement", donc pas en tant
    # que premier niveau de table.
    # 
    if props.key?(:fonts) && props[:fonts].is_a?(Hash)
      real_props.merge!(fonts: props.delete(:fonts))
    end
    # 
    # Si les données des titres ont été fournies régulièrement (en
    # profondeur) on les prend en tant que telles
    # 
    if props.key?(:titles) && props[:titles].is_a?(Hash)
      real_props.merge!(titles: props.delete(:titles))
    end
    
    # - Ajouter les données uni-dimension -
    props.each do |key, value|
      dpath = REAL_PATH_DATA[key] || []
      la = real_props
      last_index = dpath.count - 1
      dpath.each_with_index do |sk, idx|
        la.merge!(sk => {}) unless la.key?(sk)
        if idx == last_index
          la[sk] = value
        else
          la = la[sk]
        end
      end
      # la.merge!(key => value)
    end

    # puts "real_props = #{real_props.inspect}".bleu
    return real_props
  end

  # @api private
  def defaultize_options(opts)
    opts ||= {}
  end

  # @api private
  def get_recipe_data
    if File.exist?(path)
      YAML.load_file(path, **{aliases:true, symbolize_name:true})
    else
      {}
    end
  end

end #/class AbstractRecipe
end #module GeneratedBook
