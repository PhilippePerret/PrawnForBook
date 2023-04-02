require_relative 'AnyParagraph'
module Prawn4book
class PdfBook
class NTextParagraph < AnyParagraph

  attr_reader :data
  attr_reader :numero
  alias :number :numero

  alias :book :pdfbook


  # Liste des balises de style de paragraphe
  attr_accessor :styled_tags


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

    # spy "text au début de print (paragraphe) : #{text.inspect}".orange
    
    #
    # Préformatage du texte
    # (code ruby, )
    # @note : modifie directement @text
    # 
    preformate

    #
    # Si le paragraphe possède son propre builder, on utilise ce
    # dernier pour le construire et on s'en retourne.
    # Un paragraphe possède son propre builder lorsqu'il est stylé
    # (précédé de "<style>::") et qu'il existe une méthode pour
    # construire ce style dans formater.rb
    # 
    if own_builder?
      return own_builder(pdf) # stop
    end
    #
    # Si le paragraphe possède un formateur, on s'en sert pour 
    # formater le paragraphe et on poursuit (contrairement au
    # "constructeur" ci-dessus)
    # 
    # @question
    #   Est-ce vraiment bien ici qu'il faut faire ce traitement ?
    #   Ne faudrait-il pas, aussi, un formateur de fin de chaine
    #   qui permette de traiter le +final_str+ ci-dessus.
    #   Les "pre_formaters" et les "post_formaters"
    # 
    # @note
    #   Ces "formateurs" sont des méthodes d'instance. Elles 
    #   transforment la propriété @text.
    #   Peut-être vaudrait-il mieux ne pas toucher à @text et
    #   avoir une propriété @formated_text qui soit modifié
    #   partout ici. Voir aussi, maintenant, la propriété @final_text
    #   qui sera le texte vraiment traité.
    # 
    own_formaters if own_formaters?


    mg_left   = self.margin_left
    if pfbcode && pfbcode[:margin_left]
      mg_left += pfbcode[:margin_left]
    end
    mg_right  = self.margin_right
    mg_top    = self.margin_top
    theindent = self.indent

    # 
    # Indication de la première page du paragraphe
    # 
    self.first_page = pdf.page_number

    #
    # Préformatage du paragraphe
    # 
    # C'est ici, par exemple, qu'on regarde si c'est un item de liste
    # ou une citation.
    # 
    preformate

    # 
    # Ajout d'un traitement spéciale : formated_text peut retourner
    # un array définissant en deuxième argument la margin left
    # 
    no_num = false
    mg_bot = nil

    #
    # Fonte et style à utiliser pour le paragraphe
    # (note : peut avoir été modifié de force ou par le style)
    # 
    # Note : elles ne peuvent être définies qu'ici, après le
    # parse du paragraphe (dont les balises initiales peuvent
    # modifier l'aspect)
    # 
    fontFamily  = font_family(pdf)
    fontStyle   = font_style(pdf)
    fontSize    = font_size(pdf)
    textIndent  = recipe.text_indent
    textAlign   = self.text_align
    cursor_positionned = false
    # spy "Indentation du texte : #{textIndent.inspect}" if textIndent > 0

    mg_left   = final_specs[:mg_left]   if final_specs.key?(:mg_left)
    mg_top    = final_specs[:mg_top]    if final_specs.key?(:mg_top)
    mg_bot    = final_specs[:mg_bot]    if final_specs.key?(:mg_bot)
    mg_right  = final_specs[:mg_right]  if final_specs.key?(:mg_right)
    no_num    = final_specs[:no_num]    if final_specs.key?(:no_num)
    fontSize  = final_specs[:size]      if final_specs.key?(:size)
    if final_specs.key?(:cursor_positionned)
      cursor_positionned = final_specs[:cursor_positionned]
    end

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
        ft = font(Fonte.default_fonte)
      rescue Prawn::Errors::UnknownFont => e
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
        pdf.current_options = options
        parag.final_formatage(pdf)

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
          # TODO
          # ATTENTION : LE TEXTE N'EST PAS CORRIGÉ, ICI
          # 
          # 
          span(wbox, **span_options) do
            text(parag.final_text, **options)
          end
        else

          # 
          # Écriture du paragraphe dans le flux (texte normal)
          # 

          # 
          # Hauteur que prendra le texte
          # 
          final_height = height_of(parag.final_text)

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
            height_diff = final_height - cursor
            # spy "Texte trop long (de #{height_diff}) : <<< #{parag.final_text} >>>".rouge
            # spy "margin bottom: #{parag.margin_bottom}"
            box_height = cursor + line_height
            # spy "Taille box = #{box_height}".rouge
            other_options = {
              width:  bounds.width,
              height: box_height,
              at:     [0, cursor],
              overflow: :truncate
            }.merge(options)
            excedant = text_box(parag.final_text, **other_options)
            # spy "Excédant de texte : #{excedant.pretty_inspect}".rouge
            start_new_page
            move_cursor_to_next_reference_line
            rest_text = excedant.map {|h| h[:text] }.join('')
          else
            # rest_text = parag.final_text
            rest_text = parag.text
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
      puts "Problème avec le paragraphe #{final_text.inspect}".rouge
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
      inline_style(:font_size, pdf.default_font_size)
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
    return false if styled_tags.nil?
    styled_tags.each do |tag|
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

  #
  # @note
  #  'styled_tags' contient les tags en début de paragraphe, avant
  #   des '::', qui définissent la "class" du paragraphe.
  def own_formaters?
    spy "styled_tags = #{styled_tags.inspect}".bleu
    return false if styled_tags.nil?
    @own_formaters_methods = []
    styled_tags.each do |tag|
      if self.respond_to?("__formate_#{tag}".to_sym)
        @own_formaters_methods << "__formate_#{tag}".to_sym
        # Il faut toutes les récupérerer
      elsif self.respond_to?("#{tag}_formater".to_sym)
        @own_formaters_methods << "#{tag}_formater".to_sym
      else
        raise "Impossible de traiter le style #{tag.inspect}…"
      end
    end
    return @own_formaters_methods.any?
  end

  def own_formaters
    @own_formaters_methods.each do |formater|
      begin
        self.send(formater)
      rescue PrawnFatalError => e
        raise e
      rescue Exception => e
        puts "FORMATER ERROR: #{e.message}".rouge
      end
    end
  end

  # --- Predicate Methods ---

  def paragraph?; true end

  def sometext? ; true end # seulement ceux qui contiennent du texte
  alias :some_text? :sometext?

  def list_item?; @is_list_item end
  attr_accessor :is_list_item

  def citation? ; @is_citation  end

  # --- Data Methods ---

  REG_LEADING_TAG   = /^[a-z_0-9]+::/.freeze
  REG_LEADING_TAGS  = /^((?:(?:[a-z_0-9]+)::){1,6})(.+)$/.freeze
  def text
    @text 
  end

  def prepare_text
    tx = data[:text]||data[:raw_line]
    if tx.match?(REG_LEADING_TAG)
      # 
      # <= Le texte contient des balises de style
      # => Il faut relever ces balises et les retirer du
      #    texte.
      tx = tx.gsub(REG_LEADING_TAGS) do
        tags = $1.freeze
        text = $2.freeze
        self.styled_tags = tags.split('::')
        text
      end
    end
    @text = tx
  end

end #/class NTextParagraph
end #/class PdfBook
end #/module Prawn4book
