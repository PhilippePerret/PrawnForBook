#
# ATTENTION
# =========
# Cette classe ne doit pas être confondue avec la classe utilisée 
# comme page spéciale, qu’on utilise peut-être encore un peu, mais
# de moins en moins à l’avenir.
# 
require_relative 'SpecialTable'
module Prawn4book
class PdfBook
class TableOfContent < SpecialTable

  # Gravure de la table des matières
  # 
  # @param [Prawn4book::PrawnView]
  #   Le PDF Prawn gravé
  # 
  # @param [Integer] num_page
  #   Numéro de la page sur laquelle il faut graver la table des
  #   matières (car il peut y en avoir plusieurs)
  # 
  def print(pdf, num_page)
    super


    tdm = pdf.tdm
    my  = self

    # - Préparation -
    pdf.font(fonte)
    pdf.fill_color(fonte.color)
    # - On se place au bon endroit -
    pdf.go_to_page(num_page)
    pdf.move_down(lines_top * tdm_line_height)

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
      # - On ne prend pas au-dessus du niveau de titre max -
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
      # (peut-être transformé)
      # ----------------------
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

          number_width = 0
          line_width   = 0

          if my.numeroter?

            # Largeur pour le numéro
            number_width = width_of(titre.numero.to_s, **number_options)

            # Largeur (longueur) pour la ligne
            line_width = bounds.width - (indent + title_width + number_width) - 10

            ####################################
            ### Impression du NUMÉRO DE PAGE ###
            ####################################
            nopts = number_options.merge(width: number_width)
            nopts[:at] = [bounds.width - number_width, cursor - my.vadjust_number]
            fill_color(number_color) if number_color
            text_box("#{titre.numero}", **nopts)

            ##########################
            ### LIGNE D’ALIGNEMENT ###
            ##########################
            lf = indent + title_width + 5
            hl = cursor - (12 + my.vadjust_line)
            dash(my.dash_line[:length], **my.dash_line[:options])
            stroke_color(my.dash_line[:color]) if my.dash_line[:color]
            stroke_horizontal_line(lf, lf + line_width, at: hl)

          end #/s’il faut numéroter

          ############################
          ### Impression du TITRE  ###
          ############################
          opts = title_options.merge(width: title_width + 10)
          opts[:at][1] = cursor
          # - Impression -
          fill_color(title_color)
          text_box(content, **opts)
          move_down(my.tdm_line_height)

          # = Page suivante =
          # =================
          # Si on passait à la page suivante comme pour le reste du
          # livre, une table des matières placée au début du livre,
          # s’étalant sur plusieurs pages, repousserait toutes les
          # autres pages. Les belles pages pourraient alors se re-
          # trouver en fausse page, ce qui abimerait tout le livre.
          # D’autres part, toutes les références seraient fausses et
          # on serait contraint de faire un travail monstre pour rec-
          # tifier le tout. 
          # TODO: Ça pourra être envisagé pour une version suivante,
          # avec la méthode #next_page_in_automatic_mode ci-dessous
          # Pour le moment, le moyen est :
          # 1) de mettre 2 pages par défaut pour toute table des
          #    matière.
          # 2) de permettre à l’utilisateur de définir le nombre de
          #    pages exact (on signale une erreur si on se retrouve
          #    sur une page écrite)
          # 
          # Dans tous les cas, ici, on passe simplement à la page
          # suivante, on n’en ajoute pas une.
          # Passer à la page suivante si trop peu de reste
          # 
          # ESSAI EN MODE AUTOMATIQUE
          if cursor < (my.lines_bottom * my.tdm_line_height)
            # my.next_page_in_automatic_mode(pdf)
            my.next_page_in_natural_mode
          end
        
        end #/pdf.update

      rescue Prawn::Errors::CannotFit => e

        raise PFBFatalError.new(851)

      end

      # break # pour voir

    end #/fin de loop

    # exit

  end


  # Prépare les pages pour écrire dessus avec #print au deuxième
  # tour, lorsque toutes les données sont récupérées
  # 
  def prepare_pages(pdf, premier_tour)

    @pdf = pdf

    # On passe toujours sur la page suivante
    start_new_tdm_page

    # Si on ne se trouve pas sur une belle page, on passe à la page
    # suivante
    start_new_tdm_page if pdf.page_number.even?

    # Instancier un titre pour la table des matières
    # 
    unless recipe[:no_title] || title.nil? || title == '---'
      titre = PdfBook::NTitre.new(book:book, titre:title, level:title_level, pindex:nil)
      titre.print(pdf)
      book.page(page_number).add_content_length(title.length + 3)
    end

    # On mémorise le numéro de première page de cette table des
    # matières
    # book.tdm.add_page_number(pdf.page_number.freeze)
    pdf.tdm.add_page_number(pdf.page_number.freeze)

    # Le nombre de pages à ajouter est défini par :pages_count qui
    # doit impérativement être un nombre pair.
    added = page_count || 2
    if added.odd? || added == 0
      add_erreur(PFBError[853] % {num: added})
      added += 1
    end

    # On ajoute autant de pages que voulu (une page a déjà été
    # ajoutée plus haut)
    added.times { start_new_tdm_page }

  end

  # Graver une nouvelle page (vierge) dans le livre, non 
  # paginer
  # 
  def start_new_tdm_page
    pdf.start_new_page
    book.page(pdf.page_number).pagination = false
  end

  # --- Predicate Methods ---

  # @return [Boolean] true s'il faut numéroter la table des matières
  def numeroter?
    recipe[:numeroter] == true
  end

  # @return [Boolean] true si la numérotation se fait par les pages
  def num_page?
    book.recipe.page_number?
  end

  # --- Data Methods ---

  def page_count
    @page_count ||= recipe[:page_count]
  end


  # Fonte générale (définie ou par défaut)
  def font
    @font ||= Fonte.get_in(recipe).or_default
  end

  # Fonte générale pour le numéro (ou police de la tdm)
  def number_font
    @number_font ||= Fonte.get_in(recipe[:number_font]).or(font)
  end

  def level_max
    @level_max ||= recipe[:level_max].freeze
  end

  # @return [Integer] Hauteur de ligne (si elle est définie)
  def tdm_line_height
    @tdm_line_height ||= recipe[:line_height].freeze
  end

  def lines_top
    recipe[:lines_top]
  end

  def lines_bottom
    recipe[:lines_bottom]
  end

  # Ajustement vertical de la ligne d’alignement
  def vadjust_line
    recipe[:vadjust_line]
  end

  # Ajustement vertical du numéro de page
  def vadjust_number
    recipe[:vadjust_number]
  end

  # Ligne pointillée d’alignement
  def dash_line
    @dash_line ||= begin
      dl = recipe[:dash_line]
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


  # private


  def next_page_in_natural_mode
    my = self

    pdf.update do

      new_page_number = page_number + 1

      # Si la page suivante n’est pas vide, c’est une erreur fatale
      if book.page(new_page_number).not_empty?
        raise PFBFatalError.new(852, {num: new_page_number})
      end

      # On va sur la page suivante, qui doit être vide
      go_to_page(new_page_number)
      book.page(new_page_number).pagination = false
      # On se place au bon endroit vertical de la page
      move_down(my.lines_top * my.tdm_line_height)
    
    end #/pdf.update

    # On s’en retourne joyeux
  end #/next_page_in_natural_mode


  ##
  # Méthode qui définit dans recipe[:level<+level+>] les données
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
      title_rdata = recipe["level#{level}".to_sym] || {}

      # - Transformation du titre -
      cdata.merge!(caps: (title_rdata[:caps]||'title').to_s.downcase)

      # - Indentation -
      indent = title_rdata[:indent] || 0
      indent = indent.to_f if indent.is_a?(String)
      cdata.merge!(indent: indent)

      # - TITRE -
      # Fonte pour le titre de ce niveau de titre
      title_fonte = Fonte.get_in(title_rdata).or_default
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
      number_fonte = Fonte.get_in(title_rdata[:number_font]).or(title_fonte) 
      # Les options de numéro pour ce niveau de titre
      number_opts = {
        at:         [nil,nil], # fonction de title-width
        font_name:  number_fonte.name,
        style:      number_fonte.style,
        size:       title_rdata[:numero_size]||number_fonte.size,
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

end #/class TableOfContent
end #/class PdfBook
end #/module Prawn4book
