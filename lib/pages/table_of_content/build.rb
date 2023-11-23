module Prawn4book
class Pages
class TableOfContent

  # = main =
  #
  # Méthode principale construisant la page
  # 
  def build(pdf)

    reset

    # 
    # On sait que la table des matières (son emplacement) est défini
    # lorsque son @page_number est défini. Si ça n'est pas le cas,
    # on ne fait rien.
    # 
    if pdf.tdm.page_number.nil?
      spy "Pas de table des matières.".jaune
      return
    end

    #
    # Raccourci de l'instance Prawn4Book::Tdm
    # 
    tdm = pdf.tdm
    
    # 
    # Raccourci de cette instance
    # 
    me = my = self
    
    # 
    # On se rend sur la page voulue
    # 
    pdf.go_to_page(tdm.page_number)
    spy "On rejoint la page #{tdm.page_number} pour écrire la TdM".jaune
    pdf.move_down(lines_before * tdm_line_height)
    #
    # Il faudrait calculer la hauteur totale de la table des 
    # matières pour bien la placer sur un certain nombre de pages
    # 

    # - Couleur normale -
    pdf.update do
      fill_color "000000"
      font(my.font)
    end


    # Données pour le titre en cours de traitement
    # (permet de récupérer plus rapidement les données si le niveau
    #  de titre ne change pas)
    # Définit :
    # 
    #   :indent           Identation à appliquer
    #   :title_options    Options text-box pour le titre
    #   :number_options   Options text-box pour le numéro
    # 
    cdata = {}


    # = ÉCRITURE DE LA TABLE DES MATIÈRES =
    # 
    tdm.each_titre do |titre|
      # - On ne prend pas au-dessus du niveau de titre voulu -
      next if titre.level > level_max

      # Si le niveau de titre change, il faut aussi changer les
      # données courantes
      if titre.level != cdata[:level]
        cdata = cdata_per_level(titre.level)
        # puts "\nNouveau cdata = #{cdata.inspect}".bleu
      end
      indent          = cdata[:indent]
      # title_fonte     = cdata[:title_font] 
      # number_fonte    = cdata[:number_font]
      title_options   = cdata[:title_options]
      title_color     = cdata[:title_options][:color]
      number_options  = cdata[:number_options]
      number_color    = cdata[:number_options][:color]
      caps            = cdata[:caps]

      # puts "title_options = #{title_options.inspect}".jaune

      # Titre à inscrire
      # ----------------
      content = case caps
        when 'none'       then titre.content
        when 'title', NilClass then titre.content.titleize
        when 'all-caps'   then titre.content.upcase
        when 'all-min'    then titre.content.downcase
        else raise "Caps inconnu : #{caps.inspect}"
        end

      begin # pour rescuer les erreurs

        pdf.update do

          # Largeur prise par le titre
          title_width = width_of(content, **title_options)
          spy = "Largeur de #{content.inspect} : #{title_width}"

          number_width = 0
          line_width   = 0

          if me.numeroter?

            number_width = width_of(titre.numero.to_s, **number_options)
            spy = "Largeur du numéro #{titre.numero} : #{number_width}"

            line_width = bounds.width - (indent + title_width + number_width + 10)
            spy = "Largeur de la ligne : #{line_width}"

            ####################################
            ### Impression du NUMÉRO DE PAGE ###
            ####################################
            # float do
              # span(number_width + 10, **{position: :right}) do
              #   text("#{titre.numero}", **number_options)
              # end
            # end
            nopts = number_options.merge(width: number_width)
            nopts[:at] = [bounds.width - (number_width + 4), cursor - my.vadjust_number]
            fill_color(number_color) if number_color
            text_box("#{titre.numero}", **nopts)

            ##########################
            ### LIGNE D’ALIGNEMENT ###
            ##########################
            # La ligne d’alignement
            lf = indent + title_width + 5
            hl = cursor - (12 + my.vadjust_line)
            dash(my.dash_line[:length], **my.dash_line[:options])
            stroke_color(my.dash_line[:color]) if my.dash_line[:color]
            stroke_horizontal_line(lf, lf + line_width, at: hl)

          end #/s’il faut numéroter

          ############################
          ### Impression du TITRE  ###
          ############################
          spy "[1020] Impression du titre #{content.inspect} (niveau #{titre.level})".bleu
          opts = title_options.merge(width: title_width + 10)
          opts[:at][1] = cursor
          spy "       options: #{opts.inspect}".bleu
          # - Impression -
          fill_color(title_color)
          text_box(content, **opts)
          move_down(my.tdm_line_height)
          # Passer à la page suivante si trop peu de reste
          start_new_page if cursor < 20
        
        end #/pdf.update

      rescue Prawn::Errors::CannotFit => e

        raise PFBFatalError.new(851)

      end

      # break # pour voir

    end #/fin de loop

  end

  ##
  # Méthode qui définit dans recipe_tdm[:level<+level+>] les données
  # utiles pour les placements. Une fois pour toutes, pour ne pas
  # avoir à les recalculer pour tous les titres de même niveau
  # 
  def cdata_per_level(level)
    @cdata_per_level ||= define_all_cdata_per_level
    return @cdata_per_level[level]
  end

  def define_all_cdata_per_level

    cdatas = {}
    
    (1..level_max).each do |level|

      cdata = {
        level: level,
      }

      # Les données recette pour le titre
      title_rdata = recipe_tdm["level#{level}".to_sym] || {}

      # - Transformation du titre -
      cdata.merge!(caps: (title_rdata[:caps]||'title').to_s.downcase)

      # - Indentation -
      indent = title_rdata[:indent] || 0
      indent = indent.to_f if indent.is_a?(String)
      cdata.merge!(indent: indent)

      # - TITRE -
      # Fonte pour le titre de ce niveau de titre
      title_fonte = Prawn4book.fnss2Fonte(title_rdata[:font]) || font
      # Les options de titre pour ce niveau de titre
      title_opts = {
        at: [indent, nil],
        font_name:  title_fonte.name,
        style:      title_fonte.style,
        size:       title_fonte.size,
        color:      title_fonte.color,
        align:      :left,
        inline_format: true
      }
      cdata.merge!(title_options: title_opts)

      # - NUMÉRO -
      # Fonte pour le numéro de ce niveau de titre
      number_fonte = Prawn4book.fnss2Fonte(title_rdata[:number_font]) || number_font
      # Les options de numéro pour ce niveau de titre
      number_opts = {
        at:         [nil,nil], # fonction de title-width
        font_name:  number_fonte.name,
        style:      number_fonte.style,
        size:       number_fonte.size,
        color:      number_fonte.color,
        align:      :right,
        inline_format: true # utile ?
      }
      cdata.merge!(number_options: number_opts)

      cdatas.merge!(level => cdata)
    end #/chaque niveau de titre

    # On retourne la table complète
    return cdatas
  end


  def reset
    self.instance_variables.each do |varname|
      next if varname == :@folder
      # puts "Variable instanciée : #{varname.inspect}"
      self.instance_variable_set("#{varname}", nil)
    end
  end


  # @return [Boolean] true s'il faut numéroter la table des matières
  def numeroter?
    recipe_tdm[:numeroter] == true
  end

  # @return [Boolean] true si la numérotation se fait par les pages
  def num_page?
    recipe.page_number?
  end

  # --- DÉFINITIONS RECETTE ---

  # Fonte générale (définie ou par défaut)
  def font
    @font ||= Prawn4book.fnss2Fonte(recipe_tdm[:font]) || Fonte.default
  end

  # Fonte générale pour le numéro (ou police de la tdm)
  def number_font
    @number_font ||= Prawn4book.fnss2Fonte(recipe_tdm[:number_font]) || font
  end

  def level_max
    @level_max ||= recipe_tdm[:level_max].freeze
  end

  # @return [Integer] Hauteur de ligne (si elle est définie)
  def tdm_line_height
    @tdm_line_height ||= recipe_tdm[:line_height].freeze
  end

  def lines_before
    recipe_tdm[:lines_before]
  end

  # Ajustement vertical de la ligne d’alignement
  def vadjust_line
    recipe_tdm[:vadjust_line]
  end

  # Ajustement vertical du numéro de page
  def vadjust_number
    recipe_tdm[:vadjust_number]
  end

  # Ligne pointillée d’alignement
  def dash_line
    @dash_line ||= begin
      dl = recipe_tdm[:dash_line]
      {
        length: dl[:length]||1, 
        options: {
          space: dl[:space]||1, 
          phase: dl[:phase] || 1
        },
        color: dl[:color]
      }
    end
  end

  def recipe_tdm
    recipe.table_of_content
  end

end #/class TableOfContent
end #/class Pages
end #/module Prawn4book
