module Prawn4book
class PrawnView
  # Méthode principale qui invoque la construction des entêtes et
  #  pieds de page sur tout le livre
  def build_headers_and_footers(book)
    Prawn4book::HeadersFooters::Disposition.build_headers_and_footers(book, self)
  end
end #/class PrawnView
module HeadersFooters
class Disposition
class << self

  # = main =
  # 
  # Construit tous les entêtes et pieds de page
  # 
  def build_headers_and_footers(book, pdf)
    # Pour ne traiter qu’une seule fois les pages
    @traited_pages = {}
    # On boucle sur toutes les dispositions définies pour les
    # imprimer
    book.recipe.headers_footers[:dispositions].map do |dispo_id, dispo_data|
      new(book, dispo_data.merge(id: dispo_id))
    end.sort_by do |dispo|
      # Pour que celle par défaut soit en dernier et qu’elle ne
      # se mette pas sur toutes les pages traitées par d’autres
      # dispositions d’entête et pied de page
      dispo.id == :default ? 1 : 0
    end.each do |dispo|
      dispo.print(pdf)
    end
  end

  # @return true si la page +number+ a déjà été traitée (i.e. a déjà
  # reçu son entête et pied de page) ou retourne false et mémorise
  # la page pour qu’elle ne reçoive pas un autre entête pied de page
  # 
  def traited?(number)
    if @traited_pages[number]
      return true
    else
      @traited_pages.merge!(number => true)
      return false
    end
  end

end #/<< class self

############# INSTANCE HeadersFooters::Disposition ##############

attr_reader :book, :pdf
attr_reader :data
def initialize(book, data)
  @book = book
  @data = data
end

# = main =
# 
# Impression de cette disposition
# 
def print(pdf)

  @pdf = pdf

  @current_filled_color = pdf.fill_color

  parse # il dépend de pdf

  # Appliquer la fonte générale si elle est définie
  pdf.font(fonte) if font
  
  options = {dynamic: true}
  # puts "Disposition: #{name}".jaune
  # puts "Pages à header/footer : #{pages.inspect}".jaune
  pdf.repeat(pages, **options) do 
    number = pdf.page_number

    # Une page ne peut recevoir qu’un seul entête/pied de page
    # Si elle a déjà été traitée, on la passe
    next if self.class.traited?(number)

    # La page courante [Prawn4book::PageManager::Page]
    curpage = book.pages[number]

    # puts "Entête et pied de page sur page #{number}"
    next if curpage.not_printable?
    # puts "La page ##{number} est printable".bleu

    # La passer si elle ne doit pas être paginée
    next if curpage.no_pagination?
    # puts "La page ##{number} est paginée"

    # --- Page Data ---
    # Pour pouvoir faire le test avec une page au milieu :
    # if number == 34
    #   (1..70).each do |n|
    #     puts "\nDonnées de titre de la page #{n}".bleu
    #     puts book.pages[n].titres.inspect.bleu
    #   end
    #   exit
    # end
    # (les données de la page qui serviront à remplacer les variables
    #  template)
    page_data = {
      Title1:       curpage.titres[0],
      Title2:       curpage.titres[1],
      Title3:       curpage.titres[2],
      Title4:       curpage.titres[3],
      Title5:       curpage.titres[4],
    }
    (1..5).each do |n|
      tit = page_data["Title#{n}".to_sym] || ''
      page_data.merge!("TITLE#{n}".to_sym => tit.upcase)
      page_data.merge!("title#{n}".to_sym => tit.downcase)
    end
    page_data.merge!({
      number:       number,
      pages_count:  book.pages.count,
    })
    
    # --- Gravure du Header ---

    if header = headers[number.odd? ? :right : :left]
      print_header(header, page_data)
    end

    # --- Gravure du Footer ---

    if footer = footers[number.odd? ? :right : :left]
      print_footer(footer, page_data)
    end    

    # exit

  end

  # On remet la couleur initiale
  pdf.fill_color(@current_filled_color)


end #/print

def print_header(portions_header, page_data)
  apply_color(:header)
  portions_header.each do |portion|
    print_portion(portion, page_data)
  end
end

def print_footer(portions_footer, page_data)
  apply_color(:footer)
  portions_footer.each do |portion|
    print_portion(portion, page_data)
  end
end

#
# = Graveur général du Header ou du Footer =
#
# @generic method
# 
def print_portion(portion_data, page_data)
  pdata = portion_data.dup 
  text = pdata.delete(:text) % page_data
  pdata = pdata.merge({
    height: 20,
    overflow: :shrink_to_fit,
    inline_format: true
  })
  pdf.update do
    # puts "Écriture de #{text.inspect} sur page ##{page_number} avec #{pdata}".jaune
    font(pdata.delete(:fonte))
    text_box(text, **pdata)
    # Ça ne fonctionne pas, avec les valeurs par défaut, avec :
    # font(pdata.delete(:fonte)) do
    #   text_box(text, **pdata)
    # end
  end
end

# @param thing [Symbol] :header ou :footer
# 
def apply_color(thing)
  fte = fontes[thing]
  pdf.fill_color(fte.color || @current_filled_color)
end


# --- Data ---

def id          ; @id           ||= data[:id].freeze          end
def name        ; @name         ||= data[:name].freeze        end
def raw_pages   ; @raw_pages    ||= data[:pages].freeze       end
def raw_header  ; @raw_header   ||= data[:header].freeze      end
def raw_footer  ; @raw_footer   ||= data[:footer].freeze      end
def font        ; @font         ||= data[:font].freeze        end
def header_font ; @header_font  ||= data[:header_font].freeze end
def footer_font ; @footer_font  ||= data[:footer_font].freeze end


# --- Volatile Data ---

def font_size(thing)
  fontes[thing].size
end

def font_name(thing)
  fontes[thing].name
end

def fontes
  @fontes ||= {
    header: Prawn4book.fnss2Fonte(header_font) || fonte,
    footer: Prawn4book.fnss2Fonte(footer_font) || fonte,
  }
end

# [Prawn4book::Fonte] Fonte générale à utiliser (elle est définie 
# dans tous les cas
def fonte
  @fonte ||= Prawn4book.fnss2Fonte(font) || Prawn4book::Fonte.default
end

def pages_count
  @pages_count ||= book.pages.count
end

def header_top
  @header_top ||= pdf.bounds.top + 24
end

def footer_bottom
  @footer_bottom ||= -4
end

# Les headers, :left et :right
def headers
  @headers # calculé ci-dessous
end

# Les footers, :left et :right
def footers
  @footers # calculé ci-dessous
end


# Rang des pages à imprimer, pour pdf.repeater
def pages
  @pages ||= begin
    nombre_pages = book.pages.count
    if raw_pages.nil?
      (1..nombre_pages)
    else
      first_page, last_page = (raw_pages||'-').split('-').map{|n|n.to_i}
      first_page = 1 if first_page == 0
      last_page = nombre_pages if last_page.nil? || last_page == 0
      (first_page..last_page)
    end
  end
end

def page_width
  @page_width ||= pdf.bounds.width.to_f
end

private

  # Méthode qui parse le code de l’entête et du pied de page en 
  # partant de leur code brut : "| x | x || x | <-> |"
  def parse
    @headers = parse_thing(raw_header, :header)
    @footers = parse_thing(raw_footer, :footer)
    # puts "@headers = #{@headers.inspect}".jaune
    # puts "@footers = #{@footers.inspect}".jaune
  end

  def parse_thing(raw, thing)
    return nil if raw.nil?
    left_s, right_s = raw.split('||')
    {left: parse_side(left_s, thing), right: parse_side(right_s, thing)}
  end

  # @return [Array<Hash>] Une liste des portions à afficher. Chaque
  # portion est une table contenant pour le moment :text et :align
  # 
  # @param thing [Symbol] :header ou :footer
  # 
  def parse_side(side, thing)
    return nil if side.nil?
    top = thing == :header ? header_top : footer_bottom
    portions = []
    side = side[1..-1] if side.start_with?('|')
    side = side[0..-2] if side.end_with?('|')
    # On découpe le côté suivant les "|" en supprimant le premier
    # et le dernier s’ils ont été mis
    side
      .split('|').each do |s|
        s = s.strip
        next if s == 'x'
        tb_portion = {
          text: nil, 
          align: nil, 
          width: nil, 
          # size: font_size(thing),
          fonte: fontes[thing]
        }
        # - Alignement -
        tb_portion[:align] = 
          if s.start_with?('-')
            s = s[1..-1]
            :left
          elsif s.end_with?('-')
            s = s[0...-1]
            :right
          else
            :center
          end
        # - Contenu (template) -
        tb_portion[:text] = remplace_balises_in(s)
        portions << tb_portion
      end
    return nil if portions.empty?
    # Réglage de la largeur et de la position horizontal de la
    # portion en fonction de son rang
    width = page_width / portions.count
    portions.each_with_index do |po, idx| 
      po.merge!({
        width: width,
        at: [idx * width, top]
      })
    end
    return portions
  end

  TABLE_BALISES = {
    'NUM'   => '%{number}',
    'TOT'   => '%{pages_count}',
    'TIT1'  => '%{TITLE1}',
    'TIT2'  => '%{TITLE2}',
    'TIT3'  => '%{TITLE3}',
    'TIT4'  => '%{TITLE4}',
    'TIT5'  => '%{TITLE5}',
    'tit1'  => '%{title1}',
    'tit2'  => '%{title2}',
    'tit3'  => '%{title3}',
    'tit4'  => '%{title4}',
    'tit5'  => '%{title5}',
    'Tit1'  => '%{Title1}',
    'Tit2'  => '%{Title2}',
    'Tit3'  => '%{Title3}',
    'Tit4'  => '%{Title4}',
    'Tit5'  => '%{Title5}',
  }
  def remplace_balises_in(str)
    TABLE_BALISES.each do |k, v|
      str = str.gsub(k, v)
    end
    return str
  end

end #/class Disposition
end #/module HeadersFooters
end #/module Prawn4book
