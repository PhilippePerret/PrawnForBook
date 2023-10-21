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
      # Toujours sur une belle page
      # 
      start_new_page if not(belle_page?)

      #
      # On indique qu'il ne faudra pas numéroter cette page, sauf
      # indication contraire dans la recette
      # 
      book.pages[page_number].pagination = not(my.paginate?)

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
        move_to_first_line
        font(recipe.page_titre[:collection_title_font])
        text(book.collection.name, **{align:center})
      end


      #===================
      # - TITRE DU LIVRE -
      #===================
      # (à un tiers)
      font(Fonte.new(dtitre[:title]))
      move_to_line(line_count / 3)
      line_titre = current_line.freeze
      text( book.title , **{align: :center})

      #===============
      # - SOUS-TITRE -
      #===============
      # (if any)
      if book.subtitle
        font(Fonte.new(dtitre[:subtitle]))
        move_to_closest_line
        last_line_subtitle = nil
        move_to_next_line if current_line == line_titre
        ("(#{book.subtitle})").split('\\n').compact.each do |seg|
          text(seg , **{align: :center, leading: 0})
          last_line_subtitle = current_line.freeze
          move_to_next_line
        end
      end

      #============
      # - AUTEURS -
      #============
      # 
      font(Fonte.new(dtitre[:author]))
      move_to_closest_line
      move_to_next_line if current_line == last_line_subtitle
      text(book.recipe.authors.titleize, **{align: :center})
      line_authors = current_line.freeze
      
      #=====================
      # - MAISON D'ÉDITION -
      #=====================
      # 
      publisher   = book.recipe.publisher
      logo        = publisher[:logo_path] 
      logo_height = dtitre[:logo][:height]
      font(Fonte.new(dtitre[:publisher]))
      move_cursor_to(logo_height.mm + 2 * line_height)
      move_to_closest_line
      text(publisher[:name], **{align: :center})
      if logo
        move_cursor_to(logo_height.mm + line_height)
        logo_full_path = File.join(book.folder, logo)
        image(logo_full_path, {height: logo_height.mm, position: :center})
      end

      # 
      # On passe au recto
      # 
      start_new_page

    end

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
