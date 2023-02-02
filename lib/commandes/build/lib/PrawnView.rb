require 'prawn'
require 'prawn/measurement_extensions'

module Prawn4book
class PrawnView
  include Prawn::View

  @@table_errors_properties = {}
  def self.add_error_on_property(prop_name)
    unless @@table_errors_properties.key?(prop_name)
      @@table_errors_properties.merge!(prop_name => 0)
    end
    @@table_errors_properties[prop_name] += 1
    if @@table_errors_properties[prop_name] > 5
      raise PrawnFatalError.new(ERRORS[:building][:too_much_errors_on_properties] % prop_name)      
    end
  end

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

  # --- Margins Methods ---

  def odd_margins
    @odd_margins ||= [top_mg, int_mg, bot_mg, ext_mg]
  end
  def even_margins
    @even_margins ||= [top_mg, ext_mg, bot_mg, int_mg]
  end

  def top_mg; @top_mg ||= config[:top_margin] end
  def bot_mg; @bot_mg ||= config[:bot_margin] + 20 end
  def ext_mg; @ext_mg ||= config[:ext_margin] end
  def int_mg; @int_mg ||= config[:int_margin] end

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


  # Surclassement de la méthode Prawn::Document#font permettant de
  # définir la fonte courante.
  # Il existe maintenant 3 façons diffrentes de définir la fonte :
  # 
  # - normalement, c'est-à-dire avec le nom [String] en premier 
  #   argument et les autres paramètres en second argument.
  # - Avec un Hash qui contient les paramètres et en plus la propriété
  #   :name (ou :font) définissant le nom de la fonte
  # - Avec une instance Prawn4book::Fonte (utilisation privilégiée
  #   dans l'application)
  # 
  def font(fonte, params = nil)
    exit
    case fonte
    when String 
      super
    when Hash
      super(fonte.delete(:name)||fonte.delete(:font), **fonte)
    when Prawn4book::Fonte
      super(fonte.name, font.params)
    when NilClass
      raise ERRORS[:fontes][:font_argument_nil]
    else
      raise ERRORS[:fontes][:invalid_font_params]
    end
  end


  # @helper
  def add_cursor_position(str)
    "<font size=\"8\" name=\"#{pdfbook.second_font}\" color=\"grey\">[#{round(cursor)}]</font> #{str}"
  end

  # --- Predicate Methods ---

  # def paragraph_number?
  #   :TRUE == @hasparagnum ||= true_or_false(pdfbook.recette.paragraph_number?)
  # end

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
