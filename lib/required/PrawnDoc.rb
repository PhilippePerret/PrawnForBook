require 'prawn'
require 'prawn/measurement_extensions'

module Prawn4book

# DEFAULT_TOP_MARGIN    = 20
# DEFAULT_BOTTOM_MARGIN = 20
# DEFAULT_LEFT_MARGIN   = 20
# DEFAULT_RIGHT_MARGIN  = 20
# DEFAULT_FONT          = 'Arial'
# DEFAULT_SIZE_FONT     = 10

class PrawnDoc < Prawn::Document

# NARRATION_BOOK_LAYOUT = {
#   page_size: 'A5',
#   page_layout: :portrait,
#   align: :justify
# }

# MARGIN_ODD  = [20.mm, 15.mm, 20.mm, 25.mm]
# MARGIN_EVEN = [20.mm, 25.mm, 20.mm, 15.mm]

  # attr_reader :config

  # # Dernière page à imprimer (page du pdf), définie
  # # en options de la ligne de commande (pour le moment)
  # attr_accessor :last_page

  # # L'instance PdfBook::Tdm qui gère la table des
  # # matière. Permettra d'ajouter les titres pour construire
  # # la table des matières finales
  # attr_accessor :tdm

  # def initialize(config = nil)
  #   @config = config
  #   super(config)
  #   # puts "[instantiation PrawnDoc] config = #{config.pretty_inspect}".jaune
  # end

  # --- Lines Methods ---

  # ##
  # # @input  Reçoit la fonte concernée (*) et
  # #         Reçoit la hauteur de ligne voulue
  # # @output Return le leading à appliquer
  # # 
  # # Note : ne pas oublier d'indiquer la fonte en sortant de cette
  # # méthode jusqu'à (TODO) je sache remettre l'ancienne fonte en la
  # # prenant à l'entrée dans la méthode
  # def font2leading(fonte, size, hline, options = {})
  #   lead  = 0.0
  #   font fonte, size:size
  #   h = height_of("A", leading:lead, size: size)
  #   if (h - hline).abs > (h - 2*hline).abs
  #     options.merge!(:greater => true) unless options.key?(:greater)
  #   end
  #   # puts "h = #{h}"
  #   if h > hline && not(options[:greater] == true)
  #     while h > hline
  #       h = height_of("A", leading: lead -= 0.01, size: size)
  #     end
  #   else
  #     while h % hline > 0.01
  #       h = height_of("A", leading: lead += 0.01, size: size)
  #     end
  #   end
  #   return lead
  # end

  # # Méthode pour se déplacer sur la ligne suivante
  # def next_baseline(xlines = 1)
  #   move_up(4)
  #   c = cursor.freeze # p.e. 456
  #   d = c.to_i / line_height # p.e. 456 / 12 = 38
  #   newc = (d - xlines) * line_height # p.e. (38 + 1) * 12 = 468
  #   move_cursor_to(newc)
  # end

  # def default_font
  #   @default_font ||= config[:default_font]||DEFAULT_FONT
  # end

  # def default_font_size
  #   @default_font_size ||= config[:default_font_size]||DEFAULT_SIZE_FONT
  # end

  # ##
  # # Méthode appelée quand on passe à une nouvelle page, de façon
  # # volontaire ou naturelle.
  # # 
  # def start_new_page(options = {})
  #   # 
  #   # Avant de passer à la page suivante, il faudra écrire dans le 
  #   # pied de page les numéros de dernier et premier paragraphe
  #   # 

  #   # 
  #   # Réglage des marges de la prochaine page
  #   # 
  #   super({margin: (page_number.odd? ? odd_margins  : even_margins)}.merge(options))
  #   move_cursor_to_top_of_the_page

  # end

  # def move_cursor_to_top_of_the_page
  #   move_cursor_to bounds.top
  # end

  # # @predicate  Return true si c'est une belle page (aka page droite)
  # def belle_page?
  #   page_number.odd?
  # end

  # --- Insertion Methods ---

  # ##
  # # Définition des polices requises
  # # 
  # def define_required_fonts(fontes)
  #   return if fontes.nil? || fontes.empty?
  #   fontes.each do |fontname, fontdata|
  #     font_families.update(fontname => fontdata)
  #   end
  # end

  ##
  # Place les numéros de pages
  # (note : ne devrait pas être utilisé puisqu'on mettra plutôt
  #  le numéro des paragraphes)
  def set_pages_numbers(data_pages)
    @top_footer ||= - footer_height

    font footer_font_name, size: footer_font_size

    case pdfbook.recette.style_numero_page
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

      break if page_number === last_page

    end

  end

  # def paragraph_number?
  #   :TRUE == @hasparagnum ||= true_or_false(pdfbook.recette.paragraph_number?)
  # end

  def parag_number_width
    @parag_number_width ||= 7.mm
  end

  # def odd_margins
  #   @odd_margins ||= [top_mg, int_mg, bot_mg, ext_mg]
  # end
  # def even_margins
  #   @even_margins ||= [top_mg, ext_mg, bot_mg, int_mg]
  # end


  # def top_mg; @top_mg ||= config[:top_margin] || DEFAULT_TOP_MARGIN end
  # def bot_mg
  #   @bot_mg ||= begin
  #     (config[:bottom_margin] || DEFAULT_BOTTOM_MARGIN) + 20
  #   end
  # end
  # def ext_mg
  #   @ext_mg ||= begin
  #     lm = config[:left_margin] || DEFAULT_LEFT_MARGIN
  #     lm += parag_number_width if paragraph_number?
  #     lm
  #   end
  # end
  # def int_mg
  #   @int_mg ||= begin
  #     rm = config[:right_margin] || DEFAULT_RIGHT_MARGIN
  #     rm += parag_number_width if paragraph_number?
  #     rm
  #   end
  # end


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
    @footer_font_name ||= begin
      if pdfbook.recette.footers && pdfbook.recette.footers[0]
        pdfbook.recette.footers[0][:font] 
      end || DEFAULT_FONT
    end
  end
  def footer_font_size
    @footer_font_size ||= begin
      if pdfbook.recette.footers && pdfbook.recette.footers[0]
        pdfbook.recette.footers[0][:size] 
      end || DEFAULT_SIZE_FONT
    end
  end

end #/class PrawnDoc < Prawn::Document
end #/module Prawn4book
