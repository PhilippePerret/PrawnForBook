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

    #
    # Les données de fontes
    # 
    dtitre = data

    pdf.update do

      current_color = fill_color.freeze

      # Toujours une nouvelle page (avec feuillet vierge pour 
      # séparer de couverture)
      # TODO: S’il y a un copyright, il faut le mettre sur la page
      # juste avec la page de titre, donc en regard, à gauche de la
      # page de titre qui sera à droite.
      3.times { start_new_page }

      # - Toujours sur une belle page -
      start_new_page if not(belle_page?)

      #
      # On indique qu'il ne faudra pas numéroter cette page, sauf
      # indication contraire dans la recette
      # 
      if Prawn4book.first_turn?
        book.pages[page_number].pagination = false
      end

      # 
      # Calculer la position des éléments en fonction de
      # la hauteur de page disponible
      # 
      height = bounds.top - bounds.bottom
      spy "Hauteur efficiente : #{height.inspect}".bleu
      # un_tiers = (height / 3).round # pour le titre


      #===============
      # - COLLECTION -
      #===============
      # (if any)
      if book.in_collection?
        move_to_line(my.collection_line)
        font(my.collection_font)
        fill_color(my.collection_color)
        text(book.collection.name, **{align: :center})
      end


      #===================
      # - TITRE DU LIVRE -
      #===================
      # (à un tiers environ)
      font(my.title_font)
      fill_color(my.title_color)
      move_to_line(my.title_line)
      line_titre = current_line.freeze
      text( book.title , **{align: :center, inline_format: true, style: my.title_font.style})

      #===============
      # - SOUS-TITRE -
      #===============
      # (if any)
      if book.subtitle
        font(my.subtitle_font)
        fill_color(my.subtitle_color)
        move_to_line(my.subtitle_line)
        subtitle_options = {align: :center, leading: 0, style: my.subtitle_font.style}
        ("(#{book.subtitle})").split('\\n').compact.each do |seg|
          text(seg , **subtitle_options)
        end
      end

      #============
      # - AUTEURS -
      #============
      # 
      my.setup(:author, self)
      # font(my.author_font)
      # fill_color(my.author_color)
      # move_to_line(my.author_line)
      text(book.recipe.authors.titleize, **{align: :center})
      line_authors = current_line.freeze
      
      #=====================
      # - MAISON D'ÉDITION -
      #=====================
      # 
      publisher   = my.data[:publisher]
      font(my.publisher_font)
      fill_color(my.publisher_color)
      move_to_line(my.publisher_line)
      text(book.recipe.publisher[:name], **{align: :center})
      if book.recipe.logo_exists? && publisher[:logo]
        move_to_line(my.logo_line)
        logopath = book.recipe.logo_path
        options_logo = {height: my.logo_height, position: :center}
        if File.extname(logopath) == '.svg'
          svg(File.read(logopath), **options_logo)
        else
          image(logopath, **options_logo)
        end
      end

      # On passe au recto
      start_new_page

      # On remet la couleur originale
      fill_color(current_color)

    end #/pdf.update

  end
  # /build

  def setup(key, pdf)
    couleur = send("#{key}_color".to_sym)
    numline = send("#{key}_line".to_sym)
    lafonte = send("#{key}_font".to_sym)
    pdf.update do
      fill_color(couleur)
      move_to_line(numline)
      font(lafonte)
    end
  end

  # - Predicate methods -

  def logo?
    :TRUE == @withlogo ||= true_or_false(publisher.logo? && logo)
  end

  # -- Volatile Data Methods --

  def collection_font 
    @collection_font ||= Fonte.get_in(data_collection).or_default
  end

  def collection_color
    @collection_color ||= collection_font.color || '000000'
  end

  def collection_line
    @collection_line ||= data_collection[:line] || 1
  end

  def data_collection
    @data_collection ||= data[:collection] || {}
  end

  def data_title
    @data_title ||= data[:title] || {}
  end
  def title_font 
    @title_font ||= Fonte.get_in(data_title).or_default
  end

  def title_color
    @title_color ||= title_font.color || '000000'
  end

  def title_line
    @title_line ||= data_title[:line]
  end

  def data_subtitle
    @data_subtitle ||= data[:subtitle]
  end
  def subtitle_font 
    @subtitle_font ||= Fonte.get_in(data_subtitle).or_default
  end

  def subtitle_color
    @subtitle_color ||= subtitle_font.color || '000000'
  end

  def subtitle_line
    @subtitle_line ||= data_subtitle[:line]
  end

  def data_author
    @data_author ||= data[:author]
  end
  def author_font
    @author_font ||= Fonte.get_in(data_author).or_default
  end

  def author_color
    @author_color ||= author_font.color || '000000'
  end

  def author_line
    @author_line ||= data[:author][:line]
  end

  def data_publisher
    @data_publisher ||= data[:publisher]
  end
  def publisher_font
    @publisher_font ||= Fonte.get_in(data_publisher).or_default
  end

  def publisher_color
    @publisher_color ||= publisher_font.color || '000000'
  end

  def publisher_line
    @publisher_line ||= data_publisher[:line]
  end

  def logo_line
    @logo_line ||= data_publisher[:logo][:line]
  end

  def logo_height
    @logo_height ||= begin
      lh = (data_publisher[:logo][:height] || 20)
      lh = lh.to_f if lh.is_a?(String)
      lh
    end
  end

  # -- Data Methods --

  def data
    @data ||= begin
      if book.recipe.page_de_titre === true
        {}
      else
        book.recipe.page_de_titre
      end
    end
  end

  def collection_name
    @collection_name ||= book.recipe[:collection_data][:name]
  end


end #/class PageDeTitre
end #/class Pages
end #/module Prawn4book
