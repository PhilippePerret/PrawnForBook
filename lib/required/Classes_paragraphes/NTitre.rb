require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class NTitre < AnyParagraph

  attr_reader :level

  # Numéro de page du titre
  attr_accessor :page_numero

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
  def print(pdf)

    # Si le titre a un niveau de 0* il faut s'arrêter là
    # 
    # *Cela arrive par exemple avec les titres de bibliographie qui
    # doivent toujours être définis mais pas toujours affichés.
    # 
    # @note
    #   Avant, ce retour se faisait plus bas, après le 'super'.
    # 
    return if level == 0

    titre = my = me = self

    spy "Traitement du titre #{self.inspect}…".bleu

    # 
    # Faut-il passer à la page suivante ?
    # C'est le cas si la propriété :next_page est à true dans la
    # recette, pour ce titre. Ou si c'est sur une belle page que le
    # titre doit être affiché.
    # 
    pdf.start_new_page if on_new_page?


    if alone? && pdf.page_number.odd?
      #
      # Si le titre doit être seul, il doit être seul non seulement
      # sur sa page mais sur la double page. Donc, si après avoir dé-
      # placé le curseur sur la page suivante, on se trouve sur une
      # belle page, alors il faut passer deux pages
      # 
      2.times { pdf.start_new_page }

    elsif belle_page? && pdf.page_number.even?
      # 
      # Si le titre doit être affiché sur une belle page, et qu'on se
      # trouve sur une page paire, il faut encore passer à la page
      # suivante.
      # 
      pdf.start_new_page

    end

    #
    # Quelques traitements communs à tous les textes, comme la
    # retenue du numéro de la page ou le préformatage pour les
    # éléments textuels.
    # 
    super


    # 
    # Principes de placement du titre
    # 
    # Si on est sur une nouvelle page (#on_new_page?)
    #   - si le titre a un niveau < 3
    #     => on applique les lignes avant
    #   - si le titre a un niveau > 2
    #     => on n'applique pas les lignes avant
    # 
    # Le titre peut "manger" sur la marge haute, il faut donc 
    # s'assurer qu'il est assez bas (deuxième ou troisième ligne de
    # référence)
    # 
    # Le titre ne doit pas se retrouver seul en bas de page (en 
    # comptant les "lignes après" qui doivent le séparé du texte ou 
    # de l'image ou du titre suivant)
    # (le calcul est plus compliqué ici)

    pdf.update do

      font(my.fonte)

      # Le titre formaté
      ftext = my.text

      # Nombre de ligne avant le titre
      lines_before = my.lines_before
      move_down(lines_before * line_height)

      # Empêcher le titre de "manger" sur la marge haute
      ary = Prawn::Text::Formatted::Parser.format(ftext, [])
      title_height = height_of_formatted(ary)
      if cursor + title_height > bounds.top
        move_cursor_to(bounds.top - title_height)
        move_to_next_line
      end

      lines_after  = my.lines_after 

      # Le titre ne doit pas se retrouver tout seul en bas de
      # page et il faut que le texte qui suit :
      #   - possède au moins deux lignes
      #   - ne soit pas un titre (qui poserait le même problème)
      next_cursor = cursor - lines_after * line_height
      if next_cursor < 0
        start_new_page
      elsif my.next_is_title?
        if cursor - (lines_after + my.next_if_title.lines_after) * line_height < 0
          start_new_page
        end
      end

      ###########################
      # - IMPRESSION DU TITRE - #
      ###########################
      #
      text(ftext, **my.text_params.merge(size:my.size, leading:my.leading(self)))

      if me.alone?
        start_new_page
      elsif lines_after > 0
        move_down(lines_after * line_height) 
      else
        move_to_next_line
      end

    end #/pdf.update

    # 
    # Ajout du titre à la table des matières
    # 
    num = pdf.previous_text_paragraph ? pdf.previous_text_paragraph.numero : 0
    in_tdm? && pdf.tdm.add_title(self, pdf.page_number, num + 1)
  
  end
  # /print

  # @return [Hash] Les paramètres pour la méthode PrawnView#text
  # 
  # @note
  # 
  #   La propriété :is_title a été ajoutée pour ne pas ajouté
  #   de longueur de contenu quand c'est un titre qui est 
  #   ajouté.
  #   Cf. les wrappers Prawn créés.
  # 
  def text_params
    @text_params ||= {is_title: true, align: :left, inline_format: true}.freeze
  end

  # --- Data Methods ---

  def leading(pdf)
    ld = pdf.line_height - pdf.height_of('X')
    ld = 2 * pdf.line_height - pdf.height_of('X') if ld < 0
    return ld
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
    if level > 2 && on_new_page?
      0
    elsif not(@lines_before.nil?)
      @lines_before
    elsif prev_printed_paragraph && prev_printed_paragraph.titre?
      0
    else
      self.class.lines_before(level)
    end
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
    :TRUE == @alone ||= true_or_false(self.class.alone?(level))
  end
  def next_page?
    :TRUE == @onnewpage ||= true_or_false(self.class.next_page?(level))
  end

  def belle_page?
    :TRUE == @onbellepage ||= true_or_false(self.class.belle_page?(level))
  end

  def sometext? ; true  end
  def titre?    ; true  end

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
      while nextpar = book.inputfile.paragraphes[pidx += 1]
        if nextpar.paragraph? || nextpar.image? || nextpar.table?
          nextpar = nil 
          break 
        end
        break if nextpar.titre?
      end
      nextpar
    end
  end

  private

    # Pour définir si on doit inscrire le titre dans la table
    # des matières
    def check_inscription_in_tdm
      txt = text.dup
      @writeit_in_tdm = not(txt.match?(/\{no[_\-]tdm\}/i))
      txt = txt.gsub(/\{no[_-]tdm\}/,'').strip unless @writeit_in_tdm
      @text = txt
    end

  public

  # --- MÉTHODES DE CLASSES ---

  def self.lines_after(level)
    laft = get_data(:lines_after, level)
    return laft
  end

  def self.lines_before(level)
    lbef = get_data(:lines_before, level)
    # lbef = 1 if level > 1 && lbef === 0
    return lbef
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
  def self.get_data(property, niveau)
    key_niveau = :"level#{niveau}"
    unless data_titles[key_niveau].key?(property)
      spy "data_titles[key_niveau] ne connait pas la clé #{property.inspect}. Ne connait que les clés : #{data_titles[key_niveau].keys.inspect}".rouge
    end
    return data_titles[key_niveau][property]
  end

  def self.data_titles
    @@data_titles ||= PdfBook.current.recette.format_titles
  end

end #/class NTitre
end #/class PdfBook
end #/module Prawn4book
