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

    # TODO : Voir et remettre ce qui est nécessaire
    return

    # En cas de citation ou d'item de liste, on retire la marque
    # de début du paragraphe ("> " ou "* ")
    @text = raw_text[1..-1].strip if citation? || list_item?

    recup = {}
    tx = NTextParagraph.__get_class_tags_in(raw_text, recup)
    self.class_tags = recup[:class_tags]
    @text = tx
    
    # 
    # Pré-définition des styles en fonction de la nature du paragra-
    # phe de texte
    # 
    if citation?
      @text = "<i>#{@text}</i>"
      add_style({size: font_size + 1, left: 1.cm, right: 1.cm, top: 0.5.cm, bottom: 0.5.cm, no_num:true})
    elsif list_item?
      add_style({left:3.mm, no_num: true})
    elsif table_line?
      # rien à faire
    elsif tagged_line?
      # rien à faire
    end

  end #/pre_parse_text_paragraph

  REG_CITATION    = /^> .+$/.freeze
  REG_LIST_ITEM   = /^\* .+$/.freeze
  REG_NOTE_PAGE   = /^\^[0-9+] /.freeze

  
  # --- Printing Methods ---

  ##
  # Méthode principale d'écriture du paragraphe
  # @note
  #   C'est vraiment cette méthode qui écrit un paragraphe texte,
  #   en plaçant le curseur, en réglant les propriétés, etc.
  # 
  def print(pdf)

    @pdf = pdf

    #
    # Pour repartir du texte initial, même lorsqu'un second tour est
    # nécessaire pour traiter les références croisées.
    # 
    # @exemple
    #   Par exemple, si le paragraphe est un item de liste, il 
    #   commence par '* '. Mais au préformatage, ce '* ' est retiré
    #   de @text. La deuxième fois qu'on traite l'impression, on se
    #   retrouve(rait) donc avec un @text qui ne commencerait plus 
    #   par '* ' et qui ne serait donc plus un item de liste…
    # 
    @text = raw_text.dup

    #
    # Quelques traitements communs, comme la retenue du numéro de
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

    #
    # Préformatage par nature de paragraphe
    # 
    # Typiquement, c'est ici qu'on ajoute un "- " au début des items
    # de liste (encore le cas ?)
    # 
    # TODO : Normalement, ça devrait disparaitre ou être traité 
    # autrement.
    # 
    formate_per_nature(pdf)

    ###########################
    #  ÉCRITURE DU PARAGRAPHE #
    ###########################
    # 
    # Principe : voir Printer::pretty_render
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
      width: width || @pdf.bounds.width,
      align: :justify
    }.freeze
  end

  # La fonte pour la paragraphe
  # 
  # Elle peut être définie par un pfbcode avant le paragraphe
  # 
  def fonte
    @fonte ||= begin
      if styles[:font_family] || styles[:font_size] || styles[:font_style]
        Fonte.new(name:font_family, size:font_size, style:font_style)
      else
        Fonte.default_fonte
      end
    end
  end

  def indent
    @indent ||= book.recipe.text_indent
  end

  # def method_missing(method_name, *args, &block)
  #   if method_name.to_s.end_with?('=')
  #     prop_name = method_name.to_s[0..-2].to_sym
  #     if self.instance_variables.include?(prop_name)
  #       self.instance_variable_set(prop_name, args)
  #     else
  #       puts "instances_variables : #{self.instance_variables.inspect}"
  #       PrawnView.add_error_on_property(prop_name)
  #       raise "Le paragraphe ne connait pas la propriété #{prop_name.inspect}."
  #     end
  #   else
  #     raise FatalPrawnForBookError.new(200, **{mname: method_name})
  #   end
  # end

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

  def paragraph?; true end

  def sometext? ; true end # seulement ceux qui contiennent du texte
  alias :some_text? :sometext?

  def citation?     ; @is_citation      end
  def note_page?    ; @is_note_page     end
  def table_line?   ; @is_table_line    end
  def tagged_line?  ; @is_tagged_line   end
  def list_item?    ; @is_list_item     end
  attr_accessor :is_list_item

end #/class NTextParagraph
end #/class PdfBook
end #/module Prawn4book
