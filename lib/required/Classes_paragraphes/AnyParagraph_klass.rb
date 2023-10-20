module Prawn4book
class PdfBook
class AnyParagraph
class << self


  # Instanciation du paragraphe à partir de son texte dans le 
  # fichier texte.
  # 
  # @param str [String]
  # 
  #     Texte exact, sans modification, tel qu'il apparait dans le
  #     fichier texte du livre.
  #     Peut être vide (dans la version 2, même les paragraphes vides
  #     sont analysés.)
  # 
  # @param indice [Integer]
  # 
  #     L'indice exact du paragraphe dans le fichier texte source ou
  #     le fichier inclus.
  # 
  # @param file [InputTextFile]
  # 
  #     Le fichier dont est extrait le paragraphe.
  # 
  # @return L'instance paragraphe instancié
  # 
  # @note
  # 
  #   Noter le traitement particulier des tables, qui retourne 
  #   l'instance NTable à la première ligne, puis renvoie NIL en
  #   ajoutant la ligne à l'instance de table initiée.
  # 
  #   Les inclusions de fichiers sont traités en amont, donc ici il
  #   ne devrait plus y avoir aucune balise d'inclusion.
  # 
  def instantiate(book, string, indice, file)

    # Si une table est en cours de traitement et que +string+ n'est
    # plus un élément de table, on met fin à la table.
    if @current_table && not(string.match?(REG_TABLE))
      @current_table = nil 
    end

    # Si un commentaire est ouvert (par <!-- sur une ligne)
    if @current_comment
      if string.match?(REG_END_COMMENT)
        @current_comment.add(string[0...-3].strip)
        @current_comment = nil
      else
        @current_comment.add(string)
      end
      return nil
    end

    case string
    when "" 
      EmptyParagraph.new(book:book, pindex:indice)
    when REG_TITRE
      NTitre.new(book:book, titre:$2, level:$1.length, pindex:indice)
    when REG_IMAGE
      NImage.new(book:book, data_str:$1, pindex:indice)
    when REG_PFBCODE
      PFBCode.new(book:book, raw_code:$1.strip, pindex:indice)
    when REG_COMMENTS
      EmptyParagraph.new(book:book, pindex:indice, text:$1.strip)
    when REG_START_COMMENT
      @current_comment = EmptyParagraph.new(book:book, pindex:indice, text:$1.strip)
    when REG_TABLE
      if @current_table
        @current_table.add_line($1.strip)
        nil
      else
        @current_table = NTable.new(book:book, lines:[$1.strip], pindex:indice)
      end
    else # sinon un paragraphe
      NTextParagraph.new(book:book, raw_text:string, pindex:indice)
    end
  end

  REG_TITRE   = /^(\#{1,6}) (.+)$/.freeze
  REG_IMAGE   = /^IMAGE\[(.+)\]$/.freeze
  REG_PFBCODE = /^\(\( (.+) \)\)$/.freeze
  REG_TABLE   = /^\|(.+)\|$/.freeze
  REG_COMMENTS = /^<\!\-\-(.+)\-\-\>$/.freeze
  REG_START_COMMENT = /^<\!\-\-(.*)/.freeze
  REG_END_COMMENT   = /(.*)\-\-\>$/.freeze

  # Méthodes utiles pour la numérotation
  # 
  # @note
  #   Elles sont mises ici, dans AnyParagraph, mais ne servent pour
  #   le moment que pour le NTextParagraph et le NTable (mais à 
  #   l'avenir, on peut imaginer qu'elles servent aussi pour les
  #   images, qui pourraient être aussi numérotées)
  def reset
    reset_numero
    @numparagisstopped = false
  end
  @last_numero = 0
  def reset_numero
    @last_numero = 0
  end
  def init_first_turn
    reset
  end
  def init_second_turn
    reset
  end
  def get_next_numero
    @last_numero += 1
  end
  def get_current_numero
    @last_numero
  end
  # @return [Integer] le dernier numéro de paragraphe (utilisé par
  # les titres pour connaitre le numéro de leur premier paragraphe)
  # @note
  #   Inauguré pour les références internes, pour que ça fonctionne
  #   avec le titre et une numérotation des paragraphes.
  def last_numero
    @last_numero
  end


  # @return true si un parseur de paragraphe customisé est utilisé
  # (il existe quand un fichier parser.rb, propre au film et/ou à la
  #  collection définit la méthode ParserParagraphModule::paragraph_parser
  #  donc paragraph_parser dans le module ParserParagraphModule
  #  cf. le manuel pour le détail)
  def has_custom_paragraph_parser?
    @@custom_paragraph_parser_exists == true
  end
  def custom_paragraph_parser_exists=(value)
    @@custom_paragraph_parser_exists = value
  end

  def numerotation_paragraphs_stopped?
    @numparagisstopped
  end
  def stop_numerotation_paragraphs
    @numparagisstopped = true
  end
  def restart_numerotation_paragraphs
    @numparagisstopped = false
  end

  # @return la Fonte spécifique pour les paragraphes
  def parag_num_fonte
    @parag_num_fonte ||= begin
      r = Prawn4book::PdfBook.current.recipe
      Fonte.new(
        name:   r.parag_num_font_name,
        size:   r.parag_num_font_size,
        style:  r.parag_num_font_style
      )
    end
  end


  def paragraph_numero_color(strength)
    @paragraph_numero_color ||= begin
      (((100 - strength) * 255 / 100).to_s(16).upcase.rjust(2,'0') * 3 )#.tap { |n| add_notice("Couleur : #{n}") }
      # => p.e. "030303" ou "CCCCCC"
    end
  end


  def diff_height_num_parag_and_parag(pdf)
    @diff_height_num_parag_and_parag ||= begin
      recipe = pdf.pdfbook.recipe
      parag_height = nil
      numer_height = nil
      pdf.font(Prawn4book::Fonte.default_fonte) do
      # pdf.font(recipe.default_font_name, **{size:recipe.default_font_size}) do
        parag_height = pdf.height_of("Mot")
      end
      parnum_font = Fonte.new(
        name:  recipe.parag_num_font_name,
        style: recipe.parag_num_font_style,
        size:  recipe.parag_num_font_size
      )
      pdf.font(parnum_font) do
        numer_height = pdf.height_of("194")
      end
      diff = (parag_height - numer_height).round(3)
      diff - recipe.parag_num_vadjust
    end
  end

end # << self class
end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
