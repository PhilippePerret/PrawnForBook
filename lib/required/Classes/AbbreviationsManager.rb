module Prawn4book
class PdfBook
class AbbreviationsManager

  # [Prawn4book::PdfBook] Le livre en construction
  attr_reader :book

  # [Hash] Table de toutes les abréviations
  attr_reader :items

  # Pour définir la première page des abréviations
  attr_reader :on_pages

  def initialize(book)
    @book     = book
    @items    = {}
    @on_pages = []
  end

  # Ajoute une abréviation (si elle n’existe pas)
  # 
  # @note
  #   On peut définir la même abréviation plusieurs fois, pourvu que
  #   ce soit la même définition qui est donnée.
  # 
  def add(abbr, signification, **context)
    if items.key?(abbr)
      if signification != items[abbr]
        add_fatal_error(PFBError[2100] % {
          abbr:     abbr, 
          premiere: items[abbr],
          seconde:  signification,
          page:     context[:paragraph].first_page
        })
      end
    else
      items.merge!(abbr => signification)
    end
  end

  # Graver la liste des abréviations
  # 
  def print(pdf, premier_tour)

    if premier_tour
      init_pages(pdf)
      return
    end

    my = self

    # On calcule le numéro de la page qui suivra la liste des
    # abréviations
    next_page_number = (pdf.page_number + page_count + 1).freeze

    # Dans tous les cas, on passe à la page suivante pour commencer
    pdf.start_new_page

    # Si la liste des abréviations doit être mise sur une belle page,
    # il faut s’assurer qu’on s’y trouve
    if recipe[:belle_page] == true && pdf.page_number.even?
      pdf.start_new_page
      next_page_number += 1
    end

    # - Écriture du titre sur une nouvelle page -
    unless recipe[:title_level] < 1
      titre = PdfBook::NTitre.new(book:book, titre:recipe[:title], level:recipe[:title_level], pindex:0 )
      titre.print(pdf)
    end

    pdf.update do
      font(my.fonte)

      # Écriture des abréviations
      # -------------------------
      # On commence par voir la place que ça prendra autant en 
      # largeur qu’en hauteur, pour pouvoir répartir toutes les 
      # abréviations correctement.
      # Pour ce faire, on regarde la largeur la plus grande pour les
      # abréviations et la largeur la plus grande pour les significa-
      # tions. Permettra de savoir si on peut faire en deux colonnes
      # ou plus.
      # - Quelle taille pour les abréviations et les 
      #   significations ? -
      abbr_max_len = 0
      sens_max_len = 0
      my.items.each do |abbr, sens|
        w = width_of(abbr)
        abbr_max_len = w if w > abbr_max_len
        w = width_of(sens)
        sens_max_len = w if w > sens_max_len
      end
      abbr_max_len += 4
      sens_max_len += 4
      # - Largeur d’une colonne (hors gouttière) -
      # (avec 10 pps entre l’abréviation et la signification)
      abbr_column_width = abbr_max_len + 10 + sens_max_len
      # - Gouttière -
      gutter = 20

      # - Combien de colonnes ? -
      column_count = (bounds.width / (abbr_column_width + gutter)).to_i

      # - Combien de lignes -
      # (en fonction du nombre de colonnes et du nombre d’items)
      line_count = (my.items.count.to_f / column_count).ceil

      # - Tri des abréviations -
      paires = my.items.map do |abbr, sens|
        [abbr, sens]
      end.sort_by do |paire|
        paire[0].downcase
      end

      update_current_line
      first_line = self.current_line
      
      #================================#
      #=== GRAVURE DES ABRÉVIATIONS ===#
      #================================#
      column_count.times do |icol|
        move_to_line(first_line)
        line_count.times do |iline|
          paire = paires.shift
          break if paire.nil?
          abbr, sens = paire
          left = (abbr_column_width + gutter) * icol
          text_box(abbr, **{at: [left, cursor], width: abbr_max_len})
          left += abbr_max_len + gutter
          text_box(sens, **{at: [left, cursor], width: sens_max_len})
          move_to_next_line
        end
      end
    
      # - À la fin, on passe toujours à la page suivante -
      # Si on n’a pas assez de pages on les ajoute
      start_new_page while page_number < next_page_number

    end
  end

  # Pour indiquer sur quelle page commencer la liste des abréviations
  # 
  # @note
  #   On peut écrire plusieurs fois la liste des abréviations, donc
  #   la liste peut contenir plusieurs numéros de page
  # 
  def init_pages(pdf)
    page_count.times do 
      pdf.start_new_page
    end
  end

  def page_count
    @page_count ||= begin
      pc = recipe[:page_count] || 2
      pc += 1 if pc.odd?
      pc
    end
  end

  # Fonte
  # 
  def fonte
    @fonte ||= Fonte.get_in(recipe).or_default
  end

  # Donnée en recette
  # 
  def recipe
    @recipe ||= book.recipe.abbreviations
  end


end #/class AbbreviationsManager
end #/class PdfBook
end #/module Prawn4book
