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
    collection_name:  [:collection_data, :name],

    # -- Données du livre --
    book_titre:       [:book_data, :title],
    book_sous_titre:  [:book_data, :subtitle],
    book_auteur:      [:book_data, :auteurs],
    book_auteurs:     [:book_data, :auteurs],
    # -- Éditeur --
    publisher_name:   [:publishing, :name],
    logo:             [:publishing, :logo_path],

    # -- Imprimerie --
    imprimerie:       [:page_infos, :printing, :name],
    imprimerie_ville: [:page_infos, :printing, :lieu],
    # -- Format du livre --
    leading:      [:book_format, :text, :leading],
    line_height:  [:book_format, :text, :line_height],
    book_height:  [:book_format, :book, :height],
    page_height:  [:book_format, :book, :height],
    height:       [:book_format, :book, :height],
    margin_top:   [:book_format, :page, :margins, :top],
    margin_left:  [:book_format, :page, :margins, :left],
    margin_bot:   [:book_format, :page, :margins, :bot],
    margin_bottom:[:book_format, :page, :margins, :bot],
    margin_right: [:book_format, :page, :margins, :right],
    indent:       [:book_format, :text, :index],
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
  }

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
  logo_path = props[:publishing] && props[:publishing][:logo_path]
  if logo_path
    src = File.join(__dir__, 'images', logo_path)
    dst = File.join(book.folder, logo_path)
    mkdir(File.dirname(src))
    FileUtils.cp(src, dst)
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
    real_props = {}
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
