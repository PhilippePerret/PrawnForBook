require 'prawn'
require 'prawn/measurement_extensions'

module Prawn4book
class PdfFile < Prawn::Document

NARRATION_BOOK_LAYOUT = {
  page_size: 'A5',
  page_layout: :portrait,
  align: :justify
}

MARGIN_ODD  = [20.mm, 15.mm, 20.mm, 25.mm]
MARGIN_EVEN = [20.mm, 25.mm, 20.mm, 15.mm]

  def initialize(config = nil)
    super(config)
    puts "config = #{config.inspect}".jaune
  end

  ##
  # Méthode appelée quand on passe à une nouvelle page, de façon
  # volontaire ou naturelle.
  # 
  def start_new_page(options = {})
    # 
    # Avant de passer à la page suivante, il faudra écrire dans le 
    # pied de page les numéros de dernier et premier paragraphe
    # 

    # 
    # Réglage des marges de la prochaine page
    # 
    super({margin: (page_number.odd? ? MARGIN_ODD : MARGIN_EVEN)}.merge(options))
    move_cursor_to_top_of_the_page

  end

  def move_cursor_to_top_of_the_page
    move_cursor_to 35 * 13.2 # pour les livres narration
  end

  # @predicate  Return true si c'est une belle page (aka page droite)
  def belle_page?
    page_number.odd?
  end

  # --- Insertion Methods ---

  ##
  # INSERTION GÉNÉRALE
  # 
  # C'est la méthode qui est appelée pour tout type de paragraphe
  # 
  def insert(parag)
    case parag
    when Prawn4book::PdfBook::NTextParagraph
      insert_paragraph(parag)
    when Prawn4book::PdfBook::NImage
      insert_image(parag)
    when Prawn4book::PdfBook::NTitre
      insert_titre(parag)
    end
  end

  ## 
  # INSERTION D'UN PARAGRAPHE
  # -------------------------
  # 
  # La complexité ici est qu'il faudra ajouter le numéro du 
  # paragraphe à côté de lui, en regard.
  # 
  # @param {PdfBook::NTextParagraph} par Le paragraphe à insérer
  # 
  def insert_paragraph(parag)
    #
    # On positionne le cursor au bon endroit
    # 
    cursor_on_baseline = (((cursor.to_i * 10) / 132).to_f * 13.2).round(4).freeze
    #
    # Faut-il passer à la page suivante ?
    #
    if cursor_on_baseline < 10
      start_new_page
      cursor_on_baseline = cursor
    else
      move_cursor_to cursor_on_baseline
    end

    span_pos = belle_page? ? :right : :left
    span_pos_num = belle_page? ? 11.2.cm : -1.cm 
    span(2.cm, position: span_pos_num) do
      font "Bangla"
      # pos_num = [(belle_page? ? 11.2.cm : -0.8.cm ), cursor - 16]
      number = parag.number.to_s
      number = number.rjust(4) unless belle_page?
      text "#{number}", size: 8, color: '777777' #, inline_format: true
    end

    move_cursor_to cursor_on_baseline

    # puts "cursor avant écriture paragraphe = #{cursor}"

    font "Garamond" # apparemment, ça ne fonctionne que comme ça
    text "#{cursor_on_baseline} #{parag.text}", align: :justify, size: 11, font_style: 'normal', inline_format: true
    
  end

  ##
  # INSERTION D'UN TITRE
  # 
  # @param {PdfBook::NTitre} titre Le titre à écrire
  def insert_titre(titre)
    font "Nunito", style: titre.font_style
    # font "Bangla"
    text titre.text, align: :left, size: titre.font_size
    # text titre.text, font_family:'Avenir', align: :left, size: 14, font_style:'normal'
  end

  ##
  # Pour insérer une image dans le document
  def insert_image(img)
    if img.svg?
      svg IO.read(img.path), color_mode: :cmyk
    else
      image img.path, x: 0
    end
  end

  ##
  # Définition des polices requises
  # 
  def define_required_fonts(fontes)
    return if fontes.nil? || fontes.empty?
    fontes.each do |fontname, fontdata|
      font_families.update(fontname => fontdata)
    end
  end

  ##
  # Place les numéros de pages
  # (note : ne devrait pas être utilisé puisqu'on mettra plutôt
  #  le numéro des paragraphes)
  def set_pages_numbers
    repeat(:odd) do
      font "Arial"
      draw_text "Page n°X", at: [300, -20], size: 9
    end

    repeat(:even) do
      font "Arial"
      draw_text "n°X Page", at: [0, -20], size: 9
    end    
  end

  ##
  # Renvoie la distance du curseur actuel avec la prochaine ligne de
  # base
  def next_line_on_baseline
    0
  end

end #/class PdfFile
end #/module Prawn4book
