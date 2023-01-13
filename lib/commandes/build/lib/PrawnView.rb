require 'prawn'
require 'prawn/measurement_extensions'

module Prawn4book
class PrawnView
  include Prawn::View

  def self.add_cursor_position?
    :TRUE == @@addcurpos ||= true_or_false(CLI.option(:cursor))
  end

  # @prop Instance {Prawn4book::PdfBook}
  attr_reader :pdfbook

  attr_reader :config

  # Dernière page à imprimer (page du pdf), définie
  # en options de la ligne de commande (pour le moment)
  attr_accessor :last_page

  # L'instance PdfBook::Tdm qui gère la table des
  # matière. Permettra d'ajouter les titres pour construire
  # la table des matières finales
  attr_accessor :tdm

  def initialize(pdfbook, config)
    @pdfbook  = pdfbook
    @config   = config
  end

  def document
    @document ||= begin
      # spy "Config pour initialiser Prawn::Document :\n#{config.pretty_inspect}".jaune
      Prawn::RectifiedDocument.new(config)
    end
  end

  # --- Builing General Methods ---

  ##
  # - NOUVELLE PAGE -
  # 
  # Méthode appelée quand on passe à une nouvelle page, de façon
  # volontaire ou naturelle.
  # 
  def start_new_page(options = {})
    # 
    # Réglage des marges de la prochaine page
    # 
    super({margin: (page_number.odd? ? odd_margins  : even_margins)}.merge(options))
    @table_reference_grid || begin
      define_default_leading
    end
    #
    # Ajouter une page dans la donnée @pages du book
    # 
    pdfbook.add_page(page_number)
    
    # 
    # On replace toujours le curseur en haut de la page
    # 
    move_cursor_to_top_of_the_page
  end

  def move_cursor_to_top_of_the_page
    move_cursor_to bounds.top # - line_height
    # spy "bounds.top = #{bounds.top.inspect}".bleu
    spy "Curseur placé tout en haut (à #{round(cursor)})".bleu
  end

  ##
  # Quel que soit la position actuel du curseur, on le place sur la
  # prochaine ligne de référence (grille de référence pour aligner
  # toutes les lignes de texte)
  # 
  def move_cursor_to_next_reference_line
    line_ref = calc_ref_line
    spy "line_ref pour prochaine écriture du curseur : #{line_ref.inspect}".bleu
    move_cursor_to(line_ref)
  end

  ##
  # Calcul et renvoie la ligne de référence en fonction de la 
  # position actuelle du curseur.
  # 
  def calc_ref_line

    cur_dist_from_top = bounds.top - cursor
    cur_num_ref_line  = (cur_dist_from_top / line_height).floor
    new_num_ref_line  = cur_num_ref_line + 1
    new_dist_from_top = new_num_ref_line * line_height
    absolute_line_ref = bounds.top - new_dist_from_top
    line_ref          = absolute_line_ref + font.ascender

    msg_spy = <<~TEXT
    [calcul line ref]
      cursor départ : #{cursor.inspect}
      Distance depuis le haut efficace = #{cur_dist_from_top}
      Indice ligne référence courante = #{cur_num_ref_line}
      (line_height = #{line_height})
      Indice nouvelle ligne référence = #{new_num_ref_line}
      Nouvelle distance depuis le haut efficace = #{new_dist_from_top}
      Absolute Line Ref (sans la fonte) = #{absolute_line_ref}
      line_ref = #{line_ref}

      font : #{font.inspect}
      ascender : #{font.ascender}
      descender: #{font.descender}
    [/calcul line ref]
    TEXT
    spy msg_spy.bleu

    return line_ref    
  end

  # Méthode appelée quand on doit dessiner la grille de base
  # dans le document.
  def draw_reference_grids
    define_default_leading # utile ?
    font = font(default_font_name, size: default_font_size)
    # 
    # Aspect des lignes (bleues et fines)
    # 
    stroke_color 51, 0, 0, 3  # bleu ciel
    fill_color 51, 0, 0, 3    # bleu ciel
    line_width(0.1)
    # 
    # La grille peut n'être inscrite que sur quelques pages, 
    # définies par le paramètre 'grid=start-end' en ligne de commande
    # 
    if CLI.params[:grid]
      pfirst, plast = CLI.params[:grid].split('-').map {|n|n.to_i}
      kpages = (pfirst..plast)
    else
      kpages = :all
    end
    # 
    # Boucle sur toutes les pages voulues pour écrire la grille de
    # référence.
    # 
    repeat kpages do
      print_reference_grid
    end
    # 
    # On remet la couleur initiale pour retourner en noir
    # 
    stroke_color  0, 0, 0, 100
    fill_color    0, 0, 0, 100
  end

  # Pour dessiner la grille de référence sur toutes les pages ou 
  # seulement les pages choisies.
  # Option : -display_grid
  def print_reference_grid
    #
    # On commence toujours en haut
    # 
    h = bounds.top.dup # - line_height
    while h > 0
      # 
      # Prochaine position (définition de l'écartement entre les lignes)
      # 
      h -= line_height
      break if h < 0
      # 
      # Écriture de la position top
      # 
      float {
        move_cursor_to(h + 4)
        spy "[Grille référence] Cursor à #{cursor.inspect}".bleu_clair
        span(40, position: bounds.left - 20) do
          font pdfbook.second_font, size:6
          text round(h).to_s
        end
      }
      stroke_horizontal_line(0, bounds.width, at: h)
    end
  end

  # Pour dessiner les marges sur toutes les pages (ou seulement
  # celles choisies)
  # Option : -display_margins
  def draw_margins
    stroke_color(88,0,58,28)
    line_width(0.3)
    if CLI.params[:grid]
      pfirst, plast = CLI.params[:grid].split('-').map {|n|n.to_i}
      kpages = (pfirst..plast)
    else
      kpages = :all
    end
    repeat kpages do
      print_margins
    end
    stroke_color 0,0,0,100
  end
  def print_margins
    stroke_horizontal_line(0, bounds.width, at: bounds.top)
    stroke_horizontal_line(0, bounds.width, at: bounds.bottom)
    stroke_vertical_line(0, bounds.top, at: bounds.left)
    stroke_vertical_line(0, bounds.top, at: bounds.right)
  end



  def add_cursor_position(str)
    "<font size=\"8\" name=\"#{pdfbook.second_font}\" color=\"grey\">[#{round(cursor)}]</font> #{str}"
  end

  # --- Predicate Methods ---

  def table_of_contents?
    :TRUE == @hastoc ||= true_or_false(not(tdm.data[:page_number].nil?))
  end

  def paragraph_number?
    :TRUE == @hasparagnum ||= true_or_false(pdfbook.recette.paragraph_number?)
  end

  # @predicate True si c'est une belle page (aka page droite)
  def belle_page?
    page_number.odd?
  end

  # --- Doc Definition Methods ---

  ##
  # Définition des polices requises (à empaqueter dans le PDF)
  # 
  def define_required_fonts(fontes)
    return if fontes.nil? || fontes.empty?
    fontes.each do |fontname, fontdata|
      font_families.update(fontname.to_s => fontdata)
    end
  end

end #/PrawnView
end #/module Prawn4book
