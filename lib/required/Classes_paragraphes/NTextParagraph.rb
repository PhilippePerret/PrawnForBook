require_relative 'AnyParagraph'
module Prawn4book
class PdfBook
class NTextParagraph < AnyParagraph

  attr_reader :text
  attr_reader :raw_text
  attr_reader :numero

  def initialize(book:, raw_text:, pindex:)
    super(book, pindex)
    @type = 'paragraph'
    @raw_text = raw_text
    #
    # On regarde tout de suite la nature du paragraphe (item
    # de liste ? citation ? etc. pour pouvoir faire un pré-traitement
    # de son texte et pré-définir ses styles)
    pre_parse_text_paragraph
  end

  ##
  # Pré-parsing du paragraphe à l'instanciation
  # Permet de définir sa nature, par exemple citation ou item de
  # liste
  # 
  def pre_parse_text_paragraph

    @is_note_page   = raw_text.match?(REG_NOTE_PAGE)
    @is_citation    = raw_text.match?(REG_CITATION)
    @is_list_item   = raw_text.match?(REG_LIST_ITEM)
    @is_wrapped     = raw_text.start_with?('!')

    # En cas de citation ou d'item de liste, on retire la marque
    # de début du paragraphe ("> " ou "* ")
    @raw_text = raw_text[1..-1].strip if citation? || list_item? || wrapped?

    recup = {}
    tx = NTextParagraph.__get_class_tags_in(raw_text, recup)
    self.class_tags = recup[:class_tags]
    @raw_text = tx
    
    # 
    # Pré-définition des styles en fonction de la nature du paragra-
    # phe de texte
    # 
    if citation?
      @text = "<i>#{@text}</i>"
      add_style({size: font_size + 1, left: 1.cm, right: 1.cm, top: 0.5.cm, bottom: 0.5.cm, no_num:true})
    end

  end #/pre_parse_text_paragraph

  REG_CITATION    = /^> .+$/.freeze
  REG_LIST_ITEM   = /^\* .+$/.freeze
  REG_NOTE_PAGE   = /^(?<!\\)\^[0-9^]/.freeze

  # --- Printing Methods ---

  ##
  # Méthode principale d'écriture du paragraphe
  # @note
  #   C'est vraiment cette méthode qui écrit un paragraphe texte,
  #   en plaçant le curseur, en réglant les propriétés, etc.
  # 
  def print(pdf)

    # Si c’est un paragraphe enroulé (sous-entendu : autour d’une
    # image), on ne l’imprime pas ici.
    return if wrapped?

    @pdf = pdf


    # À chaque tour, on doit corriger le texte, le préparer 
    # entièrment (et le mettre dans @text).
    @text = raw_text.dup
    #
    # Tous les traitements communs, comme la retenue du numéro de
    # la page ou le préformatage pour les éléments textuels.
    # 
    super
    
    #
    # Si le paragraphe possède son propre builder, on utilise ce
    # dernier pour le construire et on s'en retourne.
    # Un paragraphe possède son propre builder lorsque :
    #   - il est taggué  (précédé de "<style>::")
    #   - il existe une méthode pour construire ce tag dans 
    #     formater.rb, de nom  build_<style>_paragraph
    # 
    return own_builder(pdf) if own_builder?

    #
    # Le texte a pu être déjà écrit par les formateurs personnalisés
    # Dans ce cas, on écrit le numéro du paragraphe si nécessaire et
    # on s'en retourne.
    # 
    # @note
    #   Si le paragraphe doit être numéroté, il faut que la méthode
    #   de formatage elle-même s'en occupe (celle qui met le texte
    #   à nil si c'est le cas, parce qu'elle s'en occupe)
    # 
    if @text.nil? || @text == ""
      return 
    end

    no_num = styles[:no_num] || false

    #
    # Pour invoquer cette instance dans le pdf.update
    # 
    par = my = self

    # - Une puce pour les items de liste -
    if list_item?
      dpuce = book.recipe.puce
      left  = dpuce.delete(:left)
      dry_options.merge!({
        puce:   dpuce,
        at:     [left, nil],
        width:  pdf.bounds.width - left,
        no_num: true,
      })
    elsif indentation
      # Si ce n’est pas un item de liste et qu’il y a une indentation,
      # on ajoute l’espace voulu
      unless no_indentation || prev_printed_paragraph.title? || not(prev_printed_paragraph.some_text?)
        @text = "#{string_indentation}#{text}"
      end
    end

    ###########################
    #  ÉCRITURE DU PARAGRAPHE #
    ###########################
    # 
    # Voir Printer::pretty_render
    # 
    Printer.pretty_render(
      owner:    self,
      pdf:      pdf, 
      fonte:    fonte,
      text:     text,
      options:  dry_options
    )

    # 
    # On prend la dernière page du paragraphe, c'est toujours celle
    # sur laquelle on se trouve maintenant
    # 
    self.last_page = pdf.page_number

  end #/print

  def dry_options
    @dry_options ||= {
      inline_format:true, 
      overflow: :truncate, 
      at:    [margin_left, nil],
      width: width || (@pdf.bounds.width - margin_left),
      # indent_paragraphs: indentation, 
      align: text_align
    }
  end

  # La fonte pour la paragraphe
  # 
  # Elle peut être définie par un pfbcode avant le paragraphe
  # 
  def fonte
    @fonte ||= begin
      if styles[:font_family] || styles[:font_size] || styles[:font_style]
        Fonte.new(name:font_family, size:font_size, style:font_style)
      elsif prev_pfbcode && prev_pfbcode.font_change?
        Fonte.current
      else
        Fonte.default_fonte
      end
    end
  end

  def indentation
    @indentation ||= book.recipe.text_indent
  end
  def string_indentation
    @string_indentation ||= self.class.string_indentation
  end
  # Pour modifier dynamiquement l’indentation
  def indentation=(value)
    if value.nil?
      @indentation = nil  
      @string_indentation = nil
    else
      @indentation = value.to_pps
      @string_indentation = self.class.calc_indentation(pdf, indentation)
    end
  end
  # Pour supprimer dynamiquement l’indentation s’il y en a
  def no_indentation=(value)
    @no_indentation = value
  end
  def no_indentation; @no_indentation || false end

  class << self
    # Création de l’indentation artificielle à l’aide d’espaces
    def string_indentation
      @string_indentation ||= calc_string_indentation(pdf, expected_length)
    end

    def calc_string_indentation(pdf, expected_length)
      @string_indentation = calc_indentation(pdf, expected_length)
    end
    def calc_indentation(pdf, expected_length)
      nnbsp = Prawn::Text::NBSP
      indent_str = "#{nnbsp}"
      final_length = nil
      itimes = 1
      pdf.update do
        font('Courier', **{size: 4, style: :regular}) do
          while width_of(indent_str) < expected_length
            indent_str = nnbsp * (itimes += 1)
          end
          final_length = width_of(indent_str)

          # On essaie pour voir si avec un itime de moins, on est plus
          # près de la valeur recherchée. Si c’est le cas, on la prend
          indent_str_moins_un = nnbsp * (itimes - 1)
          lenght_moins_un = width_of(indent_str_moins_un)
          if (expected_length - lenght_moins_un).abs < (final_length - expected_length).abs
            indent_str    = indent_str_moins_un.freeze
            final_length  = lenght_moins_un.freeze # débug
            itimes        -= 1 # débug
          end            
        end
      end
      indent_str = "<font name=\"Courier\" size=\"4\">#{indent_str}</font>".freeze
      # débug
      puts "\nexpected len: #{expected_length} / final length: #{final_length} / indent: #{indent_str} (itimes: #{itimes})".bleu
      sleep 4
      # /débug
      return indent_str
    end
  end #/<< self

  def own_builder?
    return false if class_tags.nil?
    class_tags.each do |tag|
      if self.respond_to?("build_#{tag}_paragraph".to_sym)
        @own_builder_method = "build_#{tag}_paragraph".to_sym
        return true
      end
    end
    return false
  end

  # Constructeur propre
  # TODO : Comme c'est une méthode utilisateur, il faut la protéger
  def own_builder(pdf)
    send(@own_builder_method, self, pdf)
  end

  # --- Predicate Methods ---

  def paragraph?; true  end
  def printed?  ; true  end
  def some_text? ; true  end # seulement ceux qui contiennent du texte

  def citation?     ; @is_citation      end
  def note_page?    ; @is_note_page     end
  def table_line?   ; @is_table_line    end
  def tagged_line?  ; @is_tagged_line   end
  def wrapped?      ; @is_wrapped       end
  def list_item?    ; @is_list_item     end
  attr_accessor :is_list_item

end #/class NTextParagraph
end #/class PdfBook
end #/module Prawn4book
