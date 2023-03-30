require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class NTitre < AnyParagraph

  attr_accessor :page_numero

  attr_reader :data

  def initialize(pdfbook, data)
    super(pdfbook)
    @data = data.merge!(type: 'titre')
    check_inscription_in_tdm
  end

  def leading
    @leading ||= self.class.leading(level)
  end

  # @return [Prawn4book::Fonte] Instance Fonte pour ce niveau de
  # titre
  def fonte
    @fonte ||= Prawn4book::Fonte.title(level)
  end
  def size
    @size ||= fonte.size
  end

  # @prop {Integer} Espace avec le texte suivant
  def lines_after
    @lines_after ||= self.class.lines_after(level)
  end

  # @prop {Integer} Espace avec le texte précédent
  def lines_before
    @lines_before ||= self.class.lines_before(level)
  end

  # --- Predicate Methods ---

  # @return true si on doit inscrire le titre dans la table des
  # matières (true par défaut)
  def in_tdm?
    @writeit_in_tdm
  end

  def next_page?
    :TRUE == @onnewpage ||= true_or_false(self.class.next_page?(level))
  end

  def belle_page?
    :TRUE == @onbellepage ||= true_or_false(self.class.belle_page?(level))
  end

  def paragraph?; false end
  def sometext? ; true end # seulement ceux qui contiennent du texte
  alias :some_text? :sometext?
  def titre?    ; true  end

  # --- Data Methods ---

  def level ; @level  ||= data[:level]  end
  def text  ; @text   ||= data[:text]   end


  private

    # Pour définir si on doit inscrire le titre dans la table
    # des matières
    def check_inscription_in_tdm
      txt = data[:text]
      @writeit_in_tdm = not(txt.match?(/\{no[_\-]tdm\}/i))
      txt = txt.gsub(/\{no[_-]tdm\}/,'').strip unless @writeit_in_tdm
      @text = txt
    end

  public

  # --- MÉTHODES DE CLASSES ---

  def self.lines_after(level)
    laft = get_data(:lines_after, level)
    # laft = 1 if laft === 0
    return laft
  end

  def self.lines_before(level)
    lbef = get_data(:lines_before, level)
    # lbef = 1 if level > 1 && lbef === 0
    return lbef
  end

  def self.leading(level)
    get_data(:leading, level)
  end

  def self.next_page?(level)
    level == 1 && get_data(:next_page, level) === true
  end

  def self.belle_page?(level)
    level == 1 && get_data(:belle_page, level) === true
  end

  ##
  # @return [Any] La valeur +property+ pour le niveau de titre
  # +level+
  # @note
  #   On n'utilise plus cette méthode pour le :name, :size et :style
  #   de la police, puisqu'elle est gérée par Prawn4book::Fonte. On
  #   ne s'en sert plus que pour les lignes avant/après, etc.
  # 
  def self.get_data(property, niveau)
    key_niveau = :"level#{niveau}"
    unless data_titles[key_niveau].key?(property)
      spy "data_titles[key_niveau] ne connait pas la clé #{property.inspect}. Ne connait que les clés : #{data_titles[key_niveau].keys.inspect}".rouge
    end
    return data_titles[key_niveau][property]
  end

  def self.data_titles
    @@data_titles ||= PdfBook.current.recette.titles_data
  end

end #/class NTitre
end #/class PdfBook
end #/module Prawn4book
