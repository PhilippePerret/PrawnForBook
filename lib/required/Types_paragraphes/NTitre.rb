require_relative 'AnyParagraph'

module Prawn4book
class PdfBook
class NTitre < AnyParagraph

  # Numéro de page du titre
  attr_accessor :page_numero

  # Numéro de paragraphe de titre
  # (correspond au numéro du paragraphe suivant, puisque les
  #  titres ne sont pas numérotés)
  attr_accessor :numero

  attr_reader :data

  def initialize(pdfbook, data)
    super(pdfbook)
    @data = data.merge!(type: 'titre')
    @numero = (1 + AnyParagraph.last_numero).freeze
    check_inscription_in_tdm
  end

  def inspect
    "TITRE niveau #{level} “#{text}”"
  end



  # --- Printers Methods ---

  ##
  # Méthode principale qui écrit le titre dans la page
  # 
  def print(pdf)
    titre = self

    spy "Traitement du titre #{self.inspect}…".bleu

    # 
    # Faut-il passer à la page suivante ?
    # C'est le cas si la propriété :next_page est à true dans la
    # recette, pour ce titre. Ou si c'est sur une belle page que le
    # titre doit être affiché.
    # 
    if next_page? || belle_page?
      spy "Nouvelle page".bleu
      pdf.start_new_page 
    end
    # 
    # Si le titre doit être affiché sur une belle page, et qu'on se
    # trouve sur une page paire, il faut encore passer à la page
    # suivante.
    # 
    if belle_page? && pdf.page_number.even?
      spy "Nouvelle page pour se trouver sur une belle page".bleu
      pdf.start_new_page
    end

    #
    # Quelques traitements communs, comme la retenue du numéro de
    # la page ou le préformatage pour les éléments textuels.
    # 
    super

    #
    # Application de la fonte
    # 
    ft = pdf.font(titre.fonte)

    # 
    # Formatage du titre
    # 
    # titre.preformate(pdf) -- fait dans super
    titre.final_formatage(pdf)
    ftext = titre.final_text
    # ftext = titre.formated_text(self)

    #
    # Nombre de lignes avant
    # 
    # Si le paragraphe précédent était un titre, on n'applique pas
    # le réglage linesBefore de ce titre.
    # Si le titre est trop grand pour la page, il faut ajouter des
    # :lines_before
    # 
    # QUESTION : en haut de page, faut-il systématiquement supprimer
    # les lignes avant ? Faudrait-il un paramètre 
    #   :skip_lines_before_on_page_top
    if pdf.previous_paragraph_titre?
      linesBefore = 0 
    else
      linesBefore = self.lines_before
    end
    # 
    # Nombre de lignes après
    # 
    linesAfter  = self.lines_after

    pdf.update do

      #
      # On place le titre au bon endroit en fonction des lignes
      # qu'il faut avant.
      # 
      if linesBefore > 0
        move_down(linesBefore * line_height)
        spy "Ligne avant le titre : #{linesBefore}"
      else
        spy "Pas de lignes avant le titre".gris
      end

      # 
      # On déplace le curseur sur la prochaine ligne
      # de base
      # 
      move_cursor_to_next_reference_line

      #
      # Si c'est un titre (ou pas…) et qu'il va manger sur la
      # marge haute, on le descend d'autant de lignes de référence
      # que nécessaire pour qu'il tienne dans la page.
      # 
      text_height = height_of(ftext.split(' ').first)
      while (cursor - 2 * line_height) + text_height > bounds.top
        move_down(line_height)
      end

      # 
      # Écriture du titre
      # 
      text ftext, align: :left, size: titre.size, leading: leading, inline_format: true
      spy "Cursor après écriture titre : #{cursor.inspect}".bleu

      #
      # On place le cursor sur la ligne suivante en fonction
      # du nombre de lignes qu'il faut laisser après
      # 
      if linesAfter > 0
        move_down(linesAfter * line_height)
        spy "Lignes après le titre : #{linesAfter.inspect}"
      else
        spy "Pas de lignes après le titre".gris
      end
    end

    # 
    # Ajout du titre à la table des matières
    # 
    num = pdf.previous_text_paragraph ? pdf.previous_text_paragraph.numero : 0
    in_tdm? && pdf.tdm.add_title(self, pdf.page_number, num + 1)
  end


  # --- Data Methods ---

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
  def citation? ; false end
  def list_item?; false end

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
