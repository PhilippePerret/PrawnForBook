module Prawn4book
class Printer
class << self

  THIEF_LINE_LENGTH = 7

  # @api
  # 
  # Méthode générique universelle permettant d'écrire du texte :
  #   - sur la grille de référence (quelle que soit la hauteur de 
  #     ligne)
  #   - sans aucune veuve
  #   - sans aucune orpheline
  #   - sans aucune ligne de voleurs
  # 
  # PRINCIPE
  # --------
  # 
  #   V2.0 L'écriture se fait ligne à ligne. C'est de cette manière qu'on
  #   peut gérer les lignes de voleur sur tous les paragraphes ainsi
  #   que les veuves et les orphelines aux changements de pages.
  # 
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
  #   NOTE: PREMIÈRE CHOSE À FAIRE : VOIR COMMENT ON RÉCUPÈRE LA
  #         DERNIÈRE LIGNE D'UN PARAGRAPHE TRAITÉ
  #   NOTE : il faudra étudier :
  #     - un code couleur qui passe d'une page à l'autre
  #     - un code couleur qui commence sur l'avant-dernière ligne et
  #       se termine sur une ligne de voleur.
  #   NOTE : Une fois installé, on pourra regarder si ça règle le 
  #     problème du test "produce/guillemets"
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
  # TODO
  # ----
  # 
  #   Dans une version ultérieure, pour optimiser l'impression (i.e.
  #   l'accélérer), on pourrait ne passer par le ligne à ligne que
  #   lorsque le texte en tient pas entièrement dans la page.
  #   Dans ce système, seule la dernière ligne devra être étudiée
  #   (mais comment ?) pour savoir si elle présente une ligne de
  #   voleur.
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
  #   NOTE: C'est l'instance qui est retournée.
  # 
  # @param pdf [Prawn4book::PrawnView]
  # 
  #   Le document Prawn::Document (PrawnView) en train d'être
  #   construit, qui produira le PDF
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
  #   Table des options telles qu'envoyé à pdf.box_text.
  #   En plus des options régulière, propres à Prawn on peut trouver
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
  #     - Il sera ajouté 'dry_run:true' pour
  #       gérer les orphelines, les veuves et les lignes de voleurs
  #       car l'écriture se fait ligne par ligne (c'est cher mais
  #       c'est précis).
  # 
  # @return owner
  # 
  def pretty_render(pdf:, text:, options:, owner: nil, fonte: nil)

    my = self

    options = defaultize_options(options.dup, pdf)

    owner ||= PdfBook::UserParagraph.new(text, options.merge(fonte:fonte))

    # Le décalage horizontal du texte à écrire
    # 
    left  = options[:at][0]

    # La puce éventuelle
    # 
    puce = options[:puce]

    # - Faut-il se passer du numéro de paragraphe ? -
    # TODO
    no_num = options[:no_num] === true # || pas par recette
     
    pdf.update do

      font(fonte) if fonte

      options.merge!(leading: default_leading)

      str = text.dup

      e, b = text_box(str, options)

      bheight = b.height

      printed_lines = b.instance_variable_get('@printed_lines')
      lines_count = printed_lines.count 


      # 
      # Si la dernière ligne est trop courte, il faut chercher le
      # character_spacing qui permettra de remonter le texte seul
      # à la ligne.
      # 
      last_line = printed_lines.last
      if last_line.length < THIEF_LINE_LENGTH
        # La dernière ligne est trop courte
        char_spacing = my.treate_thief_line_in_par(self, str, options)
        options.merge!(character_spacing: char_spacing)
      end

      puts "Écriture de #{str.inspect}"
      puts "Options d'écriture : #{options.inspect}"
      # move_to_next_line

      # 
      # On calcule la ligne sur laquelle doit être posée le texte
      # 
      # Avant, ce calcul se faisait à l'écart, mais comme il semble
      # qu'il y ait encore des problèmes, je le place ici pour 
      # pouvoir surveiller exactement ce qui se passe, en détaillant
      # 

      # On prend la position actuelle du curseur
      c = cursor # position du curseur
      # Si le cursor est placé plus haut que la limite de la marge
      # haute, on prend le bounds.top qui correspond à la valeur 
      # maximale en haut.
      c = bounds.top if c > bounds.top
      # On calcule la distance entre le bord haut maximum et la 
      # position actuelle du curseur. Ça donne 0 si on est tout en
      # haut.
      d = bounds.top - c 
      # On calcule à combien de lignes cette distance correspond.
      # Normalement, ça doit donner un compte à peu près rond, mais
      # on l'arrondit quand même
      current_line = (d / line_height).round
      # On regarde sur quelle ligne on doit écrire en fonction des
      # ligne qu'on doit passer (quand c'est un titre par exeemple, 
      # ou qu'un titre a été marqué avant)
      lig = current_line
      # On peut calculer très précisément la position du curseur. 
      # Elle correspond à la hauteur haute (par exemple 600) à la-
      # quelle il faut retirer le nombre de lignes multiplié par la
      # hauteur de ligne courante, auquel on ajoute l'ascender ac-
      # tuel (fonction de la fonte) pour que le texte soit parfai-
      # tement posé sur la ligne de référence.
      # (c'est un peu la formule magique).
      top = bounds.top - (current_line * line_height) + ascender
      # On déplace le curseur à cette hauteur-là.
      move_cursor_to(top)

      # Dans les options, il faut retirer le :dry_run qui permettait
      # de construire virtuellement le bloc de texte.
      options.delete(:dry_run)
      # Et il faut régler la hauteur (car dans les options pour cal-
      # culer la ligne, on s'était placé bien en haut pour ne pas
      # avoir de passage à la page suivante)
      options[:at][1] = cursor

      # On doit voir si on va passer à la page suivante. On le sait
      # si la hauteur de curseur actuelle, à laquelle on soustrait 
      # la hauteur du bloc, passe en dessous de zéro (zéro, c'est la
      # limite basse de la page)
      sur_deux_pages = cursor - bheight < 0

      # Il faut traiter le cas du passage à la page suivante. En fait,
      # en calculant ce qui dépasse, on doit pouvoir obtenir le nom
      # bre de lignes qui passe de l'autre côté et le nombre de lignes
      # qui passe
      nb_lines_next_page = (cursor - bheight).abs / line_height
      nb_lines_curr_page = lines_count - nb_lines_next_page  

      if nb_lines_next_page == 1 || nb_lines_curr_page == 1
        # 
        # <= Une veuve ou une orpheline
        # => Il faut faire un traitement particulier
        # 
        # TODO
        puts "Il faut traiter les veuves et les orphelines".rouge
        exit
      else
        text_box(str, options)
        # On se déplace en bas de la hauteur du bloc courant.
        move_down(bheight)
      end

      # On passe toujours sur la ligne suivante
      move_cursor_to(cursor + line_height)


    end


    return

    # On établit d'abord la liste des lignes qu'on aura à écrire, en
    # résolvant les lignes de voleur (il ne doit plus y en avoir).
    # 
    # Ensuite, une fois qu'on a toutes les lignes (sous forme de box),
    # on peut les écrire.
    # 
    begin
      pdf.update do

        font(fonte) if fonte

        # Pile (stack) pour mettre les lignes à écrire du paragraphe
        # 
        # Les lignes ne seront placées qu'à la fin, une fois que l'on
        # sait s'il y a des orphelines, des veuves, des lignes de
        # voleur et des paragraphes à conserver ensemble
        # 
        paragraphe_stack = [] # pour mettre les box avant de les rendre
      

        str = text.dup

        # Tant qu'il reste du texte, on boucle pour faire toutes les
        # lignes (box) du paragraphe.
        while str.length > 0

          # Fabrication du text-box
          # ------------------------
          # text_box est une méthode surclassée pour qu'elle fonc-
          # tionne avec :dry_run (donc qu'elle n'imprime pas le para-
          # graphe et qu'elle retourne en même temps l'excédant, dé-
          # signé par +rest+ ci-dessous le box [Text::Formatted::Box
          # ou Text::Box s'il n'y a pas de formatage.
          # 
          # +rest+  [Array<Hash>] Le texte restant ou une liste vide.
          # +box+   [Text::Formatted::Box|Text::Box]
          # 
          # @note
          # 
          #   On se place toujours tout en haut de la page pour 
          #   qu'aucun calcul de passage à la page suivante ne vienne
          #   perturber la vérification. Noter que quel que soit la 
          #   longueur du paragraphe, il sera traité en entier puis-
          #   qu'on fonctionne toujours ligne à ligne ici.
          # 
          rest, box = text_box(str, **options)

          # spy "rest = #{rest}"

          #
          # S'il reste quelque chose, mais que c'est trop court, il faut
          # jouer sur le kerning du texte courant pour faire remonter le
          # texte ou faire descendre un mot.
          # (<= "Ligne de voleur")
          # 
          # Donc, ici, on va calculer le character_spacing nécessaire.
          # 
          # @note TODO Il faut pouvoir régler la longueur de mot minimum
          #   C'est-à-dire la valeur du THIEF_LINE_LENGTH ci-dessous
          #   et il faut pouvoir le modifier à la volée dans le texte
          # 
          # Noter que ça survient avec l'avant-dernière ligne, la 
          # ligne de voleur est donc la dernière, la suivante, qui
          # se trouve pour le moment dans rest.
          # 
          # Mais pour que la réduction des espaces ne s'applique pas
          # seulement à l'avant-dernière ligne (qui deviendra la 
          # dernière), ce qui serait visible, surtout avec un gros
          # caracter, il faut l'appliquer à tout le paragraphe, donc
          # recommencer le calcul complet. C'est ce que fait la 
          # méthode #treate_thief_line_in_par qui retourne la nouvelle
          # liste de paragraphes (pile) et passe à la suite.
          # 
          has_thief_line = rest.count > 0 && rest.first[:text].length <= THIEF_LINE_LENGTH
          
          if has_thief_line
            #
            # <= Ligne de voleur détectée
            # => Il faut reprendre tout le paragraphe
            # 
            paragraphe_stack = my.treate_thief_line_in_par(pdf, text.dup, **options)

            # On peut s'arrêter là avec la nouvelle pile de 
            # paragraphes.
            break

          end

          has_no_rest = rest.count == 0

          # 
          # On met toujours la ligne (c'est forcément une ligne) dans 
          # le tampon de ligne du paragraphe.
          # 
          paragraphe_stack << box

          break if has_no_rest

          str = my.recompose_from_rest(rest)

        end
        # /loop tant qu'il reste du texte (while str.length > 0)


        # --------------------------------------------------------
        # À partir d'ici, on a dans le tampon de lignes toutes les
        # lignes du paragraphe à écrire.
        # --------------------------------------------------------

        # Faut-il passer à la page suivante pour écrire le premier
        # paragraphe ?
        first_line_on_next_page = cursor - line_height < 0

        start_new_page if first_line_on_next_page

        # is_first_line pour savoir si c'est la première ligne 
        # traitée et gérer les orphelines.
        is_first_line = true

        # On boucle sur toutes les lignes pour les écrire
        # À chaque ligne écrite il faut déplacer le curseur sur la 
        # ligne suivante.
        # 
        while boxline = paragraphe_stack.shift

          # Nombre de lignes restantes
          nombre_restantes = paragraphe_stack.count

          is_penultimate_line = nombre_restantes == 1

          if is_first_line && (nombre_restantes > 0) &&  cursor - 2 * line_height < 0
            # => Orpheline
            # => Passer tout de suite à la page suivante
            start_new_page

          elsif is_penultimate_line && cursor - 2 * line_height < 0
            # => La suivante serait une Veuve
            # => Passer tout de suite à la page suivante pour que
            #    la ligne suivante ne soit pas seule.
            start_new_page

          end

          # Réglage de la position exacte du cursor
          # move_to_closest_line
          # correct_cursor_position(boxline.text)
          boxline.at = [left, cursor]

          ##############################
          ### IMPRESSION DE LA LIGNE ###
          ##############################
          boxline.render

          # -- PUCE --
          my.print_puce(self, puce) if is_first_line && puce

          # -- On se place sur la ligne suivante --
          move_to_next_line

          is_first_line = false
        end

      end #/pdf

    rescue PrawnFatalError => e
      raise e
    rescue Exception => e
      raise FatalPrawnForBookError.new(100, {
        text: text.inspect, 
        err:  e.message, 
        backtrace:(debug? ? e.backtrace.join("\n") : '')
      })
    end
    
    return owner
  end #/pretty_render

  # Écriture de la puce, si nécessaire
  def print_puce(pdf, puce)
    puce_options = {
      at: [ (puce[:hadjust]||0), pdf.cursor + (puce[:vadjust]||0)]
    }
    if puce[:text].downcase.match?(REG_IMG_EXTENSION)
      puce_image_path = book.existing_path(puce[:text]) || raise(FatalPrawnForBookError.new(102, {path:puce[:text]}))
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

    # La nouvelle pile des paragraphes récolté, quand le character-
    # spacing sera appliqué au paragraphe.
    paragraphes_stack = []

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

      spy "CS trouvé pour le paragraphe « #{str[0..60]} […] » : #{cs}".bleu


      # NOUVELLE MÉTHODE : ON RETOURNE SEULEMENT L'ESPACE
      return cs # character_spacing



      # Découpage du paragraphe en ligne (sans avoir plus rien à 
      # surveiller puisque la ligne de voleur a été remontée)


      options = options.merge!(kerning: true, character_spacing: cs)

      options[:at][1] = pdf.bounds.top

      # Ramassage de tous les paragraphes
      # 
      while str.length > 0
        rest, box = text_box(str, **options)
        paragraphes_stack << box
        break if rest.count == 0
        str = my.recompose_from_rest(rest)
      end #/while

    end #/pdf.update
  
    return paragraphes_stack
  end #/ #treate_thief_line_in_par


  # Reçoit le "reste" d'une opération de text_box sur une partie du
  # texte et recompose le texte initial.
  # 
  # 1)  C'est dommage d'avoir à faire ça mais heureusement, ça n'ar-
  #     rive que lorsqu'on a une ligne de voleur
  #     FAUX : ça arrive pour chaque paragraphe…
  # 
  # 2)  C'est l'opération inverse de Prawn::Text::Formatted:: \
  #     Parser.format(str, []) qui prend le str et le transforme
  # 
  # SOLUTION
  #   Une solution pour régler ça serait de ne traiter par ligne que
  #   les textes qui dépasserait de la page pour aller sur la page
  #   suivante…
  # 
  # Propriétés d'un fragment dont je ne tiens pas compte :
  #   :local, :link, :anchor, :character_spacing
  # 
  def recompose_from_rest(rest)
    rest.map do |fragment|
      t  = fragment[:text]
      font    = fragment[:font]
      size    = fragment[:size]
      color   = fragment[:color]
      fragment[:styles].each do |sty|
        t = case sty
        when :italic      then "<em>#{t}</em>"
        when :bold        then "<b>#{t}</b>"
        when :underline   then "<u>#{t}</u>"
        when :superscript then "<sup>#{t}</sup>"
        when :subscript   then "<sub>#{t}</sub>"
        else t
        end
      end
      font_props = {}
      font_props.merge!(name: font)    if font
      font_props.merge!(size: size)    if size
      font_props.merge!(color: color)  if color
      unless font_props.empty?
        props = font_props.map { |k,v| "#{k}=\"#{v}\""}.join(' ')
        t = FONT_TAG % {props: props, str: t}
      end
      t # pour le map
    end.join('')
  end
  FONT_TAG = '<font %{props}>%{str}</font>'.freeze


  # Pour régler toutes les valeurs par défaut dans les options
  # transmises à pretty_render
  # 
  def defaultize_options(options, pdf)

    # Pour pouvoir gérer ligne à ligne, il faut toujours que 
    # :dry_run et :single_line soit à true
    # options.merge!(dry_run: true, single_line: true)
    # Version 2.1 : on ne passe plus par le ligne à ligne (qui casse
    # tout au niveau des styles et des balises HAML)
    options.merge!(dry_run: true)

    # On part toujours du principe qu'un paragraphe comporte du
    # format HTML, même si ça coûte plus cher
    options.merge!(inline_format: true)

    # Dans tous les cas, il faut que l'on ait les propriétés :
    # :at, :left, :width
    left = options[:left] || options.delete(:margin_left)
    if options[:at]
      left ||= options[:at][0]
    end
    left ||= 0

    right = options.delete(:right) || options.delete(:margin_right)
    if options[:width]
      right ||= left + options[:width]
    end
    right ||= pdf.bounds.width

    width = options[:width]
    width ||= right - left

    # Ce qu'il va rester dans les options
    # 
    # @note
    #   Par défaut, on met le paragraphe (test) tout au-dessus pour
    #   qu'on n'ait pas de passage inopportun à la page suivante 
    #   pendant le calcul.
    # 
    options.merge!(
      at: [left, pdf.bounds.height],
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

end #/ << self Prawn4book::Printer
end #/ class Printer
end #/ module Prawn4book
