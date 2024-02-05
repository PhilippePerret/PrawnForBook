require_relative 'AnyParagraph'
module Prawn4book
class PdfBook
class PFBCode < AnyParagraph

  REG_NEXT_PARAG_STYLE = /^#{EXCHAR}\{.+?\}$/.freeze

  attr_reader :raw_code

  # {Hash} Contenant la définition qui doit affecter le paragraphe
  # suivant (cette instance a été mise dans la propriété :pfbcode
  # du paragraphe)
  # p.e. {font_size: 42}
  attr_reader :next_parag_style

  # Certains paragraphes de code doivent utiliser la propriété
  # @numero (par exemple les codes qui sont des cibles de référence)
  attr_reader :numero


  def initialize(book:, raw_code:, pindex:)
    super(book, pindex)
    @type             = 'pfbcode'
    @raw_code         = raw_code
    @next_parag_style = {}
    #
    # On met toujours le numéro, ça peut servir à diverses méthodes
    # utilisateur
    # 
    @numero = AnyParagraph.get_current_numero + 1
    
    #
    # Traitement immédiat de certains type de paragraphe
    # 
    case @raw_code.strip
    when REG_NEXT_PARAG_STYLE
      treat_as_next_parag_code
    when 'stop'
      Prawn4book.stop_gravure
      @isnotprinted = true
    when PdfBook::ReferencesTable::REG_CIBLE_REFERENCE
      # Rien
    end
  end


  def print(pdf)
    return if not_printed?
    case raw_code
    when 'new_page', 'nouvelle_page', 'saut_de_page'
      pdf.start_new_page
    when 'new_even_page','nouvelle_page_paire','fausse_page'
      pdf.update do
        start_new_page
        start_new_page if page_number.odd?
      end
    when 'new_odd_page', 'new_belle_page', 'nouvelle_page_impaire', \
      'belle_page', 'page_impaire'
      pdf.update do
        start_new_page
        start_new_page if page_number.even?
      end
    when 'line' # ligne vide
      pdf.move_to_next_line
    when 'no_pagination'
      book.page(pdf.page_number).pagination = false
    when 'stop_pagination'
      pdf.stop_pagination
    when 'start_pagination','restart_pagination'
      pdf.restart_pagination
    when 'stop_numerotation_paragraphs'
      AnyParagraph.stop_numerotation_paragraphs
    when 'restart_numerotation_paragraphs'
      AnyParagraph.restart_numerotation_paragraphs
    when /^move_to_(line|next|closest|first|last)(_line)?/.freeze
      pdf.instance_eval(raw_code)
    when PdfBook::ReferencesTable::REG_CIBLE_REFERENCE
      # Une cible de référence (ou un lien) seule sur une ligne
      # Pour le moment, on considère que ça ne peut être qu'une cible
      treate_as_cible_references(pdf, book)
    when PdfBook::ReferencesTable::REG_APPEL_REFERENCE
      raise PFBFatalError.new(2000, {code: raw_code})
    when 'index'
      book.page_index.build(pdf)
      book.pages[pdf.page_number].add_content_length(100) #arbitrairement
    when REG_METHODE_WITH_ARGS
      case raw_code
      when /^(?:colonne|column)s?\((.+?)\)$/ 
        change_nombre_colonnes($1, pdf)
      when /^index\((?<index_id>[a-z]+)\)$/
        book.index($~[:index_id].to_sym).print(pdf)
      when /^biblio/
        treate_as_bibliography(pdf)
      when /^fonte?\((.+)\)$/.freeze # Changement forcé de fonte
        force_fonte_change(pdf, $1.strip)
      when /^notice\((.+?)\)$/.freeze
        add_notice($1, self)
      when /^(?:erreur|error)\((.+?)\)$/.freeze
        add_erreur($1, self)
      else        
        #
        # Une méthode appelée entre (( ... )) sur la ligne
        # 
        # methode = $1.to_sym.freeze
        # params  = $2.freeze
        methode = $~[:method].to_sym.freeze
        params  = $~[:params].freeze
        traite_as_methode_with_params(pdf, methode, params)
      end
    when 'tdm','toc','table_des_matieres','table_of_contents','table_of_content'
      book.table_of_content.prepare_pages(pdf, first_turn?)
    when 'tdi','loi','table_des_illustrations','list_of_illustrations'
      book.table_illustrations.print(pdf, first_turn?)
    when 'list_of_abbreviations','liste_des_abreviations','loa','lda'
      book.abbreviations.print(pdf, first_turn?)
    when 'glossaire','glossary'
      book.glossary.print(pdf)
    when REG_METHODE_WITHOUT_ARGS
        traite_as_methode_with_params(pdf, $~[:method].to_sym.freeze)
    else
      raise PFBFatalError.new(1001, {code:raw_code, page: pdf.page_number})
    end
  end

  # Pour changer le nombre de colonnes dans la page
  # 
  # @params params_str [String]
  #   Les paramètres bruts tels qu’ils sont dans les parenthèses.
  # 
  # @params pdf [Prawn::PrawnView]
  #   Le document PDF en construction
  # 
  def change_nombre_colonnes(params_str, pdf)
    # return
    if params_str.match?(',')
      params_str = params_str.split(',').map { |e| e.strip }
      nombre_colonnes = params_str.shift.to_i.freeze
      options = params_str.join(', ')
      options = "{#{options}}" unless options.start_with?('{')
      options = eval(options)
    else
      nombre_colonnes = params_str.to_i.freeze
      options = {}
    end

    # Si le nombre de colonnes demandé correspond au nombre de colonnes
    # déjà en cours, on ne fait rien
    if book.columns_box && book.columns_box.column_count == nombre_colonnes
      spy "Aucun changement de colonnes. Je m’en retourne".jaune
      return
    end

    # Si le nombre de colonnes est 1 mais qu’on n’est pas en multi-
    # colonnage, on ne fait rien
    if nombre_colonnes == 1 && book.columns_box.nil?
      spy "Pas de colonne et pas de bloc colonne. Je m’en retourne.".jaune
      return
    end
    
    # Si on veut plus d’une colonne, on indique que le prochain
    # paragraphe devra tenir sur ce nombre de colonnes
    if nombre_colonnes > 1
      spy "INSTANCIATION DE BOITE COLONNES (#{nombre_colonnes})".jaune
      options.merge!(column_count:nombre_colonnes)
      book.columns_box = ColumnsBox.new(book, **options)
    else
      book.columns_box = nil
    end

  end

  def force_fonte_change(pdf, font_data)
    begin
      dfont =
        if font_data.match?(/^(['"]).+\1$/)
          font_data[1...-1]
        else
          eval("{#{font_data}}")
        end
      fonte =
        if dfont.is_a?(String)
          Fonte.get_by_name(dfont) || raise("Fonte introuvable.")
        else
          fonte = Fonte.new(name:dfont[:name], size:dfont[:size], style:dfont[:style].to_sym, hname:dfont[:hname])
        end
      pdf.font(fonte)
      @opere_font_change = true
    rescue Exception => e
      raise PFBFatalError.new(652, {bad:font_data.inspect, err:e.message})
    end
  end

  def font_change?
    @opere_font_change === true
  end

  def data
    @data ||= {pfbcode: self}
  end

  # Traitement d'un code comme une méthode avec ou sans paramètres
  # 
  # Attention : cette méthode peut-être en fait un objet avec
  # méthode, c'est-à-dire <objet>.<methode> (mais il ne peut pas
  # y avoir plus que ça)
  # 
  # @notes
  # 
  #   [voir si j'ai traité ici les nouvelles pages ajoutées]
  # 
  def traite_as_methode_with_params(pdf, methode, params = nil)
    # -- Exposer (pour les méthodes) --
    @pdf   = pdf
    @book  = book
    # -- Pour l'erreur --
    methode_ini = methode.dup.freeze
    #
    # Numéro de page au départ
    # 
    page_number_at_start = pdf.page_number.freeze
    begin
      #
      # Quand la méthode est définie comme méthode d'instance 
      # (avec ou sans arguments)
      #
      if methode.to_s.match?(/\./)
        objet, methode = methode.to_s.split('.').collect { |m| m.to_sym }
        if self.respond_to?(objet)
          self.instance_eval(raw_code)
        elsif Prawn4book.respond_to?(objet)
          objet = Prawn4book.send(objet)
        elsif PrawnHelpersMethods.respond_to?(objet)
          objet = PrawnHelpersMethods.send(objet)
        elsif defined?(eval(objet.to_s))
          objet = eval(objet.to_s)
        else
          raise PFBFatalError.new(5001, {o: objet.to_s, m: methode_ini})
        end
        # 
        # Cet objet connait-il la méthode +methode+ ?
        # 
        if objet.respond_to?(methode)
          params = params ? eval("[#{params}]") : []
          params_count = objet.method(methode).parameters.count
          if params_count == 0
            objet.send(methode)
          elsif params_count == params.count
            objet.send(methode, *params)
          elsif params_count == params.count + 1
            params.unshift(pdf)
            objet.send(methode, *params)
          elsif params_count == params.count + 2
            params.unshift(pdf)
            params << self
            objet.send(methode, *params)
          else
            raise PFBFatalError.new(5003, {n:params_count, max:params_count+2, c: methode_ini})
          end
        else
          raise PFBFatalError.new(5002, {o: objet.to_s, m:methode, c: methode_ini})
        end
        return
      end

      if self.respond_to?(methode)
        #
        # --- Méthode définie comme méthode d'instance ---
        #
        self.instance_eval(raw_code)
      elsif PrawnHelpersMethods.respond_to?(methode)
        #
        # --- Méthode définie comme méthode de classe ---
        # 
        parameters_count = PrawnHelpersMethods.method(methode).parameters.count
        str = 
          case parameters_count
          when 2 then PrawnHelpersMethods.send(methode,pdf,book)
          when 1 then PrawnHelpersMethods.send(methode,pdf)
          when 0 then PrawnHelpersMethods.send(methode)
          end
        pdf.update do
          text(str)
        end
      elsif Prawn4book.respond_to?(methode)
        params = params ? eval("[#{params}]") : []
        params_count = Prawn4book.method(methode).parameters.count
        if params_count == 0
          Prawn4book.send(methode)
        elsif params_count == params.count
          Prawn4book.send(methode, *params)
        else
          params.unshift(pdf)       if params_count > params.count
          params.insert(1, book) if params_count > params.count
          begin
            Prawn4book.send(methode, *params)
          rescue Exception => e
            msg = "methode défectueuse : #{methode.inspect}".rouge + \
                "\nBacktrace:\n#{e.backtrace.join("\n")}".orange
            PFBError.context_add(msg)
            raise e
          end
        end
      else
        raise 'méthode inconnue'
      end
    rescue PFBFatalError => e
      raise e
    rescue Exception => e
      if e.message == 'méthode inconnue'
        raise PFBFatalError.new(1002, {code:raw_code, meth: methode})
      else
        # Méthode mal implémentée
        raise PFBFatalError.new(1100, {code:raw_code, lieu:e.backtrace.shift, err_msg:e.message, error:e, backtrace:true})
      end
    end

    #
    # Numéro de page après la procédure
    #   
    page_number_at_end = pdf.page_number.freeze

  end

  ##
  # Traitement d'un code qui doit affecter le paragraphe
  # suivant. Se présente sous la forme : '(( {...} ))'
  # 
  def treat_as_next_parag_code
    @is_for_next_paragraph = true
    @isnotprinted = true # pour ne pas l'imprimer
    @next_parag_style = eval(raw_code)
    # S’il y a une fonte définie, on l’étudie pour en faire vraiment
    # une fonte PFB
    if (ft = @next_parag_style[:font]||@next_parag_style.delete(:fonte))
      @next_parag_style.merge!(font: Fonte.get_in(ft).or_default())
    end
    # Rationnalisatin de la propriété d’identation
    if (ind = @next_parag_style.delete(:indentation))
      @next_parag_style.merge!(indent: ind)
    end
  end

  # --- Formatage Methods ---

  ##
  # Traitement spécial quand le code est une marque de bibliographie,
  # comme par exemple '(( biblio(livre) ))'
  # Il faut :
  #   - extraire le tag de la bibliographie
  #   - prendre la bibliographie instanciée
  #   - l'imprimer dans le livre
  def treate_as_bibliography(pdf)
    Bibliography.print(raw_code.match(/^biblio.*?\((.+?)\)$/)[1], book, pdf)
  end

  ##
  # Noter qu'on ne passe ici que lorsque la balise de référence 
  # "occupe" toute la ligne (lorsqu'il n'y a pas d'autre texte). Ça
  # arrive surtout lorsque c'est une cible qu'il faut définir.
  # 
  # Si on est en format paragraphe ou hybride, on doit générer une
  # erreur fatale car on n’aura pas de numéro de paragraphe.
  # 
  def treate_as_cible_references(pdf, book)
    cible  = raw_code[3...-1]
    if book.recipe.paragraph_number?
      params = {pagin:book.recipe.page_num_type, cible:cible, idx:pindex, str:raw_code}
      raise PFBFatalError.new(2003, **params)
    end
    book.table_references.add(cible, {paragraph:self})
  end

  # Pour pouvoir obtenir une valeur de style "inline" en faisant
  # simplement 'pfbcode[:width]' (depuis un paragraphe)
  def [](key)
    next_parag_style[key]
  end

  # --- Predicate Methods ---

  def paragraph?  ; false end
  def pfbcode?    ; true  end

  # Par défaut un pfb-code est un paragraphe vide
  def empty_paragraph?; true end

  def for_next_paragraph?
    @is_for_next_paragraph === true
  end

  def multi_columns_end?
    raw_code.match?(/^(colonne|column)s?\((|1)\)$/.freeze)
  end

  def line_height(new_height, dfonte = nil)
    pdf.line_height = new_height
    if dfonte
      if dfonte.is_a?(Fonte)
        fonte = dfonte
      else
        fonte = Fonte.new(name:dfonte[:fname], style:dfonte[:fstyle], size:dfonte[:fsize])
      end
      pdf.font(fonte)
    end
  end

  REG_METHODE_WITH_ARGS     = /^(?<method>[a-zA-Z0-9_.]+)(?:\((?<params>.*?)\))$/.freeze
  REG_METHODE_WITHOUT_ARGS  = /^(?<method>[a-zA-Z0-9_.]+)$/.freeze

end #/class PFBCode
end #/class PdfBook
end #/module Prawn4book
