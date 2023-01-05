module Prawn4book
class PrawnView

  ##
  # = main =
  # 
  # Méthode principale qui construit les entêtes et pieds de page
  # sur tout le livre.
  def build_headers_and_footers(pdfbook, pdf, data_pages)
    Header.build(pdfbook, pdf, data_pages)
    Footer.build(pdfbook, pdf, data_pages)
  end

  ##########################################################
  #
  # Class PrawnView::AbstractHeadFoot
  #
  # Classe abstraite pour Header et Footer
  #
  ##########################################################
  class AbstractHeadFoot
    class << self
      attr_reader :pdfbook
      attr_reader :data_pages
      # = main =
      # 
      # Méthode principale pour construire les entêtes et les
      # pieds de pages
      # 
      def build(pdfbook, pdf, data_pages)
        init(pdfbook, data_pages)
        data.each { |ditem| new(ditem).build(pdf) }
        # puts "Data page: #{data_pages.inspect}".bleu
      end
      def init(pdfbook, data_pages)
        @pdfbook    = pdfbook
        @data_pages = data_pages
      end
      def data
        @data ||= pdfbook.recipe.headers_footers
      end
    end #/ << self


    # --- INSTANCE (headers and footers) ---

    
    attr_reader :data
    def initialize(data)
      @data = data
      analyse_disposition
    end

    # Raccourcis
    def pdfbook     ; self.class.pdfbook    end
    def data_pages  ; self.class.data_pages end

    # = MAIN BUILDER =
    # 
    # Méthode générique pour construire l'entête ou le pied
    # de page
    # 
    def build(pdf)
      @font_size = data[:size] || 9
      @font_face = data[:font] || pdfbook.second_font

      pdf.font(@font_face, size: @font_size)

      proc_for_odd = hdft_procedure_for(pdf, :odd)
      proc_for_even = hdft_procedure_for(pdf, :even)
      
      # 
      # Séparation des pages impaires et paires
      # 
      odd_pages   = [] # impaires
      even_pages  = [] # paires
      pages.to_a.each do |ipage|
        (ipage.odd? ? odd_pages : even_pages) << ipage
      end

      num_page = pdfbook.page_number?

      # 
      # INSCRIPTION DES HEADERS OU FOOTERS
      # 
      pdf.repeat even_pages, dynamic: true do
        contents = {
          left:   content_for(even_left_temp,   pdf.page_number), 
          center: content_for(even_center_temp, pdf.page_number),
          right:  content_for(even_right_temp,  pdf.page_number)
        }
        pdf.update do
          proc_for_even.call(contents)
        end
      end
      pdf.repeat odd_pages, dynamic: true do
        contents = {
          left:   content_for(odd_left_temp,   pdf.page_number), 
          center: content_for(odd_center_temp, pdf.page_number),
          right:  content_for(odd_right_temp,  pdf.page_number)
        }
        pdf.update do
          proc_for_odd.call(contents)
        end
      end
    end

    def content_for(cas, numero_page)
      return nil if cas.nil? # case non définie
      return '' if data_pages[numero_page].nil?
      dtemp = {}.merge(data_pages[numero_page])
      # puts "dtemp = #{dtemp.inspect}"
      if cas.match?(/%{numero}/)
        pagine = pdfbook.page_number? ? numero_page : paragraphs_for(numero_page)
        pagine ||= numero_page # le cas échéant (pas de paragraphe)
        dtemp.merge!(numero: pagine.to_s)
      end
      cas % dtemp
    end

    ##
    # Retourne la pagination pour les paragraphes de la page
    # +numpage+
    # 
    def paragraphs_for(numpage)
      dp = data_pages[numpage]
      return nil if dp.nil?
      dp = "#{dp[:first_par]}-#{dp[:last_par]}"
      return nil if dp == '-'
      return dp
    end

    ## Retourne la procédure pour écrire l'élément (soit le header
    # soit le footer en fonction de l'instance appelée)
    # 
    def hdft_procedure_for(pdf, side)

      cL = send("#{side}_left".to_sym)
      cM = send("#{side}_center".to_sym)
      cR = send("#{side}_right".to_sym)

      w = pdf.bounds.width
      pct100 = pct2width(w, 100)
      pct50  = pct2width(w, 50)
      pct33  = pct2width(w, 33)
      pct66  = pct2width(w, 66)
      pct34  = pct2width(w, 34)
      # 
      # Top et Hauteur
      # 
      top, height = self.class.calc_top_and_height(pdf)
      # 
      # Préparation des données
      # 
      cusdata = {height: height, size: @font_size}
      #
      # Pour mettre les données du text_box (et les débugguer)
      # 
      dtb = nil

      laproc = 
      if cL && cM.nil? && cR.nil?
        dtb = cusdata.merge(width:pct100, at:[0, top], align:align_of(cL,:left))
        Proc.new do |contents|
          pdf.text_box(contents[:left].to_s, dtb)
        end
      elsif cL.nil? && cM && cR.nil?
        # Seulement au milieu
        dtb = cusdata.merge(width: pct100, at: [0, top], align: align_of(cM,:center))
        Proc.new do |contents|
          pdf.text_box(contents[:center].to_s, dtb)
        end
      elsif cL.nil? && cL.nil? && cR
        dtb = cusdata.merge(width:pct100, at:[0, top], align:align_of(cR, :right))
        Proc.new do |contents|
          pdf.text_box(contents[:right].to_s, dtb)
        end
      elsif cL && cM && cR.nil?
        dtb_left    = cusdata.merge(width:pct34, at:[0, top], align:align_of(cL,:left))
        dtb_center  = cusdata.merge(width:pct66, at:[pct34, top], align:align_of(cM,:center))
        Proc.new do |contents|
          pdf.text_box(contents[:left].to_s  , dtb_left)
          pdf.text_box(contents[:center].to_s, dtb_center)
        end
      elsif cL && cM.nil? && cR
        dtb_left    = cusdata.merge(width:pct50, at:[0, top], align:align_of(cL,:left))
        dtb_right   = cusdata.merge(width:pct50, at:[pct50, top], align:align_of(cR,:right))
        Proc.new do |contents|
          pdf.text_box(contents[:left].to_s , dtb_left)
          pdf.text_box(contents[:right].to_s, dtb_right)
        end
      elsif cL.nil? && cM && cR
        dtb_center  = cusdata.merge(width:pct34, at:[pct33, top], align:align_of(cM, :center))
        dtb_right   = cusdata.merge(width:pct34, at:[pct66, top], align:align_of(cR,:right))
        Proc.new do |contents|
          pdf.text_box(contents[:center].to_s, dtb_center)
          pdf.text_box(contents[:right].to_s , dtb_right)
        end
      elsif cL && cM && cR
        dtb_left    = cusdata.merge(width:pct33, at:[0, top], align:align_of(cL,:left))
        dtb_center  = cusdata.merge(width:pct34, at:[pct33, top], align:align_of(cM,:center))
        dtb_right   = cusdata.merge(width:pct33, at:[lR, top], align:align_of(cR,:right))
        Proc.new do |contents|
          pdf.text_box(contents[:left].to_s  , dtb_left)
          pdf.text_box(contents[:center].to_s, dtb_center)
          pdf.text_box(contents[:right].to_s , dtb_right)
        end
      end

      # Debug
      # puts "Data procédure pour #{side.inspect} : #{dtb.inspect}"

      return laproc
    end

    # --- "Bords" (left, center, right) par "Side" (odd, even) ---

    def odd_left
      @odd_left ||= hdispositions[:odd][:left]
    end
    def odd_left_temp
      @odd_left_temp ||= retire_tirets_align_in(odd_left)
    end
    def odd_center
      @odd_center ||= hdispositions[:odd][:center]
    end
    def odd_center_temp
      @odd_center_temp ||= retire_tirets_align_in(odd_center)
    end
    def odd_right
      @odd_right ||= hdispositions[:odd][:right]
    end
    def odd_right_temp
      @odd_right_temp ||= retire_tirets_align_in(odd_right)
    end

    def even_left
      @even_left ||= hdispositions[:even][:left]
    end
    def even_left_temp
      @even_left_temp ||= retire_tirets_align_in(even_left)
    end
    def even_right
      @even_right ||= hdispositions[:even][:right]
    end
    def even_right_temp
      @even_right_temp ||= retire_tirets_align_in(even_right)
    end
    def even_center
      @even_center ||= hdispositions[:even][:center]
    end
    def even_center_temp
      @even_center_temp ||= retire_tirets_align_in(even_center)
    end

    # --- Dispositions --- 

    def hdispositions; @hdispositions end

    def disposition
      @disposition ||= data[:disposition] || erreur_fatale(ERRORS[things][:dispositions_required])
    end

    def analyse_disposition
      odd_disp  = decompose_disp(disposition[:odd])
      even_disp = decompose_disp(disposition[:even])
      @hdispositions = {
        odd:  {left: odd_disp[0], center:odd_disp[1], right:odd_disp[2]},
        even: {left: even_disp[0], center:even_disp[1], right:even_disp[2]}
      }
    end

    def decompose_disp(disp)
      return disp if disp.is_a?(Hash)
      disp.split('|').map do |s|
        s = s.strip
        s == '' ? nil : s
      end
    end

    # Méthode qui retire les '-' au début ou à la fin des contenus
    # des cases de headers et footers
    # 
    def retire_tirets_align_in(str)
      return nil if str.nil?
      str = str[1..-1] if str.start_with?('-')
      str = str[0..-2] if str.end_with?('-')
      return str
    end


    # --- Dimensions Methods --- #

    def align_of(content, default)
      case content
      when /^\-.+\-$/ then :center
      when /^\-/    then :right
      else default
      end
    end

   def pct2width(w, pct)
      return nil if pct.nil?
      round(w * pct / 100)
    end

    def pages
      @pages ||= begin
        d = data[:pages]
        d = eval(d) if d.is_a?(String)
        d.to_a
      end
    end

  end #/ class AbstractHeadFoot


  ##########################################################
  #
  # Class PrawnView::Header
  #
  # Construction des entêtes
  #
  ##########################################################

  class Header < AbstractHeadFoot
    class << self
      def things; :headers end
      def thing;  :header  end
      def calc_top_and_height(pdf)
        @calc_top_and_height ||= begin
          height = 20
          top = pdf.bounds.top + height
          [top, height]
        end
      end
    end #/<< self
  end


  ##########################################################
  #
  # Class PrawnView::Footer
  #
  # Construction des pieds de page
  #
  ##########################################################

  class Footer < AbstractHeadFoot
    class << self
      def things; :footers end
      def thing;  :footer  end 
      def calc_top_and_height(pdf)
        @calc_top_and_height ||= begin
          height = 20
          top = pdf.bounds.bottom
          [top, height]
        end
      end
    end #/<< self
  end




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


  def parag_number_width
    @parag_number_width ||= 7.mm
  end

  # --- Predicate Methods ---

  def paragraph_number?
    :TRUE == @hasparagnum ||= true_or_false(pdfbook.recette.paragraph_number?)
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
    @footer_font_name ||= begin
      if pdfbook.recette.footers && pdfbook.recette.footers[0]
        pdfbook.recette.footers[0][:font] 
      end || pdfbook.second_font
    end
  end
  def footer_font_size
    @footer_font_size ||= begin
      if pdfbook.recette.footers && pdfbook.recette.footers[0]
        pdfbook.recette.footers[0][:size] 
      end || DEFAULT_SIZE_FONT
    end
  end

end #/class PrawnView
end #/module Prawn4book
