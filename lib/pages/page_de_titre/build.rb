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
    dtitre = book.recipe.page_de_titre

    pdf.update do

      #
      # Toujours une nouvelle page
      # 
      start_new_page

      #
      # On indique qu'il ne faudra pas numéroter cette page, sauf
      # indication contraire dans la recette
      # 
      unless my.paginate?
        book.pages.without_pagination << page_number
      end

      # 
      # Calculer la position des éléments en fonction de
      # la hauteur de page disponible
      # 
      height = bounds.top - bounds.bottom
      spy "Hauteur efficiente : #{height.inspect}".bleu
      # un_tiers = (height / 3).round # pour le titre

      #
      # LA COLLECTION se place sur la deuxième ligne à partir du
      # haut.
      # 
      if book.in_collection?
        font_coll_title = Fonte.new(dtitre[:collection_title])
        font(font_coll_title)
        move_cursor_to(bounds.top - line_height)
        text( book.collection.name, **{align: :center})
      end

      #
      # Le TITRE DU LIVRE
      # (se place à un tiers)
      #
      font_title = Fonte.new(dtitre[:title])
      font(font_title)
      move_cursor_to(bounds.top - height / 3)
      text( book.title , **{align: :center})

      #
      # S'il y a un SOUS-TITRE, on le place
      # 
      if book.subtitle
        # old_line_height = line_height.dup
        font_subtitle = Fonte.new(dtitre[:subtitle])
        font(font_subtitle)
        subtitle = book.subtitle.split('\\n').compact
        # 
        # Ajout des parenthèses
        # 
        subtitle[0]   = "(#{subtitle[0]}"
        subtitle[-1]  = "#{subtitle[-1]})"
        # 
        # Écriture du sous-titre
        # 
        subtitle.each do |seg|
          text(seg , **{align: :center, leading: 0})
        end
      end

      #
      # Les ou les AUTEURS 
      # 
      move_down(line_height) # une de plus
      font_auteur = Fonte.new(dtitre[:author])
      font(font_auteur)
      text book.recipe.authors.titleize, **{align: :center}

      #
      # La MAISON D'ÉDITION
      # 
      publisher = book.recipe.publisher
      logo      = publisher[:logo_path] 
      # --- logo ---
      logo_height = dtitre[:logo][:height]
      # --- Hauteur de la marque ---
      pub_top = bounds.bottom + 4 * line_height
      if logo
        pub_top += logo_height # + haut
      end
      move_cursor_to(pub_top)
      spy "publisher: #{publisher.inspect}"
      font_publisher = Fonte.new(dtitre[:publisher])
      font(font_publisher)
      text publisher[:name], **{align: :center}

      if logo
        logo_full_path = File.join(book.folder, logo)
        spy "logo_full_path = #{logo_full_path.inspect}"
        image(logo_full_path, {height: logo_height.mm, position: :center})
      end

      # 
      # Le recto
      # 
      start_new_page

    end

    spy "<- Fin de la construction de la page de titre".jaune
  end

  # - Predicate methods -

  def logo?
    :TRUE == @withlogo ||= true_or_false(publisher.logo? && logo)
  end

  def paginate?
    book.recipe.page_de_titre[:paginate] == true
  end

end #/class PageDeTitre
end #/class Pages
end #/module Prawn4book
