module Prawn4book
module HeadersFooters
class Disposition
class << self

  # = main =
  # 
  # Construit tous les entêtes et pieds de page
  # 
  def build_headers_and_footers(book, pdf)
    
    # On boucle sur toutes les dispositions définies pour les
    # imprimer
    book.recipe.headers_footers[:dispositions].each do |dispo_id, dispo_data|
      new(book, dispo_data.merge(id: dispo_id)).print(pdf)
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

  parse # il dépend de pdf

  # puts "\nheaders : #{headers.inspect}".jaune
  # puts "footers : #{footers.inspect}".jaune

  
  options = {dynamic: true}
  # puts "Pages à entêter : #{pages.inspect}".bleu
  pdf.repeat(pages, **options) do 
    number = pdf.page_number
    # puts "Entête et pied de page sur page #{number}"
    if book.pages[number].not_printable?
      # puts "Non imprimable"
      next
    end

    # --- Page Data ---
    # (les données de la page qui serviront à remplacer les variables
    #  template)
    page_data = {
      number:       number,
      title1:       book.pages[number].titres[0],
      title2:       book.pages[number].titres[1],
      title3:       book.pages[number].titres[2],
      pages_count:  book.pages.count
    }
    
    # --- Construction du Header ---

    if header = headers[number.odd? ? :right : :left]
      print_header(header, page_data)
    end

    # --- Construction du Footer ---

    if footer = footers[number.odd? ? :right : :left]
      print_footer(footer, page_data)
    end    

    # exit

  end

end #/print

def print_header(portions_header, page_data)
  # puts "print header: #{portions_header.inspect}"
  portions_header.each do |portion|
    print_portion(portion, page_data)
  end
end

def print_footer(portions_footer, page_data)
  # puts "print footer: #{portions_footer.inspect}"
  portions_footer.each do |portion|
    print_portion(portion, page_data)
  end
end

def print_portion(portion_data, page_data)
  text = portion_data.dup.delete(:text) % page_data
  pdata = portion_data.merge({
    height: 20,
    overflow: :shrink_to_fit,
  })
  # puts "Portion à inscrire : #{pdata.inspect}".bleu
  # return
  pdf.update do
    text_box(text, **pdata)
  end
end

# --- Data ---

def name        ; @name         ||= data[:name].freeze        end
def first_page  ; @first_page   ||= data[:first_page].freeze  end
def last_page   ; @last_page    ||= data[:last_page].freeze   end
def raw_header  ; @raw_header   ||= data[:header].freeze      end
def raw_footer  ; @raw_footer   ||= data[:footer].freeze      end
def font        ; @font         ||= data[:font].freeze        end


# --- Volatile Data ---

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

# [Prawn4book::Fonte] Fonte à utiliser par défaut
def fonte
  @fonte ||= Prawn4book.fnss2Fonte(font)
end

# Rang des pages à imprimer, pour pdf.repeater
def pages
  @pages ||= begin
    real_last_page = 
      case last_page.to_i
      when -1, 0 then pages_count
      else last_page.to_i
      end
    ((first_page||1).to_i..real_last_page)
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
  def parse_side(side, thing)
    return nil if side.nil?
    top = thing == :header ? header_top : footer_bottom
    portions = []
    # On découpe le côté suivant les "|" en supprimant le premier
    # et le dernier s’ils ont été mis
    side
      .gsub(/^\|?(.+)\|?$/,'\1')
      .split('|').each do |s|
        s = s.strip
        next if s == 'x'
        tb_portion = {text: nil, align: nil, width: nil}
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
    'TIT1'  => '%{title1}',
    'TIT2'  => '%{title2}',
    'TIT3'  => '%{title3}',
    'TOT'   => '%{pages_count}'
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
