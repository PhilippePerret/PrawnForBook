module Factory
class Recipe

  attr_reader :folder

  # @param [String] path Dossier du livre
  def initialize(folder)
    @folder = folder
    @data   = nil
    data # pour forcer les données par défaut
  end

  def build_with(**props)
    #
    # Prends la table +props+ de premier niveau et en fait une
    # table en perspective correspondant aux données recette d'un
    # livre ou d'une collection
    # 
    real_props = GeneratedBook::AbstractRecipe.realize_properties(**props)
    @data.deep_merge!(real_props)
    save
    # 
    # Mettre le logo si c'est nécessaire
    # 
    if props.key?(:logo)
      logo_path = File.join(folder, props[:logo])
      unless File.exist?(logo_path)
        GeneratedBook::AbstractRecipe.copy_logo_to(logo_path)
      end
    end
  end

  def data
    @data ||= default_data
  end

  ##
  # Par défaut :
  #   - Il y a un titre par défaut
  #     Changer avec : :titre_livre
  # 
  #   - Auteur par défaut (Marion)
  #     Changer avec clé : :book_auteur ou :book_auteurs
  # 
  #   - ISBN défini
  #     Changer avec :isbn
  # 
  #   - La hauteur de page à 576 (points post-script)
  #     Changer avec :book_height ou :page_height
  # 
  #   - Les marges sont réglées (cf. ci-dessous)
  #     Changer avec : :top_margin, bot_margin, :left_margin et :right_margin
  # 
  #   - les titres de niveau 1 s'affichent sur une nouvelle page,
  #     sans aucune ligne avant (donc tout en haut)
  #     Pour le changer : :titre1_on_next_page et :titre1_lines_before
  # 
  #   - Numérotation par pages
  #     Changer avec :numerotation => 'parags' (ou 'pages')
  # 
  #   - Indentation du texte (cf. ci-dessous à indent:)
  #     Changer avec :indent (on peut utiliser 15.mm, donc les unités)
  # 
  def default_data
    {
      book_data: {
        title: "Mon plus beau livre",
        auteurs: "Marion MICHEL",
        isbn:    "123-8-26598-2-36",
        collection: false,
      },
      book_format: {
        page: {
          height:  576,
          margins: {top:10, bot:20, ext:25, int:35},
          numerotation: 'pages',
        },
        text: {
          indent: 5.mm,
        },
      },
      titles:{
        level1: {
          next_page:    true,
          lines_before: 0,
        },
        level2: {
          size: 14,
        }
      },
      headers_footers:{
        dispositions: {
           :dispo_with_numero => {
            name:       "Page normale",
            footer_id:  :footer_with_numero,
            first_page:  4,
          },
        },
        headfooters: {
          :footer_with_numero => {
            name: "Avec un numéro à gauche et à droite",
            id: 'footer_with_numero',
            font: 'Helvetica',
            size: 12,
            pg_left:  {content: :numero, align: :left},
            pd_right: {content: :numero, align: :right}
          },
        }
      },
    }
  end

  def save
    # puts "Données recette sauvées : #{data.inspect}".jaune
    File.write(path, data.to_yaml)
  end

  def path
    @path ||= File.join(folder, 'recipe.yaml')
  end
end #/class Recipe
end #/module Factory
