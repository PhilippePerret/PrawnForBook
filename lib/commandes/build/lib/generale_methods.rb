require 'prawn'
require 'prawn/measurement_extensions'

module Prawn4book

DEFAULT_TOP_MARGIN    = 20
DEFAULT_BOTTOM_MARGIN = 20
DEFAULT_LEFT_MARGIN   = 20
DEFAULT_RIGHT_MARGIN  = 20
DEFAULT_FONT          = 'Arial'
DEFAULT_SIZE_FONT     = 10
DEFAULT_LINE_HEIGHT   = 12

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
    @document ||= Prawn::Document.new(config)
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
    # Avec l'option -g/--grid on peut demander l'affichage de la 
    # grille de référence
    #
    CLI.option(:display_grid) && print_reference_grid
    # 
    # Avec l'option --display_margins, on affiche les marges
    # 
    CLI.option(:display_margins) && print_margins
    # 
    # On replace toujours le curseur en haut de la page
    # 
    move_cursor_to_top_of_the_page
  end

  # --- Cursor Methods ---

  def move_cursor_to_top_of_the_page
    move_cursor_to bounds.top
    # puts "Curseur placé en haut de page (à #{round(cursor)})"
  end

  def add_cursor_position(str)
    "<font size=\"8\" name=\"Arial\" color=\"grey\">[#{round(cursor)}]</font> #{str}"
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

  def add_cursor_position?
    :TRUE == @addcurspos ||= true_or_false(CLI.option(:cursor))
  end

  # --- Doc Definition Methods ---

  ##
  # Définition des polices requises (à empaqueter dans le PDF)
  # 
  def define_required_fonts(fontes)
    return if fontes.nil? || fontes.empty?
    fontes.each do |fontname, fontdata|
      font_families.update(fontname => fontdata)
    end
  end

end #/PrawnView
end #/module Prawn4book
