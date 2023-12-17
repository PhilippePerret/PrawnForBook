module Prawn4book
class Pages
class PageDeTitre

  attr_reader :book

  # = main =
  #
  # Méthode principale permettant de construire la page
  # 
  def build(pdf)
    spy "\n\n-> Construction de la page de titre".jaune
    @book = pdf.book
    my = self

    current_color = pdf.fill_color.freeze

    # Toujours une nouvelle page (avec feuillet vierge pour 
    # séparer de couverture)
    pdf.start_new_page

    # - Toujours sur une belle page -
    pdf.start_new_page if not(pdf.belle_page?)

    # - Copyright -
    # 
    # S’il y a un copyright, il faut le mettre en regard de la 
    # page de titre. Donc il faut revenir à la page précédente
    # et le copier
    print_copyright(pdf) if copyright?

    #
    # On indique qu'il ne faudra pas numéroter cette page, sauf
    # indication contraire dans la recette
    # 
    if Prawn4book.first_turn?
      book.pages[pdf.page_number].pagination = false
    end

    # 
    # Calculer la position des éléments en fonction de
    # la hauteur de page disponible
    # 
    calc_default_lines(pdf)

    # - COLLECTION -
    # (if any)
    print_element(:collection, pdf) if book.in_collection?

    # - TITRE DU LIVRE -
    # 
    print_element(:title, pdf)

    # - SOUS-TITRE -
    # (if any)
    print_element(:subtitle, pdf) if subtitle?

    # - AUTEURS -
    # 
    print_element(:author, pdf)
    
    # - MAISON D'ÉDITION -
    #   (et son logo)
    # 
    if book.publisher
      print_element(:publisher, pdf)
      if logo?
        pdf.move_to_line(logo_line)
        logopath = logo_path
        options_logo = {height: logo_height, position: :center}
        if File.extname(logopath) == '.svg'
          pdf.svg(File.read(logopath), **options_logo)
        else
          pdf.image(logopath, **options_logo)
        end
      end
    end

    pdf.update do
      fill_color(current_color)     # couleur originale
    end #/pdf.update

  end
  # /build

  # -- Building Methods --

  #########################################
  ###   ÉCRITURE DE L’ÉLÉMENT DE TITRE  ###
  #########################################
  # Sur la ligne voulue, de la couleur voulue, avec la police voulu
  # 
  # @param key [Symbol]
  # 
  #     L’élément à écrire, par exemple :collection ou :authors
  # 
  # @param pdf [Prawn::PrawnView]
  # 
  #     Le document en construction
  def print_element(key, pdf)
    my = self
    numline = eget(key, :line)
    lafonte = eget(key, :font)
    content = eget(key, :content)
    options = options_element.merge(eget(key, :options))
    pdf.update do
      fill_color(lafonte.color)
      move_to_line(numline)
      font(lafonte)
      text(content, **options)
    end
  end

  def eget(key, prop)
    methode = "#{key}_#{prop}".to_sym
    if self.respond_to?(methode)
      send(methode)
    else
      key_data = send("data_#{key}".to_sym)
      case prop
      when :font
        Fonte.get_in(key_data).or_default
      when :line
        key_data[:line] || default_line_for(key)
      when :options
        sup_options_for(key_data)
      when :color
        eget(key, :font).color
      end
    end
  end

  def options_element
    @options_element ||= {
      align: :center,
      inline_format: true,
    }
  end

  def sup_options_for(keydata)
    tbl = {}
    tbl.merge!(leading: keydata[:leading]) if keydata[:leading]
    return tbl
  end

  # Écriture du COPYRIGHT
  # 
  # @note
  #   On se trouve sur la page de titre, déjà. Donc il faut remonter
  #   d’une page puis retourner ensuite à la page de titre.
  # 
  def print_copyright(pdf)
    my = self
    fonte = Fonte.default
    content = copyright_content
    copyright_options = {size:fonte.size - 3, align: :left}
    pdf.update do
      current_page = page_number.freeze
      go_to_page(current_page - 1)
      book.page(current_page - 1).pagination = false
      font(fonte)
      h = height_of(content, **copyright_options)
      move_cursor_to(h + line_height)
      text(content, **copyright_options)
      go_to_page(current_page)
    end
  end

  # - Predicate methods -

  def subtitle?
    not(book.subtitle.nil?)
  end

  # @return true s’il faut écrire un copyright
  def copyright?
    data.key?(:copyright) && copyright_content && copyright_content.length > 10
  end

  # Concernant le logo
  # 
  # @note
  #   Attention : il peut s’agir d’un autre logo que le logo
  #   "officiel"
  # 
  def logo?
    book.publisher.logo? && logo && logo_valid?
  end
  def logo_valid?
    File.exist?(logo_path) || begin
      add_erreur(PFBError[252] % {path: logo_path})
      false
    end
  end

  # -- Volatile Data Methods --

  def data_collection
    @data_collection ||= book.recipe.collection
  end
  def collection_content
    @collection_content ||= data_collection[:name] || ''
  end


  def data_title
    @data_title ||= data[:title] || {}
  end
  def title_content
    @title_content ||= book.title
  end

  def data_subtitle
    @data_subtitle ||= data[:subtitle]
  end
  def subtitle_content
    @subtitle_content ||= "(#{book.subtitle})"
  end

  def data_author
    @data_author ||= data[:author] || {}
  end
  def author_content
    @author_content ||= book.recipe.authors.titleize
  end

  def data_publisher
    @data_publisher ||= data[:publisher] || {}
  end
  def publisher_content
    @publisher_content ||= book.recipe.publisher[:name] || ''
  end

  def data_logo
    @data_logo ||= data_publisher[:logo] || {}
  end
  def logo_path
    @logo_path ||= data_publisher[:path] || book.recipe.logo_path
  end

  def logo_height
    @logo_height ||= begin
      lh = data_logo[:height] || 20
      lh.to_pps
    end
  end

  def copyright_content
    @copyright_content ||= data[:copyright]
  end

  # -- Calc Methods --

  # Méthode de calcul de l’emplacement des éléments dans la page
  # (les numéros de ligne)
  # 
  def default_line_for(key)
    @default_lines[key] || begin
      # Erreur systématique
      raise "Élément de page de titre inconnu : key = #{key.inspect}"
    end
  end

  def calc_default_lines(pdf)
    @default_lines = {}
    line_count = pdf.line_count.freeze
    @default_lines.merge!(collection: 2)
    # - Hauteur de la ligne de titre -
    cur_top = (data_title[:line] || line_count / 3) + book.title.count("\n")
    @default_lines.merge!(title: cur_top.freeze)
    # - Hauteur d’un sous-titre éventuel -
    if subtitle?
      cur_top = data_subtitle[:line] || (cur_top + (3 + book.subtitle.count("\n")))      
      @default_lines.merge!(subtitle: cur_top.freeze)
    end
    cur_top = data_author[:line] || (cur_top + 4)
    @default_lines.merge!(author: cur_top.freeze)
    @default_lines.merge!(logo: line_count - 1)
    @default_lines.merge!(publisher: logo? ? line_count - 4 : line_count - 1)
  end

  # -- Data Methods --

  # Données pour la page de titre
  def data
    @data ||= begin
      if book.recipe.page_de_titre === true
        {}
      else
        book.recipe.page_de_titre
      end
    end
  end


end #/class PageDeTitre
end #/class Pages
end #/module Prawn4book
