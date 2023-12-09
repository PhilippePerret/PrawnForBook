require_relative 'AnyParagraph'
require 'fastimage'

module Prawn4book
class PdfBook
class NImage < AnyParagraph

  # @public
  # 
  # Méthode qui parse le code contenu à l'intérieur d'un ![...]
  # dans le fichier source (ou IMAGE[...] pour la régression).
  # @note : ce code doit se trouve seul sur la ligne où l’image
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

  def initialize(book:, path:, data_str:, pindex:)
    super(book, pindex)
    @type = 'image'
    @data = NImage.parse(data_str)
    @filename = path
  end


  # --- Printer Methods ---

  def me
    @me ||= "Image #{filename} (#{legend.to_s.gsub('<br>',' ')}"
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

    spy "Image:       #{filename}".bleu
    spy "Légende:     #{legend}".bleu if legend
    spy <<~EOD.bleu
      (taille page : #{pdf.bounds.width.round(2)} x #{pdf.bounds.height.round(2)})
      Original W: #{original_width.inspect}
      Original H: #{original_height.inspect}
      Explicit W: #{width.inspect}
      Explicit H: #{height.inspect}
      Calc W:     #{calc_width} 
      Calc H:     #{calc_height} 
      Scale:      #{scale.inspect}
      left:       #{left.inspect}
      right:      #{right.inspect}
      position legend: #{position_legend}
      left legend: #{left_legend}
      -----------
      Data image: #{@data_image}
      EOD


    # Propriété à sortir (pour le scope dans pdf)
    # 
    img_path = path
    # mg_bottom = margin_bottom

    data_image = @data_image

    floating_data = {} if floating? # [002]

    debugit = false # true


    pdf.update do

      # On passe à la ligne, sauf quand l’image occupe toute la
      # page
      unless (my.calc_height + my.legend_height + my.vadjust) >= bounds.height
        final_line = line_height - line_height / 2
        move_down(final_line)
        data_image[:at][1] += final_line if data_image.key?(:at)
      end

      # S’il y a de l’espace à laisser avant
      if my.space_before != 0
        data_image[:at][1] -= my.space_before if data_image.key?(:at)
        # Dans tous les cas, on se déplace vers le bas
        move_down(my.space_before)
      end

      # S’il y a un ajustement vertical
      if my.vadjust > 0
        data_image[:at][1] -= my.vadjust if data_image.key?(:at)
        # Dans tous les cas, on se déplace vers le bas
        move_down(my.vadjust)
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
        data_image[:left] = my.float_left? ? my.margin_left : my.calc_width
        # data_image[:at][0] = data_image[:left]
      end

      cursor_before = cursor.freeze
      image_top = (data_image.key?(:at) ? data_image[:at][1] : cursor_before).freeze

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
          [my.left_legend, cursor - my.vadjust_legend], 
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
        my.print_text_around_image(floating_data)
        # Où faut-il se placer (cursor) ensuite ?
        spy <<~EOT
          Pour trouver la position de curseur (best_cursor)
          -----------------------------------
          image_top = #{image_top}
          image_height = #{image_height}
          image_top - image_height = #{image_top - image_height}
          cursor = #{cursor}
          floating_data[:textbox3_top] = #{floating_data[:textbox3_top]}          
          last_cursor = #{last_cursor}  
          EOT
        best_cursor = [
          image_top - image_height - line_height, 
          cursor, 
          floating_data[:textbox3_top], 
          last_cursor
        ].min.freeze
        # spy "Meilleur curseur obtenu : #{best_cursor}".bleu
        move_cursor_to(best_cursor)
        move_to_closest_line
        # update_current_line
        move_to_next_line
        spy "Donc se placer sur la line suivant : #{cursor.freeze}".jaune
      end

      page_number_fin = page_number.freeze
      if cursor < 0 && page_number_fin == page_number_debut
        # Je ne sais absolument pourquoi je dois faire ça, mais si 
        # je ne le fais pas, avec une image trop grande, ça crée une
        # nouvelle page qui n’est pas comptabilisée et ça décale tout,
        # ce qui génère une erreur de une page dans la suite.
        # Problème à surveiller : car si ce bug est corrigé, ça ne
        # sera plus le cas.
        start_new_page
        start_new_page
      end

    end #/pdf.update
    
    # spy(:off) if first_turn? && floating?

  end #/print

  # --- Floating Image Treatment ---

  # Méthode principale qui écrit le texte autour d’une image 
  # flottante
  def print_text_around_image(float_data)
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

    if exces.nil?
      # Cela se produit lorsqu’il y a des lignes de texte à écrire
      # au-dessus, mais qu’aucun texte n’est à écrire à côté de 
      # l’image. On signale une erreur.
      add_erreur("Une image flottante ne possède aucun texte à côté d’elle. Il est défini, mais trop court.")
      pdf.move_cursor_to(float_data[:textbox3_top])
      pdf.move_to_next_line
      return
    end

    # Le texte restant doit être mis à côté de l’image
    if exces
      image_width   = calc_width + (margin_left + margin_right)
      text_width = page_width - image_width
      text_left  = float_left? ? image_width : 0
      image_height  = ((float_data[:textbox3_top] - pdf.line_height) - float_data[:textbox2_top]).abs
      pdf.move_cursor_to(float_data[:textbox2_top])
      pdf.move_to_closest_line
      options_textbox2 = {
        width:  text_width,
        height: image_height,
        at:     [text_left, pdf.cursor],
        overflow: :truncate,
        align:    :justify,
        inline_format: true
      }
      if exces.is_a?(String)
        exces = pdf.text_box(exces, **options_textbox2)
      else
        exces = pdf.formatted_text_box(exces, **options_textbox2)
      end
      exces = nil if exces.empty?
    end


    if exces.nil?
      # Cela se produit si tout le texte a pu être mis à côté de 
      # l’image. Dans ce cas, on passe sous l’image pour continuer à
      # écrire la suite.
      pdf.move_cursor_to(float_data[:textbox3_top])
      pdf.move_to_next_line
      return
    end

    # Le texte restant doit être mis en dessous de l’image
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
      pdf.formatted_text_box(exces, **options_textbox3)
      # - Déplacement du curseur -
      pdf.move_down(hauteur_reste)
      pdf.update_current_line
    end

  end

  # Le texte à enrouler autour de l’image (cf. [002])
  # Rapel : ce sont tous les paragraphes qui suivent l’image, qui 
  # sont précédés de "!"
  # 
  def wrapped_text
    s = []
    pp = self.prev_printed_paragraph
    s << pp.raw_text
    while pp.prev_printed_paragraph.wrapped?
      pp = pp.prev_printed_paragraph
      s  << pp.raw_text
    end
    s = AnyParagraph.__parse(s.reverse.join("\n"), **{pdf:pdf, paragraph:self.prev_printed_paragraph})
      # @note : peut-être faudra-t-il simplement appeler __parse sur 
      # chaque paragraphe

    # puts "\ns final = #{s}"
    # sleep 3
    return s
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
    @margin_left ||= data[:margin_left] || begin
      float_left? ? 0 : 10
    end
  end
  def margin_right
    @margin_right ||= data[:margin_right] || begin
      float_right? ? 0 : 10
    end
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

  def vadjust_legend
    @vadjust_legend ||= data[:vadjust_legend] || 0.0
  end

  def extname
    @extname ||= File.extname(filename)
  end

  def path
    @path ||= PdfBook.current.image_path(filename)
  end

end #/class NImage
end #/class PdfBook
end #/module Prawn4book
