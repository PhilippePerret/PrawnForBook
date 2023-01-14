module Prawn4book
class Pages
class PageDeTitre

  # = main =
  #
  # Méthode principale permettant de construire la page
  # 
  def build(pdf)
    spy "\n\n-> Construction de la page de titre".jaune
    book = pdf.pdfbook

    #
    # Les données de fontes
    # 
    dtitre = book.recipe.page_de_titre
    spy "dtitre = #{dtitre.inspect}".bleu

    pdf.update do

      #
      # Toujours une nouvelle page
      # 
      start_new_page

      # 
      # Calculer la position des éléments en fonction de
      # la hauteur de page disponible
      # 
      height = bounds.top - bounds.bottom
      spy "Hauteur efficiente : #{height.inspect}"
      un_tiers = (height / 3).round # pour le titre

      #
      # LA COLLECTION se place sur la deuxième ligne à partir du
      # haut.
      # 
      spy "Font pour collection : #{dtitre[:fonts][:collection_title].inspect}"
      spy "Size pour collection : #{dtitre[:sizes][:collection_title].inspect}"
      font(dtitre[:fonts][:collection_title], size: dtitre[:sizes][:collection_title])
      move_cursor_to(bounds.top - line_height)
      text( "La collection", **{align: :center})

      #
      # Le TITRE DU LIVRE
      # (se place à un tiers)
      #
      font(dtitre[:fonts][:title], size: dtitre[:sizes][:title])
      move_cursor_to(bounds.top - height / 3)
      text( book.title , **{align: :center})

      #
      # S'il y a un SOUS-TITRE, on le place
      # 
      if book.subtitle
        font(dtitre[:fonts][:subtitle], size: dtitre[:sizes][:subtitle])
        subtitle = book.subtitle.split('\\n')
        subtitle.each do |seg|
          text(seg , **{align: :center})
        end
      end

      #
      # Les ou les AUTEURS 
      # 
      move_down(line_height) # une de plus
      font(dtitre[:fonts][:author], size: dtitre[:sizes][:author])
      text book.auteurs, **{align: :center}

      #
      # La MAISON D'ÉDITION
      # 
      publisher = book.recipe.publishing
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
      font(dtitre[:fonts][:publisher], size: dtitre[:sizes][:publisher])
      text publisher[:name], **{align: :center}
    end

    return

    # 
    # L'édition et le logo
    # 
    if publisher
      redef_current_font(v('fonts-publisher'), pdf)
      name_height = pdf.height_of(publisher.name)
      hauteur_totale = name_height
      hauteur_totale += v('logo-height').mm if logo?
      pdf.move_cursor_to(hauteur_totale)
      pdf.text(publisher.name, {align: :center, size:v('sizes-publisher')})
      if logo?
        pdf.image(publisher.logo, {height: v('logo-height').mm, position: :center})
      end
    end

    # 
    # Le recto
    # 
    pdf.start_new_page

    spy "<- Fin de la construction de la page de titre".jaune
  end

  # - Predicate methods -
  def collection? ; :TRUE == @iscollection ||= true_or_false(book.collection?) end
  def logo?
    :TRUE == @withlogo ||= true_or_false(publisher.logo? && logo)
  end

  # - shortcuts -
  def book_title    ; @book_titre ||= book.titre end
  def publisher     ; @publisher ||= book.publisher end
  def book_subtitle ; @book_subtitle ||= book.formated_sous_titre end
  def authors       ; @authors ||= book.formated_auteurs end
  def logo          ; @logo ||= book.publisher.logo end


end #/class PageDeTitre
end #/class Pages
end #/module Prawn4book
