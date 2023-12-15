module Prawn4book
class PrawnView

  ##
  # Méthode permettant d’écrire la page de faux titre, quand sa
  # valeur (inserted_pages: faux_titre:) n’est pas à faux.
  # 
  def insert_faux_titre

    # Pour éviter les collisions qu’on pouvait avoir avant, on 
    # isole les données du faux titre
    ft = FauxTitre.new(book, self)

    # On commence une nouvelle page
    start_new_page

    # Si on ne se trouve pas sur une belle page, on passe encore
    # à la page suivante.
    start_new_page if page_number.even?

    # On indique qu'il ne faudra pas numéroter cette page
    book.page(page_number).pagination = false

    # Mise en forme voulue
    font(ft.title_fonte)

    # On se positionne au bon endroit pour écrire le texte
    move_to_line(ft.title_line)
    options = {
      align: :center,
      leading: ft.title_leading,
      overflow: :shrink_to_fit,
      inline_format: true
    }
    text(ft.title_text, **options)

    if ft.subtitle?
      font(ft.subtitle_fonte)
      move_to_line(ft.subtitle_line)
      options.merge!(leading: ft.subtitle_leading)
      text(ft.subtitle_text, **options)
    end
    
  end

end #/class PrawnView

class FauxTitre
  attr_reader :book, :pdf
  def initialize(book, pdf)
    @book = book
    @pdf  = pdf
  end

  # --- Predicate --- #

  def subtitle?
    not(book.subtitle.nil? || book.subtitle == '')
  end

  # --- Data --- #

  def title_text
    book.title
  end
  # Ligne sur laquelle poser le titre
  def title_line
    data_title[:line] || pdf.line_count / 3
  end
  def title_fonte
    Fonte.get_in(data_title, {size: Fonte.default.size + 4}).or_default
  end
  def title_leading
    data_title[:leading] || 0.2
  end

  def subtitle_text
    book.subtitle
  end
  def subtitle_line
    data_subtitle[:line] || pdf.line_count / 3 + 2
  end
  def subtitle_fonte
    Fonte.get_in(data_subtitle, {size: Fonte.default.size + 2}).or_default
  end
  def subtitle_leading
    data_subtitle[:leading] || 0.0
  end

  def data_title
    @data_title ||= data[:title] || {}
  end

  def data_subtitle
    @data_subtitle ||= data[:subtitle] || {}
  end
  
  def data
    @data ||= begin
      if book.recipe.faux_titre === true
        {}
      else
        book.recipe.faux_titre
      end
    end
  end

end #/class FauxTitre


end #/module Prawn4book
# 
