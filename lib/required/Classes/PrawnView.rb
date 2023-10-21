require 'prawn'
require 'prawn/measurement_extensions'

module Prawn4book
class PrawnView
  include Prawn::View

  # @prop Instance {Prawn4book::PdfBook}
  attr_reader :book

  attr_reader :config

  # Première et dernière page à imprimer
  # (définis en option)
  def first_page
    @first_page ||= (fp = CLI.options[:first]) ? fp.to_i : 1
  end    
  def last_page
    @last_page ||= (lp = CLI.options[:last]) ? lp.to_i : 100000 
  end

  # L'instance PdfBook::Tdm qui gère la table des
  # matière. Permettra d'ajouter les titres pour construire
  # la table des matières finales
  attr_accessor :tdm

  # La [Prawn4book::Fonte] courante
  # 
  attr_reader :current_fonte


  # Instanciation d'un document Prawn::Document
  # -------------------------------------------
  # (en fait un Prawn::View)
  # 
  # @param book [Prawn4book::PdfBook] 
  #   
  #     Le livre en cours de traitement
  # 
  # @param config [Hash] 
  # 
  #     Table de configuration définissant le format de page, les 
  #     marges, etc. Toutes ces données sont prises dans la recette
  #     du livre.
  # 
  def initialize(book, config)
    @book   = book
    @config = config
    # @fonts  = {}
  end

  # Prawn::View en a besoin pour "synchroniser" avec Prawn::Document
  # Dans Prawn::RectifiedDocument se trouvent des surclassement de
  # méthodes
  def document
    @document ||= begin
      Prawn::RectifiedDocument.new(config)
    end
  end


  # --- MARGINS METHODS ---


  def odd_margins
    @odd_margins ||= [top_mg, int_mg, bot_mg, ext_mg]
  end
  def even_margins
    @even_margins ||= [top_mg, ext_mg, bot_mg, int_mg]
  end

  def top_mg; @top_mg ||= config[:top_margin] end
  def bot_mg; @bot_mg ||= config[:bot_margin] end
  def ext_mg; @ext_mg ||= config[:ext_margin] end
  def int_mg; @int_mg ||= config[:int_margin] end


  # --- LINES METHODS ---


  # Déplace le curseur sur la ligne de référence +x+
  # 
  # @param [Integer] x Indice 1-start de la ligne
  # @return l'indice 1-start de la ligne sur laquelle on se trouve
  # maintenant.
  # 
  # @note
  # 
  #   Quand il est question de "ligne" ici, il s'agit de façon 
  #   absolu des lignes de référence telles que définies par la 
  #   donnée line_height courante (qui peut être propre au livre 
  #   entier ou à une page — dans l'annexe par exemple)
  # 
  def move_to_line(x)
    # Top ligne
    # ---------
    next_line_top  = (x - 1) * line_height
    # Déplacement du curseur
    move_cursor_to(bounds.height - next_line_top + ascender)
    return x
  end

  def move_to_first_line
    move_to_line(1)
  end

  # Déplacement du curseur à la prochaine ligne de référence
  def move_to_next_line
    # Ligne courante
    # --------------
    # C'est la distance entre la position actuelle du curseur et le
    # haut de la page (marge considérée), divisée par la hauteur de
    # ligne. On l'arrondit à la valeur plancher
    current_line      = ((bounds.height - cursor).to_f / line_height).ceil

    move_to_line(current_line + 1)
  end

  # @ascender
  # 
  # Il permet de savoir de combien on doit remonter la ligne pour
  # qu'en fonction de sa taille, elle soit posée sur la ligne de
  # référence.
  # 
  # Sa valeur est changée dès que la fonte est modifiée pour le
  # document (avec la méthode #font refactorisée pour Prawn-for-book.
  # 
  def ascender
    @ascender
  end

  def current_leading
    line_height - height_of('X')
  end

  def lines_down(x)
    move_cursor_to(x * line_height + ascender)
  end


  # --- Builing General Methods ---

  ##
  # - NOUVELLE PAGE -
  # 
  # Méthode appelée pour passer à une nouvelle page, de façon
  # volontaire ou naturelle.
  # 
  def start_new_page(options = {})
    # 
    # Réglage des marges de la prochaine page (suivant que c'est une
    # belle page ou une fausse page)
    # 
    new_options = {margin: (page_number.odd? ? odd_margins  : even_margins)}.merge(options)
    # spy "Nouvelle page avec option : #{new_options.inspect}".bleu, true
    super(new_options)
    
    # 
    # Si l'on est en mode pagination hybride (hybrid), il faut 
    # réinitialiser les numéros de paragraphe à chaque nouvelle
    # double page.
    # 
    if page_number.even? && book.recipe.hybrid_numerotation?
      PdfBook::AnyParagraph.reset_numero
    end

  end


  # = Définition de la police courante =
  # 
  # Cette méthode surclasse la méthode Prawn::Document#font qui 
  # permet de définir la fonte courante.
  # 
  # Il existe maintenant 3 façons différentes de définir la fonte :
  # 
  #   - La méthode privilégiée consiste à définir une 
  #     [Prawn4book::Fonte] à l'aide de Fonte.new(name:, style:, 
  #     size:, hname:) et de la donner comme premier argument de cet-
  #     te méthode.
  #   - La méthode "normale", c'est-à-dire avec le nom [String] en 
  #     premier argument et les autres paramètres en second argument.
  #   - Avec un Hash qui contient les paramètres et en plus la pro-
  #     priété :name (ou :font) définissant le nom de la fonte
  # 
  # @return La fonte Prawn courante (note : ce n'est pas l'instance 
  # Prawn4book::Fonte)
  # 
  def font(fonte = nil, params = nil)
    return super if fonte.nil?
    thefont   = nil
    data_font = nil
    case fonte
    when Prawn4book::Fonte
      thefont = fonte
    when String, Symbol
      data_font = params.dup.merge({name:fonte})
    when Hash
      data_font = fonte.dup
      data_font.merge!(name: fonte.delete(:font)) if fonte.key?(:font)
    else
      raise ERRORS[:fonts][:invalid_font_params]
    end

    # Si des données de fonte sont définies, il faut peut-être 
    # instancier une nouvelle fonte.
    # @note data_font est nil seulement lorsque c'est une Prawn::Fonte
    # qui est transmise à la méthode courante.
    # 
    if data_font
      thefont = Prawn4book::Fonte.get_or_instanciate(data_font)      
    end

    @current_font = super(thefont.name, thefont.params)

    # L'ascender courant, qui permet de savoir de combien on doit
    # décaler le texte verticalement pour qu'il repose exactement sur
    # une ligne de référence.
    @ascender = @current_font.ascender

    return @current_font
  end

  #
  # Calcul du leading pour la fonte +fonte+ en considérant une
  # hauteur de ligne de +lineheight+
  # 
  def calc_leading_for(fonte, lineheight)
    begin
      opts = {size:fonte.size, style:fonte.style, leading:0}
      font(fonte) do
        return lineheight - self.height_of('H', **opts)
      end
    rescue Exception => e
      # On passe ici par exemple quand la police n'existe pas
      puts <<~EOT.rouge
        Erreur en calculant le leading pour #{fonte.inspect}
        Erreur : #{e.message}
        EOT
      exit
    end
  end
  alias :leading_for :calc_leading_for



  # --- Predicate Methods ---

  # def paragraph_number?
  #   :TRUE == @hasparagnum ||= true_or_false(book.recette.paragraph_number?)
  # end

  # @predicate True si c'est une belle page (aka page droite)
  def belle_page?
    page_number.odd?
  end

  
  # --- Doc Definition Methods ---

  ##
  # Définition des polices requises (à empaqueter dans le PDF)
  # 
  def embed_fontes(fontes)
    return if fontes.nil? || fontes.empty?
    fontes.each do |fontname, fontdata|
      # On en profite pour vérifier l'existence
      fontdata.each do |style, fspath|
        unless fspath.start_with?('/')
          # <=  Ce n'est pas un chemin absolu
          # =>  On va le chercher dans le dossier de l'application, 
          #     le dossier de la collection (if any) ou le dossier
          #     du livre.
          if File.exist?(File.join(APP_FOLDER, fspath))
            fspath = File.join(APP_FOLDER,fspath)
          elsif File.exist?(File.join(book.folder,fspath))
            fspath = File.join(book.folder,fspath)
          elsif book.in_collection? && File.exist?(File.join(book.collection.folder,fspath))
            fspath = File.join(book.collection.folder,fspath)
          end
          fontdata.merge!(style => fspath)
        end
        File.exist?(fspath) || raise("La police #{fspath} est introuvable…")
      end
      # logif("Famille de police installée : #{fontname.inspect}\n#{fontdata.inspect}")
      font_families.update(fontname.to_s => fontdata)
    end
  end

  def current_font_size
    fsize = 
    if current_options
      current_options[:size] || current_options[:font_size]
    end
    return fsize || font.options[:size]
  end

end #/PrawnView
end #/module Prawn4book
