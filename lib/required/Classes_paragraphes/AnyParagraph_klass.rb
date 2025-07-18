module Prawn4book
class PdfBook
class AnyParagraph

  REG_TITRE         = /^(\#{1,6}) (.+)$/.freeze
  
  REG_OLD_IMAGE     = /^IMAGE\[(.+?)(?:\|(.+))?\]$/.freeze
  REG_NEW_IMAGE     = /^\!\[(.+?)\](?:\((.+?)\))?$/.freeze
  REG_AMORCE_IMAGE  = /^(?<!\\)(\!|IMAGE)\[/.freeze

  REG_PFBCODE       = /^\(\( (.+) \)\)$/.freeze
  REG_TABLE         = /^\|(.+)\|$/.freeze
  REG_END_TABLE     = /^\|\/\|$/.freeze
  REG_COMMENTS      = /^\[#\] (.*)$/.freeze
  REG_START_COMMENT = /^\[#(.*)/.freeze
  # Noter que les commentaires dans le texte ou dans le code [#...#]
  # sont retirés tout au début du travail du fichier
  REG_END_COMMENT   = /(.*)#\]$/.freeze
  REG_CODE_BLOCK    = /#{EXCHAR}(?:\~\~\~|\`\`\`)/.freeze
  REG_END_CODE_BLOCk   = /^#{REG_CODE_BLOCK}$/.freeze 
  REG_START_CODE_BLOCK = /^#{REG_CODE_BLOCK}([a-zA-Z]+)?$/.freeze

class << self

  # Reçoit le paragraphe brut et retourne l'instance de paragraphe
  # corresdondante.
  # Par exemple, un +string+ commençant par "### " est un titre donc
  # une instance NTitre. Un string commençant par "| " et terminant
  # par " |" est une table, etc.
  def instance_type_from_string(book:, string:, indice:, options: {})
    if options[:is_code]
      NTextParagraph.new(book:book, raw_text:string, pindex:indice, options: options)
    else
      case string
      when "" 
        EmptyParagraph.new(book:book, pindex:indice)
      when REG_TITRE
        NTitre.new(book:book, titre:$2, level:$1.length, pindex:indice)
      when REG_AMORCE_IMAGE
        string = string.strip # généraliser à un moment ?
        unless (d = string.match(REG_OLD_IMAGE))
          d = string.match(REG_NEW_IMAGE)
        end
        NImage.new(book:book, path:d[1], data_str:d[2], pindex:indice)
      when REG_PFBCODE
        PFBCode.new(book:book, raw_code:$1.strip, pindex:indice)
      when REG_COMMENTS
        EmptyParagraph.new(book:book, pindex:indice, text:$1.strip)
      when REG_START_COMMENT
        EmptyParagraph.new(book:book, pindex:indice, text:$1.strip).tap do |pa|
          pa.is_comment= true
        end
      when REG_START_CODE_BLOCK
        CodeBlock.new(book:book, pindex:indice, language:$1)
      when REG_TABLE
        NTable.new(book:book, raw_lines:[$1.strip], pindex:indice)
      else # sinon un paragraphe
        NTextParagraph.new(book:book, raw_text:string, pindex:indice, options: options)
      end
    end
  rescue Exception => e
    raise PFBFatalError.new(104, {ln: e.line, s:string, i: indice, e: e.message, opts:options.inspect})
  end #/ instance_type_from_string

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

  def numerotage_paragraph?
    return false if numerotation_paragraphs_stopped?
    return recipe.paragraph_number?
  end
  def numerotation_paragraph?
    
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

  # @return la Fonte spécifique pour les numéros de paragraphes
  def parag_num_fonte
    @parag_num_fonte ||= begin
      Prawn4book::PdfBook.current.recipe.parag_num_font
    end
  end

  def paragraph_numero_color(strength)
    @paragraph_numero_color ||= begin
      (((100 - strength) * 255 / 100).to_s(16).upcase.rjust(2,'0') * 3 )#.tap { |n| add_notice("Couleur : #{n}") }
      # => p.e. "030303" ou "CCCCCC"
    end
  end

  ##
  # Méthode pour définir les propriétés du paragraphe suivant, depuis
  # un programme ou depuis un paragraphe qui n’est pas un PfbCode (qui
  # utilise @next_parag_style)
  #
  # Cette méthode appelée sans argument retourne les propriétés 
  # enregistrées et les efface. Elle est systématiquement appelée par
  # les paragraphes.
  # 
  def next_paragraph_styles(values = nil)
    if values.nil?
      retour = (@__next_paragraph_styles || {}).freeze
      @__next_paragraph_styles = nil
      return retour
    else
      @__next_paragraph_styles = values
    end
  end

end # << self class
end #/class AnyParagraph
end #/class PdfBook
end #/module Prawn4book
