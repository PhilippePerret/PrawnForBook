require_relative 'AnyParagraph'
module Prawn4book
class PdfBook
class NTextParagraph < AnyParagraph

  attr_reader :data
  attr_reader :numero
  alias :number :numero

  alias :book :pdfbook


  def initialize(pdfbook,data)
    super(pdfbook)
    @data   = data.merge!(type: 'paragraph')
    @numero = AnyParagraph.get_next_numero
    prepare_text # pour obtenir tout de suite les balises initiales
  end


  # --- Helper Methods ---

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
    # construire ce style dans formater.rb
    # 
    return own_builder(pdf) if own_builder?

    #
    # Fonte et style à utiliser pour le paragraphe
    # (note : peut avoir été modifié de force ou par le style)
    # 
    # Note : elles ne peuvent être définies qu'ici, après le
    # parse du paragraphe (dont les balises initiales peuvent
    # modifier l'aspect)
    # 
    # spy "final_specs = #{final_specs.inspect}".jaune, true
    # fontFamily  = font_family(pdf)
    # fontStyle   = font_style(pdf)
    fontSize    = final_specs[:size]    || font_size(pdf)
    # textIndent  = final_specs[:indent]  || recipe.text_indent
    textAlign   = final_specs[:align]   || self.text_align
    cursor_positionned = false

    mg_left   = final_specs[:mg_left] || (pfbcode && pfbcode[:margin_left]) || self.margin_left
    mg_top    = final_specs[:mg_top]  || self.margin_top
    mg_bot    = final_specs[:mg_bot]  || nil # ...
    mg_right  = final_specs[:mg_right] || self.margin_right
    no_num    = final_specs[:no_num] || false
    cursor_positionned = final_specs[:cursor_positionned] || false

    #
    # Pour invoquer cette instance dans le pdf.update
    # 
    parag = self

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
          align:          textAlign,
          size:           fontSize
        }

        if parag.final_specs.key?(:kerning)
          options.merge!(kerning: parag.final_specs[:kerning])
        end
        if parag.final_specs.key?(:character_spacing)
          options.merge!(character_spacing: parag.final_specs[:character_spacing])
        end

        if mg_top && mg_top > 0
          move_down(mg_top)
        end

        # 
        # Placement sur la première ligne de référence suivante
        # 
        move_cursor_to_next_reference_line unless cursor_positionned

        # 
        # Maintenant que nous sommes positionnés et que toutes les
        # options sont définis, on peut formater le texte final
        self.current_options = options

        #
        # Écriture du numéro du paragraphe
        # 
        parag.print_paragraph_number(pdf) if not(no_num) && pdfbook.recipe.paragraph_number?

        # options.merge!(indent_paragraphs: textIndent) if textIndent
        if mg_left > 0
          #
          # Écriture du paragraphe dans une boite
          # 
          wbox = bounds.width - (mg_left + mg_right)
          span_options = {position: mg_left}
          # - dans un text box -
          # 
          span(wbox, **span_options) do
            text(parag.text, **options)
          end
        else

          # 
          # Écriture du paragraphe dans le flux (texte normal)
          # 

          # 
          # Hauteur que prendra le texte
          # 
          final_height = height_of(parag.text)

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
            excedant = text_box(parag.text, **other_options)
            # spy "Excédant de texte : #{excedant.pretty_inspect}".rouge
            start_new_page
            move_cursor_to_next_reference_line
            rest_text = excedant.map {|h| h[:text] }.join('')
          else
            rest_text = parag.text
            # rest_text = parag.text
          end
          spy "rest_text = #{rest_text.inspect}"
          spy "options = #{options.inspect}"
          # ------------------------------
          # L'écriture véritable du texte
          # ------------------------------
          text(rest_text, **options)
        end

        if mg_bot && mg_bot > 0
          move_down(mg_bot)
        end

      end
    rescue PrawnFatalError => e
      raise e
    rescue Exception => e
      puts "Problème avec le paragraphe #{text.inspect}".rouge
      puts e.backtrace.join("\n").rouge if debug?
      puts "ERREUR : #{e.message}"
      exit
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

  def margin_bottom
    @margin_bottom || book.recipe.book_format[:page][:margins][:bot]
  end
  def margin_top
    @margin_top ||= super || 0
  end

  def margin_left; @margin_left ||= 0 end
  def margin_left=(val); @margin_left = val end

  def margin_right; @margin_right ||= 0 end
  def margin_right=(val); @margin_right = val end

  def font_family(pdf)
    @font_family ||= begin
      pdf.default_font_name
    end
  end
  def font_family=(val)
    @font_family = val
  end

  def font_size(pdf)
    @font_size ||= begin
      inline_style(:font_size, Metric.default_font_size)
    end
  end
  def font_size=(val)
    @font_size = val
  end

  def font_style(pdf)
    @font_style ||= begin
      pdf.default_font_style
    end
  end
  def font_style=(val)
    @font_style = val
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
      raise NoMethodError.new("La méthode #{method_name.inspect} est inconnue de nos services.")
    end
  end

  # @return le style qui est peut-être défini par un code en ligne
  # au-dessus du paragraphe.
  def inline_style(key, default)
    return default if pfbcode.nil?
    pfbcode.parag_style[key] || default
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

  def list_item?; @is_list_item end
  attr_accessor :is_list_item

  def citation? ; @is_citation  end

  # --- Data Methods ---

  def text
    @text 
  end

  def prepare_text
    recup = {}
    tx = self.class.__get_class_tags_in(data[:text]||data[:raw_line], recup)
    self.class_tags = recup[:class_tags]
    @text     = tx
    @text_ini = tx
  end

end #/class NTextParagraph
end #/class PdfBook
end #/module Prawn4book
