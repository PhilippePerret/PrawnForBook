module Prawn4book
class Printer
class << self

  THIEF_LINE_LENGTH = 10

  # @api
  # 
  # Méthode générique universelle permettant d'écrire du texte :
  #   - sur la grille de référence (quelle que soit la hauteur de 
  #     ligne)
  #   - sans aucune veuve
  #   - sans aucune orpheline
  #   - sans aucune ligne de voleurs
  # 
  # NOTE CAPITALE
  # -------------
  #   LES TITRES [NTitle] NE PASSENT PAS PAR CETTE MÉTHODE (et c’est
  #   bien dommage)
  # 
  # PRINCIPE
  # --------
  # 
  #   OBSOLÈTE
  #   V2.0 L'écriture se fait ligne à ligne. C'est de cette manière qu'on
  #   peut gérer les lignes de voleur sur tous les paragraphes ainsi
  #   que les veuves et les orphelines aux changements de pages.
  # 
  #   ACTUELLEMENT
  #   V2.1 Le problème de la formule précédente, c'est que dès qu'il
  #   y a du code dans le paragraphe (par exemple pour un changement
  #   de couleur), s'il se trouve que le <color ...> se trouve sur 
  #   une ligne (voire même découpé) et que le </color> se trouve sur
  #   une autre ligne, alors la couleur n'est tout simplement pas 
  #   appliquée… La solution serait de coloriser chaque mot avec ces
  #   balises, dès qu'il y en a, et de le faire avant tout changement
  #   de balise (italique, gras, fonte, etc.) mais ça me semble par-
  #   ticulièrement dispendieux…
  #   L'autre solution est de continuer de traiter en paragraphe, 
  #   avec le leading, et de ne faire une exception que pour les 
  #   fins de ligne en ligne de voleur.
  #   Donc :
  #     - on traite par paragraphe
  #       (entre autres choses, on applique le leading adéquat)
  #     - 1. on regarde si la dernière ligne est une ligne de voleur
  #     -    le cas échéant, on la traite pour la supprimer. Ça ne 
  #          changera que le character_spacing, mais on gardera le
  #          paragraphe ensemble
  #     - 2. on regarde si le texte va être découpé d'une page à
  #          l'autre. Si c'est le cas, on étudie les veuves et les
  #          orphelines.
  #     - On procède à l'écriture. 
  # 
  #   Les fausses tables, quand elles passent par ici, fonctionnent
  #   colonne par colonne, en récupérant le curseur et la hauteur 
  #   pour gérer la prochaine colonne.
  #   @rappel : les "fausses-tables" ne fonctionnent pas avec les
  #   Prawn::Table, qui gèrent mal les lignes de référence pour le
  #   moment, mais avec des paragraphes simplement définis au niveau
  #   de leur left et leur width (dans :at et :width) pour simuler
  #   des tables ou des affichage tabulaires, plutôt.
  # 
  # 
  # PARAMÈTRES
  # ----------
  # 
  # @param owner [AnyClass|Nil] 
  #   
  #   Le propriétaire qui fait la demande, a du +text+ à écrire, la 
  #   plupart du temps un [PdfBook::NTextParagraph].
  #   Si nil, c'est un Prawn4book::PdfBook::UserParagraph qui est
  #   initié.
  #   NOTE: L'instance est retournée.
  # 
  # @param pdf [Prawn4book::PrawnView]
  # 
  #   Le document Prawn::Document (PrawnView) en train d'être
  #   construit, qui produira le PDF en fin de processus.
  # 
  # @param text [String|Formatted String]
  # 
  #   Le texte à écrire.
  # 
  # @param fonte [Prawn4book::Fonte]
  # 
  #   L'instance Fonte de la fonte.
  # 
  # @param options [Hash]
  # 
  #   Table des options telles qu'envoyée à pdf.box_text.
  #   En plus des options régulières, propres à Prawn on peut trouver
  #   aussi :
  #   :puce     qui définit une puce (typiquement utilisé pour les
  #             paragraphe qui sont des items de liste). C'est soit
  #             un caractère seul, soit une table définissant :
  #             :text     Le texte à utiliser pour la puce
  #             :vadjust  L'ajustement vertical en points
  #             :hadjust  L'ajustement horizontal en points
  #             :left     L'écart avec le texte (le déplacement du texte)
  #             :size     La taille de la puce
  #   :no_num   Si true, on ne doit pas marquer de numéro de paragraphe
  # 
  #   @notes
  # 
  #     - Il sera ajouté 'dry_run:true' pour
  #       gérer les orphelines, les veuves et les lignes de voleurs.
  # 
  #     - Les titres ont leur propre méthode de gravage, ils ne 
  #       passent pas par ici.
  # 
  # @return owner (pour l’avoir quand il est instancié ici)
  # 
  def pretty_render(pdf:, text:, options:, owner: nil, fonte: nil)

    # RAPPEL
    # ------
    # Les titres ne passent pas par cette méthode
    # 

    my = self

    options = defaultize_options(options.dup, pdf)

    owner ||= PdfBook::UserParagraph.new(pdf, text, options.merge(fonte:fonte))

    # Le décalage horizontal du texte à écrire
    # 
    left  = options[:at][0]

    # La puce éventuelle
    # 
    puce = options[:puce]

    # - Faut-il se passer du numéro de paragraphe ? -
    # TODO
    no_num = options[:no_num] === true # || pas par recette
     
    begin

      pdf.update do

        font(fonte) if fonte

        # # /débug
        # if page_number > 18 && text.match?(/Recette.+collection/i)
        #   puts"\ncursor au tout départ : #{cursor.round(3)}".bleu
        # end

        # Si le curseur est déjà sous le zéro, on passe directement
        # à la page suivante
        # 
        # @rappel
        #   Les titres ne passent pas par cette méthode. Cf. 
        #   NTitre#build
        #   
        # if cursor < 0
        if cursor < line_height
          start_new_page
          move_to_line(1)
        end

        # La fonte est définie, on peut définir le leading du texte
        options.merge!(leading: default_leading)

        str = text.dup

        debugit = false # str.match?('Le grand titre à utiliser pour la table des matières')

        e, b = text_box(str, options.merge(dry_run: true))

        boxheight = b.height

        # Un peu hackish… mais permet de régler le bug #147
        # Quand il y a une puce (vraiment nécessaire ?), et un seul
        # paragraphe dans le texte, et que la boite excède la place
        # restante, on passe directement à la page suivante.
        #   @note
        #     Peut-être faudra-t-il le faire mais sans puce, lorsque 
        #     le texte possède un left ?
        # 
        if puce && cursor - boxheight < 0 && str.count("\n") == 0
          start_new_page
          move_to_line(1)
        end

        # if debugit
        #   puts "cursor : #{cursor}".bleu
        #   puts "boxheight : #{boxheight}".bleu
        #   exit 112
        # end

        printed_lines = b.instance_variable_get('@printed_lines')
        lines_count = printed_lines.count

        # Y a-t-il une ligne de voleur ?
        has_thief_line = lines_count > 1 && printed_lines.last.length < THIEF_LINE_LENGTH

        # Si la dernière ligne est trop courte, il faut chercher le
        # character_spacing qui permettra de remonter le texte seul
        # à la ligne.
        # 
        if has_thief_line
          # puts "Ligne de voleur !".rouge
          # La dernière ligne est trop courte
          char_spacing = my.treate_thief_line_in_par(self, str, options)
          # puts "Character spacing: #{char_spacing}".bleu
          options.merge!(character_spacing: -char_spacing)
          # La hauteur diminue donc d'une ligne, ainsi que le nombre
          # de lignes
          boxheight   -= line_height
          lines_count -= 1
        end

        # On doit voir si on va passer à la page suivante. On le sait
        # si la hauteur de curseur actuelle, à laquelle on soustrait 
        # la hauteur du bloc, passe en dessous de zéro (zéro, c'est la
        # limite basse de la page)
        sur_deux_pages = cursor - boxheight < 0

        # # /débug
        # if page_number > 18 && text.match?(/Recette.+collection/i)
        #   puts "\n"
        #   puts "cursor = #{cursor.round(3)}".bleu
        #   puts "boxheight = #{boxheight.round(3)}".bleu
        #   puts "cursor - boxheight = #{cursor - boxheight}".bleu
        #   puts "sur_deux_pages est #{sur_deux_pages.inspect}".bleu
        #   exit 100
        # end

        # Il faut traiter le cas du passage à la page suivante. En fait,
        # en calculant ce qui dépasse, on doit pouvoir obtenir le nom
        # bre de lignes qui passe de l'autre côté et le nombre de lignes
        # qui passe
        if sur_deux_pages
          nb_lines_next_page = ((cursor - boxheight).abs / line_height).ceil
          nb_lines_curr_page = lines_count - nb_lines_next_page
        else
          nb_lines_next_page = 0
          nb_lines_curr_page = lines_count
        end

        # puts "Nombre lignes : #{lines_count} / On current page:#{nb_lines_curr_page} / On next page:#{nb_lines_next_page}".bleu

        parag_has_orphan = nb_lines_curr_page == 1 && lines_count > 1
        parag_has_widow  = nb_lines_next_page == 1
        
        # Gestion d'une orpheline
        # 
        # On la traite ici car il y a juste à passer à la page 
        # suivante et se placer sur la première ligne. Tout le reste
        # est identique.
        # 
        if parag_has_orphan
          start_new_page # normalement, se place sur la ligne 2
          move_to_line(1)
          # Pour passer au bon endroit ensuite
          nb_lines_curr_page = lines_count
          nb_lines_next_page = 0
        end

        # Et il faut régler la hauteur (car dans les options pour cal-
        # culer la ligne, on s'était placé bien en haut pour ne pas
        # avoir de passage à la page suivante)
        options[:at][1] = cursor

        # puts "Options avant écriture : #{options.inspect}".jaune

        # - Par défaut -
        excedent = nil

        if parag_has_widow
          # 
          # <= Une veuve
          # 
          # => Il faut réduire le text box courant d'une ligne pour
          #    obliger le texte à passer sur la page suivante
          # 
          options.merge!(height: (nb_lines_curr_page - 1) * line_height)

        elsif nb_lines_next_page > 1
          #
          # Le reste de page ne permet pas d'écrire tout le texte,
          # mais aucun problème de veuve n'a été détecté. Donc on
          # écrit sur cette page, puis sur l'autre.
          # (ce sera géré automatiquement par l'excédent)

        else
          #
          # Le cas normal : on écrit le texte sur la page courante
          # 
          
        end

        # = PUCE =
        # ========
        # (if any)
        puce_printed = puce && my.print_puce(self, puce)

        # Si le paragraphe est tout en haut et qu’il a dû être 
        # indenté (*), il faut supprimer l’indentation
        # 
        # (*) Dans PFB, l’indentation se gère avec des espaces car
        # Prawn ne sait pas calculer les dimensions avec une indenta-
        # tionsinon des paragraphes
        if current_line == 1 && owner.indentation && owner.indentation > 0 && str.start_with?('<font name="Courier"')
          str = str.sub(/^<font(.+?)<\/font>/,'')
        end

        # 
        # Dans tous les cas, on écrit le texte en récupérant 
        # l'excédant (qui peut ne pas exister)
        # 
        # puts "Options (1er) : #{options.inspect}".bleu
        excedent = text_box(str, **options)

        # puts "excedent = #{excedent.inspect}".jaune

        # 
        # Gestion de l'excedent quand il y en a
        # 
        if excedent.empty?
          # - Sans excédant, on descend simplement le curseur de 
          #   la hauteur du box -
          move_down(boxheight)
          update_current_line
        else
          # - Impression de l'exédent -
          start_new_page
          move_to_line(1)
          if puce && not(puce_printed)
            my.print_puce(self, puce)
            options[:at][0] = left
          end
          options[:at][1] = cursor
          options.delete(:height)
          old_at = options.delete(:at)

          # formatted_text_box(excedent, **options)
          # Si on continue d'utiliser formatted_text au lieu de
          # formatted_text_box, il ne faut plus :at
          # 
          if left > 0
            bounding_box(old_at, width: bounds.width - left) do
              formatted_text(excedent, **options)
            end
          else
            formatted_text(excedent, **options)
          end

          update_current_line
        end

        # On passe à la ligne suivante
        move_to_next_line

      end #/pdf

    rescue PrawnFatalError => e
      raise e
    rescue Exception => e
      raise PFBFatalError.new(100, {
        text: text.inspect, 
        err:  e.message,
        error: e,
        backtrace:(debug? ? true : '(ajouter -debug pour voir le backtrace)')
      })
    end
    
    return owner
  end #/pretty_render

  # Écriture de la puce, si nécessaire
  # 
  # @return true si la puce a pu être marquée, false dans le cas
  # contraire.
  # 
  def print_puce(pdf, puce)
    # Si la puce doit être marquée après le passage à la page
    # suivante
    return false if pdf.cursor < 0
    puce_options = {
      at: [ (puce[:hadjust]||0), pdf.cursor + (puce[:vadjust]||0)]
    }
    if puce[:text].downcase.match?(REG_IMG_EXTENSION)
      puce_image_path = book.existing_path(puce[:text]) || raise(PFBFatalError.new(102, {path:puce[:text]}))
      pdf.update do
        image_options = puce_options.merge({
          position:   :center,
        })
        image_options.merge!(height: puce[:height]) if puce[:height]
        image_options.merge!(width: puce[:size]) if puce[:size]
        image(puce_image_path, **image_options)
      end
    else
      pdf.update do
        puce_options.merge!({
          inline_format: true,
          size:   puce[:size],
          width:  puce[:left],
          at: [ (puce[:hadjust]||0), cursor + (puce[:vadjust]||0)]
        })
        float do
          text_box(puce[:text], **puce_options) 
        end
      end
    end
    return true
  end
  REG_IMG_EXTENSION = /\.(png|jpg|jpeg|tiff|svg)$/.freeze

  def book
    PdfBook.ensure_current
  end

  ##
  # Contrairement à la méthode suivante, ici, on traite la ligne de
  # voleur avec tout le paragraphe, pas seulement avec la ligne qui
  # précède la ligne de voleur.
  # Et on retourne le stack de paragraphes
  def treate_thief_line_in_par(pdf, str, **options)

    my = me = self

    snap    = 0.01
    last_cs = 0.0 # pour revenir toujours au cs précédent qui a "dépassé"
    cs      = 0.0 # pour l'exposer ("cs" pour "Character Spacing")

    #
    # Préparer +opts+ pour recevoir les options qui vont être utiles
    # pour l'opération.
    # 
    opts = {
      at:                 options[:at], 
      width:              options[:width], 
      align:              options[:align],
      kerning:            true,
      character_spacing:  0,
      inline_format:      options[:inline_format],
    }

    pdf.update do

      # Transformation du paragraphe en segment suivant le
      # formatage.
      ary = Prawn::Text::Formatted::Parser.format(str, [])

      # Hauteur actuelle du paragraphe, sans kerning
      opts_pur = opts.dup
      opts_pur.delete(:indent_paragraphs)
      normal_height = height_of_formatted(ary, **opts)

      curr_height = normal_height.dup
      while snap > 0.0000001
        cs = last_cs # [1]
        while true
          cs += snap
          opts.merge!(character_spacing:-cs)
          ######################
          ### HAUTEUR TESTÉE ###
          ######################
          curr_height = height_of_formatted(ary, **opts)
          # Si la nouvelle hauteur est inférieure à la hauteur 
          # sans kerning, c'est qu'on a réussi à remonter la ligne
          # de voleur.
          break if curr_height < normal_height
          # Sinon, on continuen, en mémorisant le cs actuel (pour le
          # reprendre et affiner quand on aura dépassé — cf. plus
          # haut en [1])
          last_cs = cs.dup
        end
        snap = snap / 10 # cran, p.e. 0.001 -> 0.0001
      end

      # NOUVELLE MÉTHODE : ON RETOURNE SEULEMENT L'ESPACE
      return cs # character_spacing

    end #/pdf.update
  
    return paragraphes_stack
  end #/ #treate_thief_line_in_par


  # Pour régler toutes les valeurs par défaut dans les options
  # transmises à pretty_render
  # 
  def defaultize_options(options, pdf)

    # On part toujours du principe qu'un paragraphe comporte du
    # format HTML, même si ça coûte plus cher
    options.merge!(
      inline_format:  true,
      kerning:        true,
    )

    # Il faut toujours couper le texte si nécessaire
    options.merge!(overflow: :truncate)

    # Dans tous les cas, il faut que l'on ait les propriétés :
    # :at, :left, :width
    left = options[:left] || options.delete(:margin_left)
    if options[:at]
      left ||= options[:at][0]
    end
    left ||= 0

    # - Étude de :right et :width -
    # Normalement, on ne doit pas pouvoir avoir les deux en même
    # temps, car les deux définissent la même chose : la largeur du
    # texte. Donc, si :width est défini, c’est elle seule qui fait
    # autorité même si :right est défini, si :right seul est défini,
    # il faut autorité
    right = options.delete(:right) || options.delete(:margin_right) || 0
    # - Largeur résultante -
    width = 
      if 
        options[:width]
      elsif right
      elsif left
        pdf.bounds.width - left
      else
        pdf.bounds.width
      end

    width = options[:width] || (pdf.bounds.width - (left + right))

    # Ce qu'il va rester dans les options
    # 
    # @note
    #   Par défaut, on met le paragraphe (test) tout au-dessus pour
    #   qu'on n'ait pas de passage inopportun à la page suivante 
    #   pendant le calcul.
    # 
    options.merge!(
      at: [left, pdf.bounds.height],
      align: options[:align] || :justify,
      width: width
    )

    # - Puce -
    # 
    # Il faut que ce soit une table définissant :content, :vadjust
    # et :hadjuste
    if options.key?(:puce) && options[:puce].is_a?(String)
      options[:puce] = {text: options[:puce]}
    end

    return options
  end
  #/defaultize_options

end #/ << self Prawn4book::Printer
end #/ class Printer
end #/ module Prawn4book
