require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class NTitre < AnyParagraph

  attr_reader :level

  # Numéro de paragraphe de titre
  # (correspond au numéro du paragraphe suivant, puisque les
  #  titres ne sont pas numérotés)
  attr_accessor :numero


  def initialize(book:, titre:, level:, pindex:)
    super(book, pindex)
    @type   = 'titre'
    @text   = titre
    @level  = level
    check_inscription_in_tdm
    @lines_before = nil
  end

  def inspect
    "TITRE niveau #{level} “#{text}”"
  end

  # --- Printers Methods ---

  ##
  # Méthode principale qui écrit le titre dans la page
  # 
  # @params [Hash] options
  #     on_this_page: true  Force l’inscription sur la page courante,
  #                         quels que soient les options.
  # 
  def print(pdf, **options)
    # Si le titre a un niveau de 0 (*) il faut s'arrêter là
    # 
    # (*) Cela arrive par exemple avec les titres de bibliographie
    # qui doivent toujours être définis mais pas toujours affichés.
    # 
    # @note
    #   Avant, ce retour se faisait plus bas, après le 'super'.
    # 
    return if level == 0

    my = me = self

    spy "Traitement du titre #{self.inspect}…".bleu

    # - Corrections du texte -
    super(pdf)

    # Le titre formaté
    ftitre = formated_as_title

    on_this_page = options[:on_this_page]

    # Calcul du nombre de ligne avant
    # ===============================
    # Principes
    # ---------
    # Si le paragraphe précédent était un titre, le principe est de 
    # mettre entre les deux titres la plus grande valeur de nombre de
    # lignes. Si, par exemple, il faut 6 lignes après un titre de 
    # niveau 2 et 4 lignes avant un titre de niveau 4, alors, avant 
    # le titre de niveau 4 on ne mettra rien (les 6 lignes du titre 
    # de niveau 2 suffisent). Si, en revanche, il faut 4 lignes après
    # un titre de niveau 2 et 6 lignes avant un titre de niveau 4, 
    # alors, avant le titre 4, il n’y aura que les 4 lignes du titre 
    # de niveau 2. Il faudra donc en ajouter deux.
    lines_before_calc =
      if alone?
        # Pour un titre seul dans la page, on préserve toujours son
        # nombre de ligne avant qui définit sa position dans la page.
        lines_before.dup.freeze
      elsif previous_paragraph && previous_paragraph.title?
        if previous_paragraph.lines_after >= lines_before
          0
        else
          lines_before - previous_paragraph.lines_after
        end
      else
        lines_before.dup.freeze
      end

    debugit = false # ftitre.match?(/recette.+collection/i)

    # = Inscription =
    pdf.update do

      fonte = my.fonte
      font(fonte)

      tstr = ftitre.inspect # débuggage


      # Il faut aussi passer à la page suivante quand il ne reste pas
      # assez de place pour mettre les lignes après (nous sommes trop
      # près du bas)
      # 
      # @note
      #   On ajoute 2 lignes après les lines_after pour avoir la 
      #   place de mettre au moins 2 lignes.
      # 
      limite_basse = cursor - (my.lines_after + lines_before_calc + 2) * line_height

      # spy <<~EOT.bleu
      #   limite_basse pour #{ftitre.inspect} : #{limite_basse.inspect}
      #   Calculée avec :
      #   cursor : #{cursor}
      #   lines after : #{my.lines_after}
      #   lines before (calculées) : #{lines_before_calc}
      #   line_height: #{line_height}
      #   EOT

      unless on_this_page

        start_new_page if limite_basse < line_height || my.on_new_page?

        # - Page seule sur la double page -
        # 
        if my.alone? 
          # puts "#{tstr} est seul sur une double".orange
          # Si la page doit être seule sur une double page et qu'on se
          # trouve actuellement sur une page paire, il faut passer à la
          # page suivante. Mais si, au contraire, on se trouve sur la 
          # page impaire (belle page) mais qu'il y a du texte à gauche,
          # c'est deux pages qu'il faut passer.
          if page_number.even?
            start_new_page
          elsif page_number.odd?
            2.times { start_new_page }
          end
        elsif my.belle_page? 
          # puts "#{tstr} est sur une belle page".orange
          if page_number.even? # paire (= gauche)
            # Si le titre doit être affiché sur une belle page, et qu'on se
            # trouve sur une page paire, il faut encore passer à la page
            # suivante.
            start_new_page
          end
        end

      end # /sauf s’il faut obligatoirement l’inscrire sur cette page
      
      # - Hauteur du titre -
      # (je ne sais plus à quel saint me vouer pour la hauteur… Ici,
      # quelle que soit la fonte, c’est toujours 18, la hauteur de
      # ligne, qui sort, ce qui signifie que c’est la taille affichée
      # que renvoie height_of et non pas la taille réelle que prend
      # la police.
      # title_height = real_height_of(ftitre, **my.title_options)
      # title_height = height_of("VOIR", **my.title_options)
      title_height = my.size

      # spy "title_height de #{tstr} : #{title_height} (size: #{my.size})".bleu, true

      # Pour simplifier (sur le debuggage)
      curpage = book.pages[page_number]

      if my.alone?
        # Si le titre est seul sur la double page, on le
        # descend simplement du nombre de lignes voulu
        move_to_line(my.lines_before + 1)
      elsif cursor + title_height - ascender > bounds.top
        # Si le titre est trop haut, on cherche la première ligne
        # ou il ne dépassera pas.
        # puts "#{tstr} est trop haut (de #{(cursor + title_height) - bounds.top} / par rapport à #{bounds.top.round}).".rouge
        move_to_line(2)
      elsif curpage.empty?
        # En cas de PAGE VIERGE pour le moment (donc commençant par
        # un titre en haut) on laisse le titre en haut quel qu'il 
        # soit
        move_to_line(my.fonte.size > line_height ? 2 : 1)
      else
        # # Titre normal, traité normalement
        # 
        if false # debug
          puts "[Page ##{curpage.number} non vide — length: #{curpage.data[:content_length]}] "\
           "#{tstr} n'est pas trop haut "\
            "(cursor: #{cursor} / curline: #{current_line} / "\
            "lines before: #{my.lines_before}".jaune
        end
        # - Sinon, il suffit de descendre du nombre de lignes 
        #   voulues -
        move_to_line(current_line + 1 + lines_before_calc)
      end

      # Ajout du titre courant à la donnée de la page courante du 
      # livre (book.pages)
      my.add_this_titre_in_page(self)

      ###############################
      ###   IMPRESSION DU TITRE   ###
      ###############################
      if my.left || my.right
        # --- CAS OÙ left OU right EST DÉFINI ---
        lf = my.left || bounds.width - my.right - width_of(ftitre, **my.title_options)
        w  = bounds.width - lf
        sup_data = {at: [lf, cursor], width: w}
        formatted_text_box([my.title_options.merge({text:ftitre})], sup_data)
        # @note: Il peut y avoir des comportements imprévus, ici, en
        # cas ce titre sur plusieurs lignes
      else
        # --- CAS NORMAL (sans left ni right) ---
        text(ftitre, **my.title_options)
      end
      move_to_next_line

      if me.alone?
        
        start_new_page

      else

        ###################################
        ### Traitement des LIGNES APRÈS ###
        ###################################
        # Principe
        # --------
        # On ajoute toujours les lignes après. C’est avant qu’on
        # traite le problème de titres successifs.
        move_down( my.lines_after * line_height )
      end

      update_current_line

    end #/pdf.update

  end
  # /print

  # Quelques opérations de formatage sur le titre
  # 
  def formated_as_title
    # Mettre le titre en capitale (si demandé)
    # 
    # Mais attention, il ne faut pas que les marquages de format
    # passent en majuscule car Prawn ne sait pas interpréter "<em>"
    # comme "<EM>".
    # Il restait quand même une faiblesse ici : si les balises qui 
    # contenaient des capitales seraient remplacées par des balises
    # avec seulement des minuscules. Il faut un traitement plus fin 
    # qui ne mette en majuscules que le texte. Il faut donc procéder 
    # ainsi : on retire toutes les balises HTML et on les met dans 
    # une table en les remplaçant provisoirement par _BALHTMLxxx_ 
    # puis on remet les balises originales après la capitalisation.
    str = text.dup
    if caps || caps == 'all-caps'
      str = str.all_caps
    end

    return str
  end #/formated_as_title

  # Ajout du titre à la table des matières et à la page d’index
  # +page_number+
  # 
  # 
  def add_this_titre_in_page(pdf)
    page_number = pdf.page_number
    # @note @todo
    #   Je ne comprends pas vraiment pourquoi je ne fais pas un 
    #   nouveau numéro.
    num = AnyParagraph.get_current_numero
    in_tdm? && pdf.tdm.add_title(self, page_number, num + 1)
    # Ajout du titre aux titres courants (et aux titres de la page)
    book.set_current_title(self, page_number)    
  end

  # @return [Hash] Les paramètres pour la méthode PrawnView#text
  # 
  # @note
  # 
  #   La propriété :is_title a été ajoutée pour ne pas ajouté
  #   de longueur de contenu quand c'est un titre qui est 
  #   ajouté.
  #   Cf. les wrappers Prawn créés.
  # 
  def title_options
    @title_options ||= begin
      tbl = {
        is_title: true, 
        inline_format: true,
        size:  self.size,
        color: color,
      }
      if align 
        tbl.merge!(align: align)
      elsif right
        tbl.merge!(right: right)
      elsif left
        tbl.merge!(left: left)
      end
      tbl.freeze
    end
  end

  # --- Data Methods ---

  # @return [Prawn4book::Fonte] Instance Fonte pour ce niveau de
  # titre
  def fonte
    @fonte ||= PdfBook::NTitre.fonte(level)
  end
  def size
    @size ||= fonte.size
  end

  def color 
    @color ||= PdfBook::NTitre.color(level)
  end

  def align
    @align ||= PdfBook::NTitre.align(level)
  end

  def left
    @left ||=  PdfBook::NTitre.left(level)
  end

  def right
    @right ||=  PdfBook::NTitre.right(level)
  end

  def caps
    @caps ||= PdfBook::NTitre.caps(level)
  end

  # @prop {Integer} Espace avec le texte suivant
  def lines_after
    @lines_after ||= self.class.lines_after(level)
  end
  # Définition manuelle
  def lines_after=(value)
    @lines_after = value
  end

  # @prop {Integer} Espace avec le texte précédent
  # Ce nombre varie en fonction du contexte, il doit être calculé
  # précisément pour chaque titre.
  # 
  # PRINCIPES
  # ---------
  #   - si le nombre de lignes a été expressément défini dans le
  #     fichier, on applique cette valeur
  #   - si le paragraphe (imprimé) précédent est un titre, il ne faut
  #     ajouter aucune ligne avant
  #   - Sinon, on retourne le nombre de ligne avant correspondant
  #     à la définition dans la recette.
  # 
  def lines_before
    @lines_before ||= NTitre.lines_before(level)
  end

  # Définition manuelle
  def lines_before=(value)
    @lines_before = value
  end

  # --- Predicate Methods ---

  # @return true si on doit inscrire le titre dans la table des
  # matières (true par défaut)
  def in_tdm?
    @writeit_in_tdm
  end

  def on_new_page?
    :TRUE == @isonnewpage ||= true_or_false(alone? || next_page? || belle_page?)
  end

  def alone?
    :TRUE == @alone ||= true_or_false(NTitre.alone?(level))
  end
  def next_page?
    :TRUE == @onnewpage ||= true_or_false(NTitre.next_page?(level))
  end

  def belle_page?
    :TRUE == @onbellepage ||= true_or_false(NTitre.belle_page?(level))
  end

  def title?      ; true  end
  def some_text?  ; true  end
  def printed?    ; true  end

  # --- Data Methods ---

  # @return true si le prochain paragraphe imprimé et un titre
  # 
  # Attention : il peut se glisser un pfbcode pour modifier le
  # titre
  def next_is_title?
    not(next_if_title.nil?)
  end

  # @return le prochain paragraphe imprimé si c'est un titre
  def next_if_title
    @next_if_title ||= begin
      pidx  = pindex.dup
      while nextpar = book.paragraphes[pidx += 1]
        if nextpar.paragraph? || nextpar.image? || nextpar.table?
          nextpar = nil 
          break 
        end
        break if nextpar.title?
      end
      nextpar
    end
  end

  private

    # Pour définir si on doit inscrire le titre dans la table
    # des matières
    def check_inscription_in_tdm
      txt = text.dup
      @writeit_in_tdm = not(txt.match?(/\{no[_\-](tdm|toc)\}/i))
      txt = txt.gsub(/\{no[_-](tdm|toc)\}/,'').strip unless @writeit_in_tdm
      @text = txt
    end

  public

  # --- MÉTHODES DE CLASSES ---

  def self.lines_after(level)
    get_data(:lines_after, level)
  end

  def self.lines_before(level)
    get_data(:lines_before, level)
  end

  def self.color(level)
    get_data(:color, level, '000000')
  end

  def self.align(level)
    get_data(:align, level, nil).to_sym
  end

  def self.left(level)
    get_data(:left, level, nil).to_pps
  end

  def self.right(level)
    get_data(:right, level, nil).to_pps
  end

  def self.caps(level)
    get_data(:caps, level, nil).to_sym
  end

  def self.alone?(level)
    return false if level < 1
    get_data(:alone, level) === true
  end

  def self.next_page?(level)
    return false if level < 1
    alone?(level) || get_data(:next_page, level) === true
  end

  def self.belle_page?(level)
    return false if level < 1
    get_data(:belle_page, level) === true
  end

  ##
  # @return [Any] La valeur +property+ pour le niveau de titre
  # +level+
  # @note
  #   On n'utilise plus cette méthode pour le :name, :size et :style
  #   de la police, puisqu'elle est gérée par Prawn4book::Fonte. On
  #   ne s'en sert plus que pour les lignes avant/après, etc.
  # 
  def self.get_data(property, niveau, default = nil)
    if data_titles.key?(key_niveau = :"level#{niveau}")
      return data_titles[key_niveau][property] || default
    else
      default
    end
  end

  DEFAULT_SIZES = {
    1 => 24.5,
    2 => 22.5,
    3 => 20.5,
    4 => 18.5,
    5 => 16.5,
    6 => 14.5,
    7 => 12.5
  }.freeze

  class << self

    # @return La fonte instanciée pour le titre de niveau +level+
    def fonte(level)
      @fontes ||= {}
      @fontes[level] ||= data_fonte_level(level)
    end

    # Retourne les données de fonte pour le titre de niveau +level+
    def data_fonte_level(level)
      dtitle = data_titles["level#{level}".to_sym]||{}
      default_values = default_fonte.values.merge(size: DEFAULT_SIZES[level])
      Fonte.get_in(dtitle, default_values).or_default
    end

    # @return la fonte par défaut pour tous les titres
    # 
    def default_fonte
      @default_fonte ||= Fonte.get_in(data_titles).or_default
    end

    def data_titles
      @data_titles ||= recipe.format_titles
    end

    # - Raccourci -
    def recipe
      PdfBook.current.recette
    end

  end #/<< self


end #/class NTitre
end #/class PdfBook
end #/module Prawn4book
