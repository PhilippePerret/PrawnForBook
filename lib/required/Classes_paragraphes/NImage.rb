require_relative 'AnyParagraph'
require 'fastimage'

module Prawn4book
class PdfBook
class NImage < AnyParagraph

  # @public
  # 
  # Méthode qui parse le code contenu à l'intérieur d'un ![...]
  # dans le fichier source (ou IMAGE[...] pour la régression).
  # @note : ce code doit se trouver seul sur la ligne où l’image
  # doit être insérée
  # 
  # @param dimg [String] Intérieur de IMAGE[...]
  # 
  # @return [Hash] Les données pour l'image
  # 
  def self.parse(dimg)
    case dimg
    when NilClass
      {}
    when /^\{(.+)\}$/.freeze
      eval($1)
    else
      eval("{#{dimg}}")
    end
  end

  attr_reader :filename
  attr_reader :data
  attr_reader :pdf

  # [Integer] Numéro de page de l’image/illustration
  attr_accessor :page

  def initialize(book:, path:, data_str:, pindex:)
    super(book, pindex)
    @type = 'image'
    @data = NImage.parse(data_str)
    @filename = path
  end


  # --- Printer Methods ---

  def me
    @me ||= "Image #{picture_name} (#{legend.to_s.gsub('<br>',' ')}"
  end

  def reset
    @left   = nil
    @right  = nil
    @width  = nil
    @height = nil
  end

  ##
  # Méthode principale qui "imprime" le paragraphe dans le PDF
  # du livre
  # 
  # Reprise de la réflexion sur le calcul des mesures de l’image. 
  # Au maximum, on doit définir :
  #   - width       La largeur de l’image, en pt-ps, ou non
  #   - height      La hauteur de l’image, en pt-ps, ou non
  #   - left        La position gauche définie, ou par défaut (0)
  #   - right       La position droite définie ou non
  #   - top         La valeur verticale
  #     at: [left, top]
  # 
  # Si rien n’est défini, ni :width, ni :height n’ont à être définis
  # dans les données de l’image, que ce soit pour les images normales
  # ou les images svg
  # Si :width et :right sont définis, l’image peut être déformée, 
  # les valeurs doivent être définis dans les données de l’image
  # 
  # Les valeurs contextes susceptibles de modifier les valeurs :
  #   La largeur de la page qu’aucune image ne peut exéder (pour le
  #   moment, c’est-à-dire jusqu’au moment où on pourra "cadrer" une
  #   image — et donc ce sera le cadre qui sera important)
  # 
  # 
  # [002] Image flottante  (floating? est true)
  #   Depuis décembre 2023, on peut utiliser des images flottantes, 
  #   ce qui reste extrêmement compliqué avec prawn. Voilà comment on
  #   procède à cette opération :
  #   - on place l’image dans la page, avec une certaine taille, donc
  #     une certaine largeur qui laissera passer du texte. Si l’image
  #     flotte à gauche, c’est à droite que se positionnera le texte,
  #     si l’image flotte à droite, c’est à gauche que se positionne-
  #     ra le texte.
  #     La valeur :
  #         LARGEUR_PAGE - (TAILLE_IMAGE + ESPACE_AVEC_TEXTE)
  #     … détermine la largeur disponible avec le texte.
  #   - on peut avoir un texte passant au-dessus de l’image en jouant
  #     sur le paramètre :margin_top qui détermine le flottement de
  #     l’image avec le haut. On ne peut pas déterminer le flottement
  #     avec le bas, car il faudrait alors déterminer la hauteur 
  #     prise par le texte.
  #   - une fois qu’on a ces valeurs, en imaginant un texte très long
  #     on aura un text-box au-dessus pour le début du texte, d’une
  #     taille correspondant à margin_top, ensuite un text-box de la
  #     largeur laissée par l’image et de la hauteur de l’image + le
  #     float_bottom qui permettra de laisser de l’air sous l’image
  #     avant le texte.
  #   - et enfin un text-box sous l’image, pour mettre l’exédant de
  #     texte s’il y en a.
  # 
  def print(pdf)
    # spy(:on) if first_turn? && floating?

    my = self # ATTENTION : pas "me"

    exist? || begin
      add_erreur(PFBError[250] % {filename:filename}) if Prawn4book.first_turn?
      return false
    end

    # Reset (surtout pour le second tour)
    reset

    # Exposer à toute l’instance
    @pdf = pdf

    # Si des styles propres ont été définis dans le paragraphe
    # précédent l’image, on les traite ici.
    get_and_calc_styles

    # Pour surveiller l’erreur de page (cf. page_number_fin plus
    # bas)
    page_number_debut = pdf.page_number.freeze

    # Il faut mettre le style par défaut
    # 
    pdf.font(Fonte.default_fonte, **{size:Fonte.default_fonte.size})

    # Table où seront consignés les données de l’image
    @data_image = {}

    # Rectifier les valeurs si elles sont définies et trop grandes
    rectify_height if height
    rectify_width
    rectify_height unless height

    # - Positionnement de l'image -
    
    if left > 0
      spy "left est défini et vaut #{left.inspect}".jaune
      @data_image.merge!(at: [left, pdf.cursor - pdf.line_height])
    elsif right > 0
      spy "right est défini et vaut #{right.inspect}".jaune
      lf = pdf.bounds.width - (calc_width + right)
      @data_image.merge!(at: [lf, pdf.cursor - pdf.line_height])
    else
      @data_image.merge!({
        position: @data[:align] || begin
          floating? ? (float_left? ? :left : :right) : :center
        end
      })
    end

    # - Passer à la page suivante s’il reste trop peu de hauteur -
    # Non, il n’y a rien à faire, ça se fait tout seul
    # car l’image va passer naturellement à la page suivante
    if calc_height > pdf.cursor
      spy "Il reste trop peu de hauteur pour mettre l’image"
      if @data_image.key?(:at)
        @data_image[:at][1] = pdf.bounds.top
      end
    end

    if svg?
      @data_image.merge!(color_mode: :cmyk)
    end

    # spy "Image:       #{filename}".bleu
    # spy "Légende:     #{legend}".bleu if legend
    # spy <<~EOD.bleu
    #   (taille page : #{pdf.bounds.width.round(2)} x #{pdf.bounds.height.round(2)})
    #   Original W: #{original_width.inspect}
    #   Original H: #{original_height.inspect}
    #   Explicit W: #{width.inspect}
    #   Explicit H: #{height.inspect}
    #   Calc W:     #{calc_width} 
    #   Calc H:     #{calc_height} 
    #   Scale:      #{scale.inspect}
    #   left:       #{left.inspect}
    #   right:      #{right.inspect}
    #   position legend: #{position_legend}
    #   left legend: #{left_legend}
    #   -----------
    #   Data image: #{@data_image}
    #   EOD


    # Propriété à sortir (pour le scope dans pdf)
    # 
    img_path = path
    # mg_bottom = margin_bottom

    data_image = @data_image

    floating_data = {} if floating? # [002]

    debugit = false # true


    pdf.update do

      # S’il y a de l’espace à laisser avant
      if my.space_before != 0
        data_image[:at][1] -= my.space_before if data_image.key?(:at)
        # Dans tous les cas, on se déplace vers le bas
        move_down(my.space_before)
      end

      # S’il y a un ajustement vertical précis
      # (mais en vérité, cet ajustement ne doit absolument concerner
      #  que l’image et sa légende, donc il ne faut pas le traiter
      #  ici mais au tout dernier moment — cf. plus bas)
      # Le premier résultat (seulement l’image) a été obtenu en 
      # commentant la ligne [L1] ci-dessous
      if my.vadjust != 0
        if data_image.key?(:at)
          @not_vadjusted = false
          data_image[:at][1] -= my.vadjust
        else
          @not_vadjusted = true
          # puts "vadjust à #{my.vadjust} mais pas bougée".rouge
          # exit 16
        end
        # Dans tous les cas, on se déplace vers le bas
        # move_down(my.vadjust) # [L1]
      end

      # Si l’image est flottante
      if my.floating? # [002]
        # La première chose à faire, pour une image flottante, est
        # de mémoriser le cursor courant, qui va correspondre au 
        # curseur du premier text-box de texte.
        move_to_closest_line
        floating_data.merge!(textbox1_top: cursor.freeze)
        rule('FF0000',0.3) if debugit # haut de l’image (rouge)
        if my.lines_before > 0
          # move_down(my.lines_before * pdf.line_height + my.margin_top + 3)
          move_down(my.lines_before * pdf.line_height + 3)
          if data_image[:at]
            data_image[:at][1] = cursor.freeze - my.vadjust
          end
          rule('008800') if debugit
        # elsif my.margin_top != 0
        #   move_down(my.margin_top)
        end
        floating_data.merge!(textbox2_top: cursor.freeze)
        rule('00FFFF') if debugit
        if my.margin_top != 0
          move_down(my.margin_top)
          rule('0000FF') if debugit
        end
        # Ensuite, on définit sa valeur :left et son alignement s’il
        # n’est pas défini
        data_image[:left] = 
          if my.float_left? 
            my.margin_left 
          else 
            my.page_width - (my.calc_width + my.margin_right)
          end
        if data_image[:at]
          data_image[:at][0] = data_image[:left]
        else
          data_image.merge!(at: [data_image[:left], cursor])
        end
      end

      cursor_before = cursor.freeze
      image_top = (data_image.key?(:at) ? data_image[:at][1] : cursor_before).freeze

      if my.vadjust != 0 && @not_vadjusted
        if data_image.key?(:at)
          data_image[:at][1] -= my.vadjust
        else
          # Tentative très dangereuse par move_down (qui risque de
          # tout déplacer n’importe comment)
          move_down(my.vadjust)
        end
      end

      # Consigner le numéro de page, on en aura besoin pour la
      # liste des illustrations
      my.page = page_number.freeze

      #######################
      ###      IMAGE      ###
      #######################
      if my.svg?
        # Pour le moment, je ne sais pas gérer la rotation,
        # il faut tourner l’image d’origine et mettre la
        # bonne largeur/hauteur
        image = svg(IO.read(img_path), **data_image)
        # Hauteur prise par l'image
        image_height = image[:height]
        image_width  = image[:width]
      else
        image = image(img_path, **data_image)
        # Hauteur prise par l'image
        image_height = image.scaled_height
        image_width  = image.scaled_width
      end

      cursor_after = cursor.freeze

      if cursor_after == cursor_before
        move_down(image_height)
      elsif cursor_after < (cursor_before - image_height)
        # puts "Le curseur n’est pas tout à fait en dessous pour #{my.me}".orange
      else
        # puts "Le curseur est bien placé#{he}".vert
      end

      #########################
      ###       LÉGENDE     ###
      #########################
      if my.legend
        # Calculer les options pour la légende
        my.legend_options({image_width:image_width})
        bounding_box(
          [my.left_legend, cursor - (my.vadjust_legend + my.vadjust)], 
          position: my.position_legend,
          width: my.legend_options[:width]
        ) do
          text(my.legend, **my.legend_options)
        end
      end

      if my.svg?
        move_down(line_height)
      end

      if my.space_after != 0
        move_down(my.space_after)
        update_current_line
        move_to_closest_line
      end

      if my.floating?
        # J’essaie de mémoriser le cursor actuel pour le remettre 
        # après l’écriture du texte.
        last_cursor = cursor.freeze

        update_current_line
        move_to_closest_line
        if cursor > last_cursor # <= line de référence au-dessus
        end
        move_to_next_line
        if my.margin_bottom != 0
          move_down(my.margin_bottom)
        end
        floating_data.merge!(textbox3_top: cursor.freeze)
        rule(:jaune) if debugit

        ###################################
        ###   TEXTE AUTOUR DE L’IMAGE   ###
        ###################################

        # Écriture du texte autour de l’image
        # 
        # @note
        #   Dans certains cas, lorsque le texte se finit sur l’autre
        #   page par exemple, il ne faut pas déplacer le curseur ici
        #   Dans ces cas-là, la méthode retourne false qui est mis 
        #   dans +move_after+
        move_after = my.print_text_around_image(floating_data)
        # Où faut-il se placer (cursor) ensuite ?

        if move_after
          best_cursor = [
            image_top - image_height - line_height, 
            cursor, 
            floating_data[:textbox3_top], 
            last_cursor
          ].min.freeze
          # spy "Meilleur curseur obtenu : #{best_cursor}".bleu
          move_cursor_to(best_cursor)
          move_to_closest_line
        end
        # Dans tous les cas, on passe à la ligne suivante ?
        move_to_next_line

      else

        # Cas d’une image non flottante

        update_current_line

      end

      page_number_fin = page_number.freeze
      if cursor < 0 && page_number_fin == page_number_debut
        # Je ne sais absolument pourquoi je dois faire ça, mais si 
        # je ne le fais pas, avec une image trop grande, ça crée une
        # nouvelle page qui n’est pas comptabilisée et ça décale tout,
        # ce qui génère une erreur de page dans la suite.
        # Problème à surveiller : car si ce bug est corrigé, ça ne
        # sera plus le cas.
        start_new_page
        start_new_page
      end

      # Consignation de l’image dans la table des illustrations
      # du livre (que cette table doive être imprimée ou non)
      book.table_illustrations.add(my)

    end #/pdf.update
    
    # spy(:off) if first_turn? && floating?

  end #/print

  # --- Floating Image Treatment ---

  # Méthode principale qui écrit le texte autour d’une image 
  # flottante
  def print_text_around_image(float_data)
    @erreur_passage_sous_page_signaled = false

    # S’il y a un margin_top, il faut écrire du texte avant
    if lines_before > 0
      # L’image est un peu décalée du haut, il faut donc écrire le
      # texte avant
      # @note
      #   La hauteur de curseur de :textbox1_top correspond à une 
      #   ligne de référence
      # 
      pdf.move_cursor_to(float_data[:textbox1_top])
      options_textbox1 = {
        width:  page_width, 
        height: (float_data[:textbox2_top] - float_data[:textbox1_top]).abs,
        at: [0, pdf.cursor],
        overflow: :truncate,
        align:    :justify,
        inline_format: true
      }
      exces = pdf.text_box(wrapped_text, **options_textbox1)
      exces = nil if exces.empty?
    else
      exces = wrapped_text
    end

    if exces.to_s.length == 0
      # - ERREUR PSEUDO-FATALE -
      # Cela se produit lorsqu’il y a des lignes de texte à écrire
      # au-dessus, mais qu’aucun texte n’est à écrire à côté de 
      # l’image. On signale une erreur.
      err_msg = PFBError[256] % {img: imgname, page: pdf.page_number}
      add_fatal_error(err_msg)
      pdf.move_cursor_to(float_data[:textbox3_top])
      pdf.move_to_next_line
      return true
    end

    # Le texte restant doit être mis à côté de l’image
    if exces
      image_w = calc_width + (margin_left + margin_right)
      text_w  = text_width ? text_width : page_width - image_w
      text_left = 
        if float_left?
          image_w
        else
          page_width - (text_w + image_w) # 0 en cas normal
        end
      image_height  = ((float_data[:textbox3_top] - pdf.line_height) - float_data[:textbox2_top]).abs
      
      pdf.move_cursor_to(float_data[:textbox2_top])
      pdf.move_to_closest_line

      if pdf.cursor - image_height < 0
        # - ERREUR PSEUDO-FATALE -
        # Avec la hauteur de l’image, on passe sous la page. On 
        # n’imterrompt pas la construction (sauf avec l’option -bat)
        # mais on met une forte alerte (rouge dans le rapport final)
        letexte = extract_text_for_error(exces, debug? ? nil : 70)
        err_msg = PFBError[253] % {img: imgname, page: pdf.page_number, text: letexte}
        add_fatal_error(err_msg)
        @erreur_passage_sous_page_signaled = true
      end

      options_textbox2 = {
        width:  text_w,
        height: image_height,
        at:     [text_left, pdf.cursor],
        overflow: :truncate,
        align:    :justify,
        inline_format: true
      }
      begin
        if exces.is_a?(String)
          exces = pdf.text_box(exces, **options_textbox2)
        else
          exces = pdf.formatted_text_box(exces, **options_textbox2)
        end
      rescue Prawn::Errors::CannotFit => e
        raise PFBFatalError.new(255, {img:imgname,page:pdf.page_number})
      end
      # LE CODE SUIVANT DÉTECTE DES ERREURS QUI N’EN SONT PAS… NE PAS
      # L’UTILISER
      # if pdf.cursor < 0
      #   puts "Problème de texte sous le zéro avec #{exces.inspect}".rouge
      #   exit 12
      # end
      exces = nil if exces.empty?
    end


    if exces.nil?
      # Cela se produit si tout le texte a pu être mis à côté de 
      # l’image. Dans ce cas, on passe sous l’image pour continuer à
      # écrire la suite.
      pdf.move_cursor_to(float_data[:textbox3_top])
      if pdf.cursor < 0 && not(@erreur_passage_sous_page_signaled)
        err_msg = PFBError[254] % {page: pdf.page_number, img: imgname, text: wrapped_text.gsub(/<.+?>/,'').gsub(/ +/,' ').scan(/[^ ]{1,70}/).join("\n")}
        add_fatal_error(err_msg)
      end
      pdf.move_to_next_line
      return true
    end

    # Le texte restant doit être mis en dessous de l’image
    # 
    if exces && exces.any?
      pdf.move_cursor_to(float_data[:textbox3_top])
      pdf.move_to_closest_line
      options_textbox3 = {
        document: pdf,
        width:  page_width,
        at:     [0, pdf.cursor],
        align:  :justify,
        inline_format: true
      }
      # - Calcul de la hauteur que prendra le reste -
      fbox = Prawn::Text::Formatted::Box.new(exces, **options_textbox3)
      fbox.render(dry_run: true)
      hauteur_reste = fbox.height
      # - Écriture du reste -
      if pdf.cursor < 0
        # Quand le texte à mettre sous l’image doit être passé à la
        # page suivante dès le premier mot. On se place alors en haut
        # de la page suivante.
        pdf.start_new_page
        pdf.move_to_line(1)
        options_textbox3[:at][1] = pdf.cursor
      end
      # - Écriture du texte sous l’image -
      exces = pdf.formatted_text_box(exces, **options_textbox3)
      if exces.empty?
        # - Déplacement du curseur -
        pdf.move_down(hauteur_reste)
      else
        # Il reste du texte (à cause d’un passage à la page suivante, 
        # on l’écrit
        pdf.start_new_page
        pdf.move_to_line(1)
        cursor_start = pdf.cursor.freeze
        pdf.formatted_text(exces, **{align: :justify, inline_format: true})
        cursor_end = pdf.cursor.freeze
      end
      pdf.update_current_line
      return false # pour ne pas déplacer le curseur
    end

  end

  # Le texte à enrouler autour de l’image (cf. [002])
  # Rapel : ce sont tous les paragraphes qui suivent l’image, 
  # précédés de "!"
  # 
  def wrapped_text
    s = []
    pp = self.prev_printed_paragraph
    # s << "#{pp.string_indentation}#{pp.raw_text}"
    s << "#{pp.string_indentation}#{pp.text}"
    # s << "#{pp.text}"
    while pp.prev_printed_paragraph.wrapped?
      pp = pp.prev_printed_paragraph
      # s  << "#{pp.string_indentation}#{pp.raw_text}"
      s  << "#{pp.string_indentation}#{pp.text}"
    end
    # s = AnyParagraph.__parse(s.reverse.join("\n"), **{pdf:pdf, paragraph:self.prev_printed_paragraph})
      # @note : peut-être faudra-t-il simplement appeler __parse sur 
      # chaque paragraphe
    return s.reverse.join("\n")
  end


  # Juste pour retourner un texte (le texte enroulé autour de l’image,
  # en gros, mais quelquefois seulement un extrait) en le simplifiant
  # pour qu’il s’affiche mieux.
  def extract_text_for_error(str, max_len)
    str = 
      if str.is_a?(Array)
        str.map { |h| h[:text] }.join(' ')
      else
        str.to_s
      end.gsub(/<.+>/,'').gsub(/ +/,' ').strip
    str = "#{str[0..max_len]} […]" if str.length > max_len && not(debug?)
    return str
  end

  # --- Calcul Methods ---

  def rectify_width
    if resize? && calc_width > max_width
      @data_image.merge!(width: max_width)
      @data_image.delete(:height) unless height
    elsif width
      @data_image.merge!(width: width)
    elsif scale != 1.0
      @data_image.merge!(width: calc_width)
    end
  end

  def rectify_height
    if resize? && calc_height > max_height
      @data_image.merge!(height: max_height)
      @data_image.delete(:width) unless width
    elsif height
      @data_image.merge!(height: height)
    elsif scale != 1.0
      @data_image.merge!(height: calc_height)
    end
  end

  # @return [Float] La largeur calculée de l’image
  def calc_width
    width || begin
      @data_image.key?(:height) && @data_image[:height] / ratio 
    end || begin
      height && height / ratio
    end || begin
      original_width
    end
  end

  # @return [Float] La hauteur calculée de l’image
  # 
  def calc_height
    height || begin
      @data_image.key?(:width) && @data_image[:width] * ratio
    end || begin
      width && width * ratio
    end || begin
      original_height
    end
  end

  # @return [Float] La largeur max pour l’image
  # 
  def max_width
    page_width - (left + right)
  end

  # @return [Float] La hauteur max pour l’image
  # (en tenant compte de la légende et des marges avant et après)
  # 
  def max_height
    page_height - 10 - (vadjust + legend_height + vadjust_legend + space_before + space_after)
  end

  # w * ratio donnera la hauteur
  # h / ratio donnera la largeur
  def ratio
    @ratio ||= original_height.to_f / original_width
  end

  # @return [Float] La largeur actuelle de la page
  # 
  def page_width
    pdf.bounds.width.to_f
  end

  # @return [Float] la hauteur actuelle de la page
  # 
  def page_height
    pdf.bounds.height.to_f
  end

  # --- Helper Methods ---

  # Nom de l’image dans la table des illustrations (si elle est
  # affichée)
  # 
  # On prendra par ordre de précédence :
  #   - le nom défini par :name dans les données
  #   - la légende (sans br)
  #   - le nom du fichier (sans trait plat)
  def picture_name
    self.name || self.legend&.gsub(/<br( \/)?>/,' ') || self.affixe.gsub(/[_\-]/,' ').titleize
  end

  # --- Legend methods ---

  # def wrap_in_color(str)
  #   fmt = 
  #     if legend_color.is_a?(String)
  #       '<color rgb="%s">'.freeze
  #     else
  #       '<color >'.freeze
  #     end
  #   format(fmt, legend_color) + str + '</color>'
  # end

  # Hauteur que prendra la légende
  def legend_height
    @legend_height ||= begin
      if legend
        pdf.height_of(legend,**legend_options)
      else
        0
      end
    end
  end

  def position_legend
    (left > 0 && left) || @data_image[:position] || :center
  end

  def left_legend
    if @data_image[:position] == :right || right > 0
      pdf.bounds.width - (legend_width + right)
    elsif float_left?
      left
    else
      (left > 0 && left) || pdf.bounds.width / 2 - legend_width / 2
    end
  end

  # La légende occupe la moitié de la page ou la largeur de l’image
  # si elle est plus petite que la moitié de la page.
  def legend_width
    @legend_width ||= begin
      [pdf.bounds.width / 2, calc_width].min
    end
  end

  # Options text pour la légende (if any)
  def legend_options(params = nil)
    @legend_options ||= {
        align:  :center,
        style:  legend_style,
        size:   legend_size,
        width:  legend_width,
        color:  legend_color,
        inline_format: true
      }
  end

  def legend_font_name
    data[:legend_font] || legend_data[:font] 
  end
  def legend_style
    @legend_style ||= data[:legend_style] || legend_data[:style] || :italic
  end
  def legend_size
    @legend_size ||= data[:legend_size] || legend_data[:size] || Fonte.current.size - 1
  end
  def legend_color
    @legend_color ||= data[:legend_color] || legend_data[:color]
  end

  def legend_data
    book.recipe.format_images[:legend] || {}
  end


  # --- Predicate Methods ---

  def first_turn?; Prawn4book.first_turn? end

  def image?    ; true  end
  def paragraph?; false end
  def printed?  ; true  end

  def exist?
    path && File.exist?(path)
  end

  def svg?
    :TRUE == @issvg ||= true_or_false(extname == '.svg')
  end

  def resize?
    :TRUE == @resizeit ||= true_or_false(not(data[:no_resize] === true))
  end

  def floating?
    :TRUE == @isfloating ||= true_or_false([:left, :right].include?(data[:float]))
  end

  def float_right?
    :TRUE == @isfloatright ||= true_or_false(floating? && data[:float].to_sym == :right)
  end
  def float_left?
    :TRUE == @isfloatleft ||= true_or_false(floating? && data[:float].to_sym == :left)
  end

  # --- Image Data ---

  # En cas d’image flottante, la largeur que doit prendre le texte,
  # si elle est définie
  def text_width
    @text_width ||= data[:text_width]
  end
  # EN cas d’image flottante, le nombre de lignes à laisser passer
  # au-dessus de l’image.
  def lines_before
    @lines_before ||= data[:lines_before] || 0
  end
  def margin_top
    @margin_top ||= data[:margin_top] || 0
  end
  def floating_bottom
    @floating_bottom ||= data[:floating_bottom] || 0
  end
  def margin_top
    @margin_top ||= data[:margin_top] || 0
  end
  def margin_bottom
    @margin_bottom ||= data[:margin_bottom] || 0
  end

  def margin_left
    @margin_left ||= data[:margin_left]||data[:left_margin]||begin
      if float_left?
        margin_distance || 0
      elsif float_right? && text_distance
        # - image flottante à droite avec :text_distance définie -
        text_distance
      else
        book.recipe.right_margin_with_floating_image
      end
    end
  end
  def margin_right
    @margin_right ||= data[:margin_right]||data[:right_margin]||begin
      if float_right?
        margin_distance || 0
      elsif float_left? && text_distance
        # - image flottante à gauche avec :text_distance définie -
        text_distance
      else
        book.recipe.left_margin_with_floating_image
      end
    end
  end
  def text_distance
    @text_distance ||= data[:text_distance]||data[:margin_text]||data[:text_margin]
  end
  def margin_distance
    @margin_distance ||= data[:margin_distance]
  end

  def space_before
    @space_before ||= data[:space_before] || 0
  end
  def space_after
    @space_after ||= data[:space_after] || 0
  end


  def original_width
    @original_width ||= original_size[:width] * scale
  end

  def original_height
    @original_height ||= original_size[:height] * scale
  end

  def original_size
    @original_size ||= begin
      width, height = FastImage.size(path)
      {width: width.to_f, height: height.to_f}
    end
  end

  # Width explicite
  def width
    @width ||= data[:width] && data[:width].to_pps(pdf.bounds.width)
  end

  # Heigh explicite
  def height
    @height ||= data[:height] && data[:height].to_pps(pdf.bounds.height)
  end

  def vadjust
    @vadjust ||= data[:vadjust] || 0.0
  end

  def left
    @left ||= begin
      if data.key?(:left)
        data[:left].to_pps
      elsif data.key?(:margin_left) # floating
        data[:margin_left].to_pps
      elsif float_left?
        0.0
      end
    end || 0.0
  end

  def right
    @right ||= begin
      data[:right].to_pps if data.key?(:right)
    end || 0.0
  end

  def scale
    @scale ||= data[:scale] || 1.0
  end

  def legend
    @legend ||= data[:legend] || data[:legende]
  end

  # @warning: ça n’est pas le nom du fichier, mais le nom pour la
  # table des illustrations
  def name
    @name ||= data[:name] || data[:picture_name]
  end

  def vadjust_legend
    @vadjust_legend ||= data[:vadjust_legend] || 0.0
  end

  def extname
    @extname ||= File.extname(filename)
  end

  def affixe
    @affixe ||= File.basename(imgname, extname)
  end

  def imgname
    @imgname ||= File.basename(path)
  end

  def path
    @path ||= PdfBook.current.image_path(filename)
  end

end #/class NImage
end #/class PdfBook
end #/module Prawn4book
