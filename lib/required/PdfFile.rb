require 'prawn'
require 'prawn/measurement_extensions'

module Prawn4book
class PdfFile < Prawn::Document

# NARRATION_BOOK_LAYOUT = {
#   page_size: 'A5',
#   page_layout: :portrait,
#   align: :justify
# }

# MARGIN_ODD  = [20.mm, 15.mm, 20.mm, 25.mm]
# MARGIN_EVEN = [20.mm, 25.mm, 20.mm, 15.mm]

  attr_reader :config

  def initialize(config = nil)
    @config = config
    super(config)
    puts "[instantiation PdfFile] config = #{config.pretty_inspect}".jaune
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
    super({margin: (page_number.odd? ? odd_margins  : even_margins)}.merge(options))
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

    if paragraph_number? 
      numero = (parag.number + 900).to_s

      # 
      # On place le numéro de paragraphe
      # 
      font "Bangla", size: 7
      # 
      # Taille du numéro si c'est en belle page, pour calcul du 
      # positionnement exactement
      # 
      # Calcul de la position du numéro de paragraphe en fonction du
      # fait qu'on se trouve sur une page gauche ou une page droite
      # 
      span_pos_num = 
        if belle_page?
          wspan = width_of(numero)
          bounds.right + (parag_number_width - wspan)
        else
          - parag_number_width
        end

      @span_number_width ||= 1.cm

      move_cursor_to cursor_on_baseline - 1
      span(@span_number_width, position: span_pos_num) do
        text "#{numero}", color: '777777'
      end
    end #/end if paragraph_number?

    move_cursor_to cursor_on_baseline

    # puts "cursor avant écriture paragraphe = #{cursor}"

    final_str = "#{cursor_on_baseline} #{parag.text}"

    font "Garamond", size: 11, font_style: :normal
    text final_str, 
      align: :justify, 
      size: 11, 
      font_style: 'normal', 
      inline_format: true
    # h = height_of(final_str)
    # puts "h = #{h.inspect}"
    # text_box(final_str, 
    #     at: [belle_page? ? 0 : 1.cm, cursor],
    #     # inline_format: true,
    #     height: h,
    #     overflow: :shrink_to_fit
    #     ) do
    # end    
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
  def set_pages_numbers(data_pages)
    @top_footer ||= - footer_height

    font footer_font_name, size: footer_font_size

    case num_page_style
    when 'num_parags'
      numerote_pages_with_paragraphs_number(data_pages)
    when 'num_page'
      numerote_pages_with_page_number
    end

  end

  def numerote_pages_with_page_number
    str = "<page>"
    odd_options = { 
      page_filter: :odd,
      at: [bounds.right - 200, @top_footer], 
      width: 200, 
      align: :right,
      start_count_at: 1
    }
    even_options = {
      page_filter: :even,
      at: [0, @top_footer], 
      width: 200, 
      align: :left,
      start_count_at: 2
    }
    number_pages str, odd_options
    number_pages str, even_options
  end

  #
  # Numérotation exceptionnelle des pages avec le numéro des
  # premiers et derniers paragraphes
  # 
  # Cf. https://github.com/prawnpdf/prawn/blob/7d4f6b8998e0627259c1036a2cd6bca65cd53f45/lib/prawn/document.rb#L572
  def numerote_pages_with_paragraphs_number(data_pages)
    common_options = {
      width: 200,
      height: 50,
      color: 'CCCCCC'
    }
    odd_options = common_options.merge({
      at: [bounds.right - 200, @top_footer],
      align: :right
    })
    even_options = common_options.merge({
      at: [0, @top_footer], 
      align: :left,
    })
    # 
    # Réglage de la fonte
    # 
    font footer_font_name, size: footer_font_size
    # 
    # Boucle sur toutes les pages (qui comportent des paragraphes)
    # 
    data_pages.each do |page_number, data_page|
      if page_match?(:odd, page_number)
        options = odd_options.dup
      else
        options = even_options.dup
      end
      go_to_page(page_number)
      str = "#{data_page[:first_par]} - #{data_page[:last_par]}"

      # Debug
      # puts "str = #{str.inspect} / #{options.inspect} / page #{page_number}"

      text_box str, options
    end

  end

  ##
  # Renvoie la distance du curseur actuel avec la prochaine ligne de
  # base
  def next_line_on_baseline
    0
  end


  def odd_margins
    @odd_margins ||= [top_mg, int_mg, bot_mg, ext_mg]
  end
  def even_margins
    @even_margins ||= [top_mg, ext_mg, bot_mg, int_mg]
  end

  def num_page_style
    @num_page_style ||= pdfbook.num_page_style
  end

  def paragraph_number?
    :TRUE == @hasparagnum ||= true_or_false(pdfbook.paragraph_number?)
  end

  def parag_number_width
    @parag_number_width ||= 7.mm
  end

  def top_mg; @top_mg ||= config[:top_margin]     end
  def bot_mg
    @bot_mg ||= begin
      config[:bottom_margin] + 20
    end
  end
  def ext_mg
    @ext_mg ||= begin
      lm = config[:left_margin]
      lm += parag_number_width if paragraph_number?
      lm
    end
  end
  def int_mg
    @int_mg ||= begin
      rm = config[:right_margin]
      rm += parag_number_width if paragraph_number?
      rm
    end
  end


  # --- Calcul Methods ---

  # @prop Hauteur du pied de page. Déterminera le cursor maximal pour
  # une page
  def footer_height
    @footer_height ||= begin
      font footer_font_name, size: footer_font_size
      height_of("Dans le pied de page")
    end
  end

  def footer_font_name
    @footer_font_name ||= pdfbook.footer[:style][:font] || 'Times'
  end
  def footer_font_size
    @footer_font_size ||= pdfbook.footer[:style][:font_size] || 10
  end

  def pdfbook
    @pdfbook ||= PdfBook.current
  end

end #/class PdfFile < Prawn::Document
end #/module Prawn4book
