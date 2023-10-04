require_relative 'AnyParagraph'
module Prawn4book
class PdfBook
class NTextParagraph < AnyParagraph

  attr_reader :data
  attr_reader :text
  attr_reader :numero

  def initialize(pdfbook,data)
    super(pdfbook)
    @data   = data.merge!(type: 'paragraph')
    # @numero = AnyParagraph.get_next_numero
    # dbg "@numero = #{@numero.inspect}".bleu
    #
    # On regarde tout de suite la nature du paragraphe (table ? item
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
    @text = data[:text] || data[:raw_line]

    @is_citation    = text.match?(REG_CITATION)
    @is_list_item   = text.match?(REG_LIST_ITEM)
    @is_table_line  = text.match?(REG_TABLE_LINE)
    #
    # En cas de citation ou d'item de liste, on retire la marque
    # de début du paragraphe ("> " ou "* ")
    @text = text[1..-1].strip if citation? || list_item?

    recup = {}
    tx = self.class.__get_class_tags_in(text, recup)
    self.class_tags = recup[:class_tags]
    @text = tx
    
    # 
    # Pré-définition des styles en fonction de la nature du paragra-
    # phe de texte
    # 
    if citation?
      @text = "<i>#{@text}</i>"
      add_style({font_size: font_size + 1, margin_left: 1.cm, margin_right: 1.cm, margin_top: 0.5.cm, margin_bottom: 0.5.cm, no_num:true})
    elsif list_item?
      add_style({margin_left:3.mm, no_num: true, cursor_positionned: true})
    elsif table_line?
      # rien à faire
    elsif tagged_line?
      # rien à faire
    end

    @text_ini = @text

  end #/pre_parse_text_paragraph

  REG_CITATION    = /^> .+$/.freeze
  REG_LIST_ITEM   = /^\* .+$/.freeze
  REG_TABLE_LINE  = /^\|/.freeze 

  
  # --- Printing Methods ---

  ##
  # Méthode principale d'écriture du paragraphe
  # @note
  #   C'est vraiment cette méthode qui écrit un paragraphe texte,
  #   en plaçant le curseur, en réglant les propriétés, etc.
  # 
  def print(pdf)

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
    @text = @text_ini

    #
    # Définir le numéro du paragraphe ici, pour que
    # le format :hybrid (n° page + n° paragraphe) fonctionne
    # 
    @numero = AnyParagraph.get_next_numero
    # dbg "@numero = #{@numero.inspect}".bleu

    #
    # Quelques traitements communs, comme la retenue du numéro de
    # la page ou le préformatage pour les éléments textuels.
    # 
    super

    # spy "text au début de print (paragraphe) : #{text.inspect}".orange
    
    #
    # Si le paragraphe possède son propre builder, on utilise ce
    # dernier pour le construire et on s'en retourne.
    # Un paragraphe possède son propre builder lorsqu'il est stylé
    # (précédé de "<style>::") et qu'il existe une méthode pour
    # construire ce style dans formater.rb de nom
    #     build_<style>_paragraph
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

    mg_left   = margin_left
    mg_bot    = margin_bottom  || nil # ...
    mg_right  = margin_right
    no_num    = style[:no_num] || false
    cursor_positionned = style[:cursor_positionned] || false

    #
    # Pour invoquer cette instance dans le pdf.update
    # 
    pa = self

    #
    # Préformatage par nature de paragraphe
    # 
    # Typiquement, c'est ici qu'on ajoute un "- " au début des items
    # de liste
    # 
    formate_per_nature(pdf)

    #
    # On inscrit enfin le texte
    # 
    pdf.update do

      # 
      # FONTE (name, taille et style)
      # 
      begin
        spy "Application de la fonte : #{Fonte.default_fonte.inspect}"
        font(Fonte.default_fonte)
      rescue Prawn::Errors::UnknownFont
        spy "--- fonte inconnue ---"
        spy "Fontes : #{pdfbook.recipe.get(:fonts).inspect}"
        raise
      end
    end

      
    ###########################
    #  ÉCRITURE DU PARAGRAPHE #
    ###########################
    begin
      pdf.update do
        options = {
          inline_format:  true,
          align:          pa.text_align,
          size:           pa.font_size
        }

        if pa.kerning?
          options.merge!(kerning: pa.kerning)
        end
        if pa.character_spacing?
          options.merge!(character_spacing: pa.character_spacing)
        end

        if pa.margin_top && pa.margin_top > 0
          move_down(pa.margin_top)
        end

        # 
        # Placement sur la première ligne de référence suivante
        # 
        move_cursor_to_next_reference_line unless cursor_positionned

        # 
        # Maintenant que nous sommes positionnés et que toutes les
        # options sont définis, on peut formater le texte final
        # 
        # self.current_options = options

        #
        # Écriture du numéro du paragraphe
        # 
        pa.print_paragraph_number(pdf) if pdfbook.recipe.paragraph_number? && not(no_num)

        #
        # S'il faut exporter le texte
        # 
        pa.book.export_text(pa.text) if pa.book.export_text?

        # options.merge!(indent_paragraphs: textIndent) if textIndent
        if mg_left > 0

          #
          # Écriture du paragraphe dans une boite
          # (quand la marge gauche est fixée)
          # 
          
          wbox = bounds.width - (mg_left + mg_right)
          span_options = {position: mg_left}
          #
          # - dans un text box -
          # 
          span(wbox, **span_options) do
            text(pa.text, **options)
          end
        else

          # 
          # Écriture du paragraphe dans le flux (texte normal)
          # 

          # 
          # Hauteur que prendra le texte
          # 
          final_height = height_of(pa.text)

          # 
          # Le paragraphe tient-il sur deux pages ?
          # 
          chevauchement = (cursor - final_height) < 0

          # --- Écriture ---
          # 
          # Le bout de texte qui sera vraiment écrit (une partie peut
          # être écrite sur la page précédente)
          # 
          rest_text = nil

          if chevauchement
            # 
            # On passe ici quand le texte est trop et qu'il va
            # passer sur la page suivante. Malheureusement, en utilisant
            # le comportement par défaut, le texte sur la page suivante
            # n'est pas posé sur les lignes de référence. Il faut donc
            # que je place un bounding_box pour placer la part de
            # texte possible, puis on passe à la page suivante et on
            # se place sur la place suivante.
            # 
            # height_diff = final_height - cursor
            # spy "Texte trop long (de #{height_diff}) : <<< #{parag.text} >>>".rouge
            # spy "margin bottom: #{parag.margin_bottom}"
            box_height = cursor + line_height
            # spy "Taille box = #{box_height}".rouge
            other_options = {
              width:  bounds.width,
              height: box_height,
              at:     [0, cursor],
              overflow: :truncate
            }.merge(options)
            excedant = text_box(pa.text, **other_options)
            # spy "Excédant de texte : #{excedant.pretty_inspect}".rouge
            start_new_page
            move_cursor_to_next_reference_line
            rest_text = excedant.map {|h| h[:text] }.join('')
          else
            rest_text = pa.text
          end
          # spy "rest_text = #{rest_text.inspect}"
          # spy "(pour #{rest_text.inspect}, options = #{options.inspect}"
          # ------------------------------
          # L'écriture véritable du texte
          # ------------------------------
          text(rest_text, **options)
        end

        if mg_bot && mg_bot > 0
          move_down(mg_bot)
        end

      end #/pdf

    rescue PrawnFatalError => e
      raise e
    rescue Exception => e
      raise FatalPrawnForBookError.new(100, {
        text:text.inspect, 
        err: e.message, 
        backtrace:(debug? ? e.backtrace.join("\n") : '')
      })
    end

    # 
    # On prend la dernière page du paragraphe, c'est celle sur 
    # laquelle on se trouve maintenant
    # 
    self.last_page = pdf.page_number

  end

  def indent
    @indent ||= book.recipe.text_indent
  end

  def method_missing(method_name, *args, &block)
    if method_name.to_s.end_with?('=')
      prop_name = method_name.to_s[0..-2].to_sym
      if self.instance_variables.include?(prop_name)
        self.instance_variable_set(prop_name, args)
      else
        puts "instances_variables : #{self.instance_variables.inspect}"
        PrawnView.add_error_on_property(prop_name)
        raise "Le paragraphe ne connait pas la propriété #{prop_name.inspect}."
      end
    else
      raise FatalPrawnForBookError.new(200, **{mname: method_name})
    end
  end

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
  def own_builder(pdf)
    send(@own_builder_method, self, pdf)
  end

  # --- Predicate Methods ---

  def paragraph?; true end

  def sometext? ; true end # seulement ceux qui contiennent du texte
  alias :some_text? :sometext?

  def citation?     ; @is_citation      end
  def table_line?   ; @is_table_line    end
  def tagged_line?  ; @is_tagged_line   end
  def list_item?    ; @is_list_item     end
  attr_accessor :is_list_item

end #/class NTextParagraph
end #/class PdfBook
end #/module Prawn4book
