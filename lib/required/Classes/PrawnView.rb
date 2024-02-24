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
  attr_reader :current_font


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
    @book           = book
    @config         = config
    @current_fonte  = nil
  end

  # Prawn::View en a besoin pour "synchroniser" avec Prawn::Document
  # Dans Prawn::RectifiedDocument se trouvent des surclassement de
  # méthodes
  def document
    @document ||= begin
      Prawn::RectifiedDocument.new(config)
    end
  end

  # --- CALCUL METHODS ---

  # Quand line_height est défini (toujours dans Prawn-for-book), 
  # appelé height_of ou height_of_formatted est vain puisque renvoie
  # toujours un multiple de height_of (car height_of ne renvoie pas
  # vraiment la hauteur de +str+ mais la hauteur que prendra l'im-
  # pression de +str+)
  # La méthode suivante, au contraire, permet de calculer la vraie
  # valeur dans le contexte courant.
  # 
  # @note
  #   J’ai dû modifier la méthode #text_box pour pouvoir faire ça
  #   De base, elle ne permet pas d’utiliser :dry_run
  # 
  def real_height_of(str, **options)
    e, b = text_box(str, **options.merge(dry_run: true))
    return b.height
  end

  # --- MARGINS METHODS ---


  def odd_margins
    @odd_margins ||= [top_mg, int_mg, bot_mg, ext_mg]
  end
  # Pour changer à la volée
  def odd_margins=(value); @odd_margins = value end

  def even_margins
    @even_margins ||= [top_mg, ext_mg, bot_mg, int_mg]
  end
  # Pour changer à la volée
  def even_margins=(value); @even_margins = value end

  def top_mg; @top_mg ||= config[:top_margin] end
  def bot_mg; @bot_mg ||= config[:bot_margin] end
  def ext_mg; @ext_mg ||= config[:ext_margin] end
  def int_mg; @int_mg ||= config[:int_margin] end

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
    
    # Si une fonte est définie (c'est-à-dire si on n'en est pas au
    # tout début) On se place sur la première ligne
    if font
      move_to_line(1)
      cursor.round == (bounds.top - (1 * line_height) + ascender).round || begin
      # cursor.round == (bounds.top - (1 * line_height) + ascender).round || begin
        puts "ON N'EST PAS SUR LA PREMIÈRE LIGNE".rouge
        puts <<~ERR.rouge
          La position du curseur (#{cursor.round}) devrait être égale
          à la hauteur de page #{bounds.top.round} à laquelle on 
          ajoute l'ascender #{ascender.round} (ce qui fait #{(bounds.top + ascender).round})
          auquel on soustrait la hauteur de line (#{line_height}) ce qui donne
          #{(bounds.top - line_height + ascender).round}
          Sans arrondissement :
            Curseur : #{cursor}
            Calcul  : #{bounds.top - line_height + ascender}
          ERR
        exit
      end
    end

    # 
    # Si l'on est en mode pagination hybride (hybrid), il faut 
    # réinitialiser les numéros de paragraphe à chaque nouvelle
    # double page.
    # 
    if page_number.even? && book.recipe.hybrid_numerotation?
      PdfBook::AnyParagraph.reset_numero
    end

  end #/start_new_page

  # Appelé pour suspendre la pagination des pages
  # 
  # @note
  #   - Appelant en-ligne par (( stop_pagination ))
  #   - La pagination sera reprise quand la méthode 
  #     #restart_pagination sera invoquée.
  # 
  def stop_pagination
    @pagination_is_stopped = true
  end

  # Appelée pour reprendre une pagination interrompue par 
  # #stop_pagination
  # 
  def restart_pagination
    @pagination_is_stopped = false
  end

  def pagination_stopped?
    @pagination_is_stopped === true
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


    thefont = 
      case fonte
      when Prawn4book::Fonte
        fonte
      when String, Symbol
        Fonte.get_or_instanciate((params||{}).dup.merge({name:fonte}))
      when Hash
        data_font = fonte.dup
        data_font.merge!(name: fonte.delete(:font)) if fonte.key?(:font)
        Fonte.get_or_instanciate(data_font)
      else
        raise ERRORS[:fonts][:invalid_font_params]
      end


    # On applique la fonte seulement si elle a changé. Sinon,
    # on s'en retourne aussitôt.
    # 
    # @noter que le changement de fonte est une opération qui doit se
    # faire extrêmement souvent [1], d'où l'importance de conserver 
    # les instances Fonte, de ne pas les refaire à chaque fois.
    # [1] À chaque titre, et même à chaque paragraphe si on est en
    # numérotation de paragraphe.
    # 
    return if thefont == @current_fonte

    # spy "APPLICATION DE LA FONTE #{fonte.inspect}"

    # Pour avoir aussi la fonte courante dans Fonte
    # 
    # @noter que la classe ici est Prawn4book::Fonte alors que la
    # fonte de @current_font est une instance Prawn::Document::Fonte
    # (ou quelque chose comme ça)
    Prawn4book::Fonte.current = thefont
    
    begin
        @current_fonte  = thefont
        @current_font   = super(thefont.name, thefont.params)
    rescue Prawn::Errors::UnknownFont
      spy "--- fonte inconnue ---"
      spy "Fontes : #{book.recipe.get(:fonts).inspect}"
      raise
    end

    # - Calcul des valeurs propres à la fonte appliquée -

    # L'ascender courant, qui permet de savoir de combien on doit
    # décaler le texte verticalement pour qu'il repose exactement sur
    # une ligne de référence.
    @ascender         = @current_font.ascender

    move_to_closest_line

    return @current_font
  end

  # [Prawn4book::Fonte] La fonte courante
  def current_fonte
    @current_fonte
  end


  # --- Predicate Methods ---

  # @predicate True si c'est une belle page (aka page droite)
  def belle_page?
    page_number.odd?
  end

end #/PrawnView
end #/module Prawn4book
